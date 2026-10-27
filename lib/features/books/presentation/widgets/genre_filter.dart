import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/books_controller.dart';

class GenreFilter extends ConsumerWidget {
  const GenreFilter({super.key});

  static const _genres = [
    'Ficción',
    'No Ficción',
    'Ciencia',
    'Historia',
    'Técnico',
    'Otro'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedGenreProvider);
    return Container(
      height: 46,
      color: const Color(0xFFEBF0FA),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        children: [
          _chip('Todos', selected == null,
              () => ref.read(selectedGenreProvider.notifier).state = null, ref),
          ..._genres.map((g) => _chip(g, selected == g,
              () => ref.read(selectedGenreProvider.notifier).state = g, ref)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2C4A7C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2C4A7C)),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF2C4A7C),
              fontSize: 12,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            )),
      ),
    );
  }
}
