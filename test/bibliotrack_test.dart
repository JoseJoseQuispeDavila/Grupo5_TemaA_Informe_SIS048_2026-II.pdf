// test/bibliotrack_test.dart
//
// ✅ TESTS PROVISTOS COMPLETOS — El estudiante NO debe modificar este archivo.
//    Solo debe ejecutarlos. Si fallan, significa que hay errores en la implementación.
//
//  Para ejecutar:
//    flutter test test/bibliotrack_test.dart -v
//
import 'package:bibliotrack/core/database/app_database.dart';
import 'package:bibliotrack/features/books/domain/entities/book_entity.dart';
import 'package:bibliotrack/features/books/presentation/controllers/books_controller.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Datos de prueba ───────────────────────────────────────────────────────
BookEntity _book({
  int id = 1,
  String title = 'Cien años de soledad',
  String author = 'García Márquez',
  int year = 1967,
  String genre = 'Ficción',
  bool available = true,
}) => BookEntity(
  id: id, title: title, author: author, year: year,
  genre: genre, available: available,
  addedAt: DateTime(2024, 1, 15),
);

LoanEntity _loan({
  int id = 1, int bookId = 1,
  String borrower = 'Ana Torres',
  String status = 'active',
  DateTime? dueDate,
  DateTime? returnDate,
}) => LoanEntity(
  id: id, bookId: bookId, borrower: borrower,
  loanDate: DateTime(2024, 3, 1),
  dueDate: dueDate, returnDate: returnDate, status: status,
);

void main() {

  // ═══════════════════════════════════════════════════════
  // GRUPO 1 — BookEntity: reglas de negocio
  // ═══════════════════════════════════════════════════════
  group('BookEntity — reglas de negocio', () {

    test('isClassic: libro de 1967 debe ser clásico', () {
      expect(_book(year: 1967).isClassic, isTrue);
    });

    test('isClassic: libro reciente NO debe ser clásico', () {
      expect(_book(year: DateTime.now().year - 5).isClassic, isFalse);
    });

    test('statusLabel: "Disponible" cuando available=true', () {
      expect(_book(available: true).statusLabel, equals('Disponible'));
    });

    test('statusLabel: "Prestado" cuando available=false', () {
      expect(_book(available: false).statusLabel, equals('Prestado'));
    });

    test('yearLabel: retorna "Año: 1967"', () {
      expect(_book(year: 1967).yearLabel, equals('Año: 1967'));
    });
  });

  // ═══════════════════════════════════════════════════════
  // GRUPO 2 — LoanEntity: reglas de negocio
  // ═══════════════════════════════════════════════════════
  group('LoanEntity — reglas de negocio', () {

    test('isOverdue: préstamo con dueDate pasado y status active = vencido', () {
      final loan = _loan(
        dueDate: DateTime.now().subtract(const Duration(days: 3)),
        status: 'active',
      );
      expect(loan.isOverdue, isTrue);
    });

    test('isOverdue: préstamo con dueDate futuro NO está vencido', () {
      final loan = _loan(
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: 'active',
      );
      expect(loan.isOverdue, isFalse);
    });

    test('isReturned: returnDate no null → true', () {
      final loan = _loan(returnDate: DateTime(2024, 3, 10), status: 'returned');
      expect(loan.isReturned, isTrue);
    });

    test('isReturned: returnDate null → false', () {
      expect(_loan().isReturned, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════
  // GRUPO 3 — Drift in-memory: BooksDao CRUD
  // ═══════════════════════════════════════════════════════
  group('BooksDao — CRUD con BD en memoria', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() async => await db.close());

    test('INSERT + GET: insertar libro y recuperarlo', () async {
      await db.booksDao.insertBook(BooksCompanion.insert(
        title: 'El Principito',
        author: 'Antoine de Saint-Exupéry',
        year: const Value(1943),
        genre: const Value('Ficción'),
        addedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      final books = await db.booksDao.getAllBooks();
      expect(books.length, equals(1));
      expect(books.first.title, equals('El Principito'));
    });

    test('UPDATE: updateBook cambia el título correctamente', () async {
      await db.booksDao.insertBook(BooksCompanion.insert(
        title: 'Título Original',
        author: 'Autor Test',
        addedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      final book = (await db.booksDao.getAllBooks()).first;
      final updated = await db.booksDao.updateBook(
        book.id,
        BooksCompanion(title: const Value('Título Actualizado')),
      );
      expect(updated, isTrue);
      final after = await db.booksDao.getAllBooks();
      expect(after.first.title, equals('Título Actualizado'));
    });

    test('DELETE: eliminar libro y verificar lista vacía', () async {
      await db.booksDao.insertBook(BooksCompanion.insert(
        title: 'Para eliminar',
        author: 'Autor',
        addedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      final book = (await db.booksDao.getAllBooks()).first;
      await db.booksDao.deleteBook(book.id);
      final books = await db.booksDao.getAllBooks();
      expect(books, isEmpty);
    });

    test('setAvailability: marcar libro como no disponible', () async {
      await db.booksDao.insertBook(BooksCompanion.insert(
        title: 'Disponible',
        author: 'Autor',
        addedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      final book = (await db.booksDao.getAllBooks()).first;
      expect(book.available, isTrue);
      await db.booksDao.setAvailability(book.id, false);
      final updated = await db.booksDao.getAllBooks();
      expect(updated.first.available, isFalse);
    });

    test('watchAvailableBooks: stream solo emite libros disponibles', () async {
      await db.booksDao.insertBook(BooksCompanion.insert(
        title: 'Libro A', author: 'Autor', addedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      await db.booksDao.insertBook(BooksCompanion.insert(
        title: 'Libro B', author: 'Autor',
        available: const Value(false),
        addedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      final available = await db.booksDao.watchAvailableBooks().first;
      expect(available.length, equals(1));
      expect(available.first.title, equals('Libro A'));
    });
  });

  // ═══════════════════════════════════════════════════════
  // GRUPO 4 — Drift in-memory: LoansDao
  // ═══════════════════════════════════════════════════════
  group('LoansDao — préstamos con BD en memoria', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() async => await db.close());

    test('INSERT préstamo y obtener activos', () async {
      await db.booksDao.insertBook(BooksCompanion.insert(
        title: 'Libro Prestado', author: 'Autor',
        addedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      final book = (await db.booksDao.getAllBooks()).first;
      await db.loansDao.insertLoan(LoansCompanion.insert(
        bookId:   book.id,
        borrower: 'Carlos Quispe',
        loanDate: DateTime.now().millisecondsSinceEpoch,
      ));
      final active = await db.loansDao.getActiveLoans();
      expect(active.length, equals(1));
      expect(active.first.borrower, equals('Carlos Quispe'));
    });

    test('returnLoan: status cambia a "returned" y returnDate no es null', () async {
      await db.booksDao.insertBook(BooksCompanion.insert(
        title: 'L', author: 'A', addedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      final book = (await db.booksDao.getAllBooks()).first;
      await db.loansDao.insertLoan(LoansCompanion.insert(
        bookId: book.id, borrower: 'Test',
        loanDate: DateTime.now().millisecondsSinceEpoch,
      ));
      final loan = (await db.loansDao.getActiveLoans()).first;
      await db.loansDao.returnLoan(loan.id);
      final loans = await db.loansDao.watchAllLoans().first;
      expect(loans.first.status, equals('returned'));
      expect(loans.first.returnDate, isNotNull); // ← falla si ERROR 7 no fue corregido
    });
  });

  // ═══════════════════════════════════════════════════════
  // GRUPO 5 — Riverpod: selectedGenreProvider
  // ═══════════════════════════════════════════════════════
  group('selectedGenreProvider — StateProvider', () {
    test('valor inicial es null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(selectedGenreProvider), isNull);
    });

    test('actualizar a "Ficción"', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(selectedGenreProvider.notifier).state = 'Ficción';
      expect(container.read(selectedGenreProvider), equals('Ficción'));
    });

    test('limpiar filtro → null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(selectedGenreProvider.notifier).state = 'Ciencia';
      container.read(selectedGenreProvider.notifier).state = null;
      expect(container.read(selectedGenreProvider), isNull);
    });
  });
}
