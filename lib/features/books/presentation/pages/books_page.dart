import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/books_controller.dart';
import '../widgets/book_card.dart';
import '../widgets/genre_filter.dart';
import '../widgets/add_book_dialog.dart';

class BooksPage extends ConsumerWidget {
  const BooksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(filteredBooksProvider);
    final availableCount = ref.watch(availableCountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EF),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BiblioTrack 📚',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('$availableCount disponibles',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: const Color(0xFF2C4A7C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Préstamos activos',
            onPressed: () => context.push('/loans'),
          ),
        ],
      ),
      body: Column(
        children: [
          const GenreFilter(),
          Expanded(
            child: booksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text('Error: $e'),
                    TextButton(
                      onPressed: () =>
                          ref.read(booksControllerProvider.notifier).refresh(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (books) {
                if (books.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                            'No hay libros aún.\nAgrega el primero con el botón +',
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: books.length,
                  itemBuilder: (ctx, i) => BookCard(book: books[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AddBookDialog(),
        ),
        backgroundColor: const Color(0xFF2C4A7C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Agregar libro'),
      ),
    );
  }
}
