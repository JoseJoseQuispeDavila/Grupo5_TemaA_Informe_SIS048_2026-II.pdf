import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/books_controller.dart';

class AddBookDialog extends ConsumerStatefulWidget {
  const AddBookDialog({super.key});
  @override
  ConsumerState<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends ConsumerState<AddBookDialog> {
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  String _genre = 'Ficción';
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar libro'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Título *')),
          TextField(
              controller: _authorCtrl,
              decoration: const InputDecoration(labelText: 'Autor *')),
          TextField(
              controller: _yearCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Año')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _genre,
            items: [
              'Ficción',
              'No Ficción',
              'Ciencia',
              'Historia',
              'Técnico',
              'Otro'
            ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (v) => setState(() => _genre = v!),
            decoration: const InputDecoration(labelText: 'Género'),
          ),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () async {
                  setState(() => _loading = true);
                  try {
                    await ref.read(booksControllerProvider.notifier).addBook(
                          title: _titleCtrl.text.trim(),
                          author: _authorCtrl.text.trim(),
                          year: int.tryParse(_yearCtrl.text) ??
                              DateTime.now().year,
                          genre: _genre,
                        );
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Agregar'),
        ),
      ],
    );
  }
}
