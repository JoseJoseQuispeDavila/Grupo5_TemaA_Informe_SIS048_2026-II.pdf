import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/book_entity.dart';

class BookModel extends BookEntity {
  const BookModel({
    required super.id,
    required super.title,
    required super.author,
    super.isbn,
    required super.year,
    required super.genre,
    required super.available,
    required super.addedAt,
  });

  factory BookModel.fromDrift(Book row) => BookModel(
        id: row.id,
        title: row.title,
        author: row.author,
        isbn: row.isbn,
        year: row.year,
        genre: row.genre,
        available: row.available,
        addedAt: DateTime.fromMillisecondsSinceEpoch(row.addedAt),
      );

  BooksCompanion toDriftCompanion() => BooksCompanion.insert(
        title: title,
        author: author,
        isbn: Value(isbn),
        year: Value(year),
        genre: Value(genre),
        available: Value(available),
        addedAt: addedAt.millisecondsSinceEpoch,
      );
}

class LoanModel extends LoanEntity {
  const LoanModel({
    required super.id,
    required super.bookId,
    required super.borrower,
    required super.loanDate,
    super.dueDate,
    super.returnDate,
    required super.status,
  });

  factory LoanModel.fromDrift(Loan row) => LoanModel(
        id: row.id,
        bookId: row.bookId,
        borrower: row.borrower,
        loanDate: DateTime.fromMillisecondsSinceEpoch(row.loanDate),
        dueDate: row.dueDate != null
            ? DateTime.fromMillisecondsSinceEpoch(row.dueDate!)
            : null,
        returnDate: row.returnDate != null
            ? DateTime.fromMillisecondsSinceEpoch(row.returnDate!)
            : null,
        status: row.status,
      );

  LoansCompanion toDriftCompanion() => LoansCompanion.insert(
        bookId: bookId,
        borrower: borrower,
        loanDate: loanDate.millisecondsSinceEpoch,
        dueDate: Value(dueDate?.millisecondsSinceEpoch),
        returnDate: Value(returnDate?.millisecondsSinceEpoch),
        status: Value(status),
      );
}
