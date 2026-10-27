import 'package:get_it/get_it.dart';
import '../database/app_database.dart';
import '../../features/books/data/repositories/book_repository_impl.dart';
import '../../features/books/domain/repositories/book_repository.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerSingleton<AppDatabase>(AppDatabase());
  sl.registerSingleton<BooksDao>(sl<AppDatabase>().booksDao);
  sl.registerSingleton<LoansDao>(sl<AppDatabase>().loansDao);

  sl.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(sl<BooksDao>()),
  );
  sl.registerLazySingleton<LoanRepository>(
    () => LoanRepositoryImpl(sl<LoansDao>(), sl<BooksDao>()),
  );
}
