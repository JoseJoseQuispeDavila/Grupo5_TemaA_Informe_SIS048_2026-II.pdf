import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../../../../core/di/injection_container.dart';

// null representa todos los géneros.
final selectedGenreProvider = StateProvider<String?>((ref) => null);

final booksStreamProvider = StreamProvider<List<BookEntity>>((ref) {
  return sl<BookRepository>().watchAllBooks();
});

final filteredBooksProvider = Provider<AsyncValue<List<BookEntity>>>((ref) {
  final books = ref.watch(booksStreamProvider);
  final genre = ref.watch(selectedGenreProvider);
  // whenData mantiene los estados de carga y error del stream original.
  return books.whenData((list) => genre == null
      ? list
      : list.where((book) => book.genre == genre).toList());
});

final availableBooksProvider = StreamProvider<List<BookEntity>>((ref) {
  return sl<BookRepository>().watchAvailableBooks();
});

final availableCountProvider = Provider<int>((ref) {
  return ref.watch(availableBooksProvider).valueOrNull?.length ?? 0;
});

class BooksController extends AsyncNotifier<List<BookEntity>> {
  @override
  Future<List<BookEntity>> build() async {
    return await sl<BookRepository>().watchAllBooks().first;
  }

  Future<void> addBook({
    required String title,
    required String author,
    String? isbn,
    required int year,
    required String genre,
  }) async {
    final result = await sl<BookRepository>().addBook(
      title: title,
      author: author,
      isbn: isbn,
      year: year,
      genre: genre,
    );
    await result.fold<Future<void>>(
      (failure) async => throw Exception(failure.message),
      (_) async {
        state =
            AsyncValue.data(await sl<BookRepository>().watchAllBooks().first);
      },
    );
  }

  Future<void> deleteBook(int id) async {
    final result = await sl<BookRepository>().deleteBook(id);
    await result.fold<Future<void>>(
      (failure) async => throw Exception(failure.message),
      (_) async {
        state =
            AsyncValue.data(await sl<BookRepository>().watchAllBooks().first);
      },
    );
  }

  Future<void> refresh() async {
    ref.invalidate(booksStreamProvider);
    ref.invalidate(availableBooksProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => sl<BookRepository>().watchAllBooks().first,
    );
  }
}

final booksControllerProvider =
    AsyncNotifierProvider<BooksController, List<BookEntity>>(
        BooksController.new);

final loansStreamProvider = StreamProvider<List<LoanEntity>>((ref) {
  return sl<LoanRepository>().watchAllLoans();
});

class LoansController extends AsyncNotifier<List<LoanEntity>> {
  @override
  Future<List<LoanEntity>> build() async {
    return await sl<LoanRepository>().watchAllLoans().first;
  }

  Future<void> createLoan({
    required int bookId,
    required String borrower,
    DateTime? dueDate,
  }) async {
    final result = await sl<LoanRepository>().createLoan(
      bookId: bookId,
      borrower: borrower,
      dueDate: dueDate,
    );
    await result.fold<Future<void>>(
      (failure) async => throw Exception(failure.message),
      (_) async {
        state =
            AsyncValue.data(await sl<LoanRepository>().watchAllLoans().first);
      },
    );
  }

  Future<void> returnBook(int loanId, int bookId) async {
    final result = await sl<LoanRepository>().returnBook(loanId, bookId);
    await result.fold<Future<void>>(
      (failure) async => throw Exception(failure.message),
      (_) async {
        state =
            AsyncValue.data(await sl<LoanRepository>().watchAllLoans().first);
      },
    );
  }
}

final loansControllerProvider =
    AsyncNotifierProvider<LoansController, List<LoanEntity>>(
        LoansController.new);
