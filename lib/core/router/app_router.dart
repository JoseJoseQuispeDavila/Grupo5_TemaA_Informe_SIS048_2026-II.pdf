import 'package:go_router/go_router.dart';
import '../../features/books/presentation/pages/books_page.dart';
import '../../features/books/presentation/pages/loans_page.dart';

final appRouter = GoRouter(
  initialLocation: '/books',
  routes: [
    GoRoute(
        path: '/books', name: 'books', builder: (_, __) => const BooksPage()),
    GoRoute(
        path: '/loans', name: 'loans', builder: (_, __) => const LoansPage()),
  ],
);
