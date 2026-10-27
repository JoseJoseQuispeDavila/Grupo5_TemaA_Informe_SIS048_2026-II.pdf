import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/book_entity.dart';

abstract class BookRepository {
  Stream<List<BookEntity>> watchAllBooks();
  Stream<List<BookEntity>> watchAvailableBooks();
  Future<Either<Failure, List<BookEntity>>> getByGenre(String genre);
  Future<Either<Failure, BookEntity>> addBook({
    required String title,
    required String author,
    String? isbn,
    required int year,
    required String genre,
  });
  Future<Either<Failure, void>> updateBook(
    int id, {
    String? title,
    String? author,
    String? isbn,
    int? year,
    String? genre,
  });
  Future<Either<Failure, void>> deleteBook(int id);
}

abstract class LoanRepository {
  Stream<List<LoanEntity>> watchAllLoans();
  Future<Either<Failure, List<LoanEntity>>> getActiveLoans();
  Future<Either<Failure, LoanEntity>> createLoan({
    required int bookId,
    required String borrower,
    DateTime? dueDate,
  });
  Future<Either<Failure, void>> returnBook(int loanId, int bookId);
}
