import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../src/constants/app_colors.dart';
import '../models/balance.dart';
import '../providers/balances_provider.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class BalancesScreen extends StatelessWidget {
  const BalancesScreen({super.key});

  void _showAddBalanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return _AddBalanceForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BalancesProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Balances',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddBalanceSheet(context),
                tooltip: 'Add balance',
              ),
            ],
          ),
          backgroundColor: AppColors.background,
          body: () {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(child: Text('Error: ${provider.error}'));
            }
            if (provider.balances.isEmpty) {
              return Center(
                child: Text(
                  'You have no balances yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.balances.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final Balance balance = provider.balances[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.account_balance_wallet, color: AppColors.primary),
                    title: Text(balance.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(balance.currency, style: Theme.of(context).textTheme.bodyMedium),
                    onTap: () {
                      // TODO: переход к деталям баланса
                    },
                  ),
                );
              },
            );
          }(),
        );
      },
    );
  }
}

// --- Форма создания баланса ---
class _AddBalanceForm extends StatefulWidget {
  @override
  State<_AddBalanceForm> createState() => _AddBalanceFormState();
}

class _AddBalanceFormState extends State<_AddBalanceForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCurrency = 'EUR';
  bool _isSubmitting = false;
  String? _submitError;

  static const _currencies = ['USD', 'EUR', 'UAH', 'BYN'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    try {
      final provider = Provider.of<BalancesProvider>(context, listen: false);
      // Получаем userId и groupId через Amplify
      final session = await Amplify.Auth.fetchAuthSession();
      final currentUser = await Amplify.Auth.getCurrentUser();
      final userId = currentUser.userId;
      // groupId можно захардкодить как в примере
      const groupId = '6a785a55-fced-4f13-af78-5c19a39c9abc';
      await provider.createBalance(
        userId: userId,
        groupId: groupId,
        currency: _selectedCurrency,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _submitError = e.toString();
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add Balance', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Currency', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _currencies.map((currency) {
                final selected = _selectedCurrency == currency;
                return ChoiceChip(
                  label: Text(currency),
                  selected: selected,
                  onSelected: (v) {
                    setState(() => _selectedCurrency = currency);
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.surface : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: AppColors.surface,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Balance name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            if (_submitError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_submitError!, style: TextStyle(color: AppColors.error)),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Create'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
} 