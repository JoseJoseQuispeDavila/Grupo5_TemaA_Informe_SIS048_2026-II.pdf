import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get author => text()();
  TextColumn get isbn => text().nullable()();
  IntColumn get year => integer().withDefault(const Constant(2000))();
  TextColumn get genre => text().withDefault(const Constant('General'))();
  BoolColumn get available => boolean().withDefault(const Constant(true))();
  IntColumn get addedAt => integer().named('added_at')();
}

class Loans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer()
      .named('book_id')
      .references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get borrower => text()();
  IntColumn get loanDate => integer().named('loan_date')();
  IntColumn get dueDate => integer().named('due_date').nullable()();
  IntColumn get returnDate => integer().named('return_date').nullable()();
  TextColumn get status => text().withDefault(
      const Constant('active'))(); // 'active' | 'returned' | 'overdue'
}

@DriftAccessor(tables: [Books])
class BooksDao extends DatabaseAccessor<AppDatabase> with _$BooksDaoMixin {
  BooksDao(super.db);

  Future<List<Book>> getAllBooks() => select(books).get();

  Stream<List<Book>> watchAllBooks() => select(books).watch();

  Stream<List<Book>> watchAvailableBooks() =>
      (select(books)..where((b) => b.available.equals(true))).watch();

  Future<List<Book>> getByGenre(String genre) =>
      (select(books)..where((b) => b.genre.equals(genre))).get();

  Future<Book?> getBook(int id) =>
      (select(books)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<int> insertBook(BooksCompanion book) => into(books).insert(book);

  Future<bool> updateBook(int id, BooksCompanion data) async {
    final rows =
        await (update(books)..where((b) => b.id.equals(id))).write(data);
    return rows > 0;
  }

  Future<void> setAvailability(int id, bool available) async {
    await (update(books)..where((b) => b.id.equals(id)))
        .write(BooksCompanion(available: Value(available)));
  }

  Future<int> deleteBook(int id) {
    return (delete(books)..where((b) => b.id.equals(id))).go();
  }
}

@DriftAccessor(tables: [Loans])
class LoansDao extends DatabaseAccessor<AppDatabase> with _$LoansDaoMixin {
  LoansDao(super.db);

  Stream<List<Loan>> watchAllLoans() => select(loans).watch();

  Future<List<Loan>> getActiveLoans() =>
      (select(loans)..where((l) => l.status.equals('active'))).get();

  Future<List<Loan>> getLoansByBook(int bookId) =>
      (select(loans)..where((l) => l.bookId.equals(bookId))).get();

  Future<Loan?> getLoan(int id) =>
      (select(loans)..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<int> insertLoan(LoansCompanion loan) => into(loans).insert(loan);

  Future<void> returnLoan(int loanId) async {
    await (update(loans)..where((l) => l.id.equals(loanId)))
        .write(LoansCompanion(
      status: const Value('returned'),
      returnDate: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }
}

@DriftDatabase(
  tables: [Books, Loans],
  daos: [BooksDao, LoansDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        // Incorpora la clave foránea en bases de la versión 1.
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.alterTable(TableMigration(loans));
          }
        },
        beforeOpen: (_) async {
          // Los pragmas se establecen fuera de la transacción de migración.
          await customStatement('PRAGMA journal_mode=WAL');
          await customStatement('PRAGMA foreign_keys=ON');
        },
      );

  /// Constructor para tests (BD en memoria).
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'bibliotrack.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
