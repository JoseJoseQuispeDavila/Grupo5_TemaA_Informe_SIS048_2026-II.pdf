import 'package:equatable/equatable.dart';

class BookEntity extends Equatable {
  final int id;
  final String title;
  final String author;
  final String? isbn;
  final int year;
  final String genre;
  final bool available;
  final DateTime addedAt;

  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    required this.year,
    required this.genre,
    required this.available,
    required this.addedAt,
  });

  bool get isClassic => DateTime.now().year - year > 50;

  String get statusLabel => available ? 'Disponible' : 'Prestado';

  String get yearLabel => 'Año: $year';

  @override
  List<Object?> get props =>
      [id, title, author, isbn, year, genre, available, addedAt];
}

class LoanEntity extends Equatable {
  final int id;
  final int bookId;
  final String borrower;
  final DateTime loanDate;
  final DateTime? dueDate;
  final DateTime? returnDate;
  final String status; // 'active' | 'returned' | 'overdue'

  const LoanEntity({
    required this.id,
    required this.bookId,
    required this.borrower,
    required this.loanDate,
    this.dueDate,
    this.returnDate,
    required this.status,
  });

  bool get isOverdue =>
      status == 'active' &&
      dueDate != null &&
      dueDate!.isBefore(DateTime.now());

  bool get isReturned => returnDate != null;

  @override
  List<Object?> get props =>
      [id, bookId, borrower, loanDate, dueDate, returnDate, status];
}
