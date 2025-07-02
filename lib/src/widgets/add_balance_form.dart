import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/balances_provider.dart';
import '../services/auth_service.dart';

class AddBalanceForm extends StatefulWidget {
  @override
  State<AddBalanceForm> createState() => _AddBalanceFormState();
}

class _AddBalanceFormState extends State<AddBalanceForm> {
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
      // Get userId and groupId from AuthService
      final userId = await AuthService.getUserId();
      final groupId = AuthService.groupId;
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
            Text(AppStrings.addBalanceTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(AppStrings.currencyLabel, style: Theme.of(context).textTheme.bodyMedium),
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
                labelText: AppStrings.balanceNameLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.titleRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppStrings.descriptionLabel,
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
                    : Text(AppStrings.createButton),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
} 