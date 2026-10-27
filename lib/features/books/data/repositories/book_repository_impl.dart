import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../models/book_model.dart';

class BookRepositoryImpl implements BookRepository {
  final BooksDao _booksDao;
  BookRepositoryImpl(this._booksDao);

  @override
  Stream<List<BookEntity>> watchAllBooks() => _booksDao
      .watchAllBooks()
      .map((rows) => rows.map(BookModel.fromDrift).toList());

  @override
  Stream<List<BookEntity>> watchAvailableBooks() => _booksDao
      .watchAvailableBooks()
      .map((rows) => rows.map(BookModel.fromDrift).toList());

  @override
  Future<Either<Failure, List<BookEntity>>> getByGenre(String genre) async {
    try {
      final rows = await _booksDao.getByGenre(genre);
      return Right(rows.map(BookModel.fromDrift).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookEntity>> addBook({
    required String title,
    required String author,
    String? isbn,
    required int year,
    required String genre,
  }) async {
    if (title.trim().isEmpty || author.trim().isEmpty) {
      return const Left(ValidationFailure('Título y autor son obligatorios'));
    }
    if (title.trim().length > 200) {
      return const Left(
          ValidationFailure('El título admite hasta 200 caracteres'));
    }
    try {
      final id = await _booksDao.insertBook(BooksCompanion.insert(
        title: title.trim(),
        author: author.trim(),
        isbn: Value(isbn?.trim()),
        year: Value(year),
        genre: Value(genre.trim()),
        addedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      final row = await _booksDao.getBook(id);
      if (row == null)
        return const Left(NotFoundFailure('Libro no encontrado'));
      return Right(BookModel.fromDrift(row));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBook(
    int id, {
    String? title,
    String? author,
    String? isbn,
    int? year,
    String? genre,
  }) async {
    if ((title != null && title.trim().isEmpty) ||
        (author != null && author.trim().isEmpty)) {
      return const Left(ValidationFailure('Título y autor son obligatorios'));
    }
    if (title != null && title.trim().length > 200) {
      return const Left(
          ValidationFailure('El título admite hasta 200 caracteres'));
    }
    try {
      final updated = await _booksDao.updateBook(
          id,
          BooksCompanion(
            title: title == null ? const Value.absent() : Value(title.trim()),
            author:
                author == null ? const Value.absent() : Value(author.trim()),
            isbn: isbn == null ? const Value.absent() : Value(isbn.trim()),
            year: year == null ? const Value.absent() : Value(year),
            genre: genre == null ? const Value.absent() : Value(genre.trim()),
          ));
      if (!updated) return const Left(NotFoundFailure('Libro no encontrado'));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBook(int id) async {
    try {
      final deleted = await _booksDao.deleteBook(id);
      if (deleted == 0)
        return const Left(NotFoundFailure('Libro no encontrado'));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

class LoanRepositoryImpl implements LoanRepository {
  final LoansDao _loansDao;
  final BooksDao _booksDao;
  LoanRepositoryImpl(this._loansDao, this._booksDao);

  @override
  Stream<List<LoanEntity>> watchAllLoans() => _loansDao
      .watchAllLoans()
      .map((rows) => rows.map(LoanModel.fromDrift).toList());

  @override
  Future<Either<Failure, List<LoanEntity>>> getActiveLoans() async {
    try {
      final rows = await _loansDao.getActiveLoans();
      return Right(rows.map(LoanModel.fromDrift).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoanEntity>> createLoan({
    required int bookId,
    required String borrower,
    DateTime? dueDate,
  }) async {
    if (borrower.trim().isEmpty) {
      return const Left(ValidationFailure('El prestatario es obligatorio'));
    }
    try {
      // La inserción y el cambio de disponibilidad se confirman juntos.
      return await _booksDao.attachedDatabase
          .transaction<Either<Failure, LoanEntity>>(() async {
        final book = await _booksDao.getBook(bookId);
        if (book == null)
          return const Left(NotFoundFailure('Libro no encontrado'));
        if (!book.available) {
          return const Left(ValidationFailure('El libro ya está prestado'));
        }
        final id = await _loansDao.insertLoan(LoansCompanion.insert(
          bookId: bookId,
          borrower: borrower.trim(),
          loanDate: DateTime.now().millisecondsSinceEpoch,
          dueDate: Value(dueDate?.millisecondsSinceEpoch),
        ));
        await _booksDao.setAvailability(bookId, false);
        final loan = await _loansDao.getLoan(id);
        if (loan == null) throw StateError('No se pudo recuperar el préstamo');
        return Right(LoanModel.fromDrift(loan));
      });
    } catch (e) {
      // La excepción sale de transaction para provocar rollback.
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> returnBook(int loanId, int bookId) async {
    try {
      return await _booksDao.attachedDatabase
          .transaction<Either<Failure, void>>(() async {
        final loan = await _loansDao.getLoan(loanId);
        if (loan == null) {
          return const Left(NotFoundFailure('Préstamo no encontrado'));
        }
        if (loan.bookId != bookId) {
          return const Left(
              ValidationFailure('El préstamo no corresponde al libro'));
        }
        if (loan.status == 'returned' || loan.returnDate != null) {
          return const Left(ValidationFailure('El préstamo ya fue devuelto'));
        }
        await _loansDao.returnLoan(loanId);
        await _booksDao.setAvailability(bookId, true);
        return const Right(null);
      });
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
