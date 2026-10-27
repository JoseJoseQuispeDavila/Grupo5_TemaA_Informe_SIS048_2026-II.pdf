import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/books_controller.dart';

class LoansPage extends ConsumerWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(loansStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EF),
      appBar: AppBar(
        title: const Text('Préstamos Activos'),
        backgroundColor: const Color(0xFF2C4A7C),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const NewLoanDialog(),
        ),
        backgroundColor: const Color(0xFF2C4A7C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Nuevo préstamo'),
      ),
      body: loansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (loans) {
          final active = loans.where((l) => l.status == 'active').toList();
          if (active.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 64, color: Colors.green),
                  SizedBox(height: 12),
                  Text('No hay préstamos activos 🎉'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: active.length,
            itemBuilder: (ctx, i) {
              final loan = active[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        loan.isOverdue ? Colors.red : const Color(0xFF2C4A7C),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(loan.borrower,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Libro #${loan.bookId} · ${loan.isOverdue ? "⚠️ VENCIDO" : "En plazo"}',
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(loansControllerProvider.notifier)
                            .returnBook(loan.id, loan.bookId);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Libro devuelto')),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text('Devolver'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NewLoanDialog extends ConsumerStatefulWidget {
  const NewLoanDialog({super.key});

  @override
  ConsumerState<NewLoanDialog> createState() => _NewLoanDialogState();
}

class _NewLoanDialogState extends ConsumerState<NewLoanDialog> {
  final _borrowerCtrl = TextEditingController();
  int? _bookId;
  bool _loading = false;

  @override
  void dispose() {
    _borrowerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final available = ref.watch(availableBooksProvider).valueOrNull ?? const [];

    return AlertDialog(
      title: const Text('Registrar préstamo'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<int>(
            initialValue: _bookId,
            decoration: const InputDecoration(labelText: 'Libro disponible *'),
            items: available
                .map((b) => DropdownMenuItem(value: b.id, child: Text(b.title)))
                .toList(),
            onChanged: (v) => setState(() => _bookId = v),
          ),
          TextField(
            controller: _borrowerCtrl,
            decoration:
                const InputDecoration(labelText: 'Prestado a (nombre) *'),
          ),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _loading || _bookId == null ? null : _save,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Prestar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await ref.read(loansControllerProvider.notifier).createLoan(
            bookId: _bookId!,
            borrower: _borrowerCtrl.text.trim(),
            dueDate: DateTime.now().add(const Duration(days: 14)),
          );
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
