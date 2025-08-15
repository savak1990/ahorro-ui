import 'package:ahorro_ui/src/models/transaction_type.dart';
import 'package:ahorro_ui/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../constants/app_typography.dart';
import '../models/category.dart';
import '../providers/transaction_entries_provider.dart';
import '../widgets/expense_transaction_form.dart';
import '../widgets/income_transaction_form.dart';
import '../widgets/movement_transaction_form.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _selectedType = TransactionType.expense;
  final ValueNotifier<FormzSubmissionStatus> _formStatus = ValueNotifier(
    FormzSubmissionStatus.initial,
  );
  bool _isLoading = false;
  final GlobalKey<ExpenseTransactionFormState> _formKey =
      GlobalKey<ExpenseTransactionFormState>();
  final GlobalKey<IncomeTransactionFormState> _incomeFormKey =
      GlobalKey<IncomeTransactionFormState>();
  final GlobalKey<MovementTransactionFormState> _movementFormKey =
      GlobalKey<MovementTransactionFormState>();

  // callback для сабмита с данными
  void _onSubmit(ExpenseTransactionFormData data) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final provider = Provider.of<TransactionEntriesProvider>(
        context,
        listen: false,
      );
      await provider.createTransaction(
        type: TransactionType.expense,
        amount: null,
        date: data.date,
        categoryId: '',
        description: '',
        transactionEntriesParam: data.entries,
        balanceId: data.balanceId,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final success = Theme.of(context).extension<SuccessColors>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaction saved!'),
            backgroundColor: success?.successContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _onIncomeSubmit(IncomeTransactionFormData data) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final provider = Provider.of<TransactionEntriesProvider>(
        context,
        listen: false,
      );
      await provider.createTransaction(
        type: TransactionType.income,
        amount: null,
        date: data.date,
        categoryId: '',
        description: '',
        transactionEntriesParam: data.entries,
        balanceId: data.balanceId,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final success = Theme.of(context).extension<SuccessColors>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaction saved!'),
            backgroundColor: success?.successContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _onMovementSubmit(MovementTransactionFormData data) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await ApiService.postMovementTransaction(
        fromBalanceId: data.fromBalanceId,
        toBalanceId: data.toBalanceId,
        amount: data.amount,
        convertedAmount: data.convertedAmount,
        date: data.date,
        description: 'Transfer between accounts',
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final success = Theme.of(context).extension<SuccessColors>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transfer saved!'),
            backgroundColor: success?.successContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          minHeight: 400, // Минимальная высота для комфортного использования
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ValueListenableBuilder<FormzSubmissionStatus>(
                    valueListenable: _formStatus,
                    builder: (context, status, _) {
                      return FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(40, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed:
                            _isLoading ||
                                status != FormzSubmissionStatus.success
                            ? null
                            : () {
                                if (_selectedType == TransactionType.expense) {
                                  _formKey.currentState?.submit();
                                } else if (_selectedType ==
                                    TransactionType.income) {
                                  _incomeFormKey.currentState?.submit();
                                } else if (_selectedType ==
                                    TransactionType.movement) {
                                  _movementFormKey.currentState?.submit();
                                }
                              },
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save'),
                      );
                    },
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        'New transaction',
                        style: AppTypography.headlineLarge,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SegmentedButton<TransactionType>(
                        segments: const [
                          ButtonSegment<TransactionType>(
                            value: TransactionType.income,
                            label: Text('Income'),
                            icon: Icon(Icons.arrow_upward),
                          ),
                          ButtonSegment<TransactionType>(
                            value: TransactionType.expense,
                            label: Text('Expense'),
                            icon: Icon(Icons.arrow_downward),
                          ),
                          ButtonSegment<TransactionType>(
                            value: TransactionType.movement,
                            label: Text('Movement'),
                            icon: Icon(Icons.swap_horiz),
                          ),
                        ],
                        selected: {_selectedType},
                        onSelectionChanged: (Set<TransactionType> selected) {
                          setState(() {
                            _selectedType = selected.first;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_selectedType == TransactionType.expense)
                      ExpenseTransactionForm(
                        key: _formKey,
                        formStatus: _formStatus,
                        onSubmit: _onSubmit,
                        isLoading: _isLoading,
                      )
                    else if (_selectedType == TransactionType.income)
                      IncomeTransactionForm(
                        key: _incomeFormKey,
                        formStatus: _formStatus,
                        onSubmit: _onIncomeSubmit,
                        isLoading: _isLoading,
                      )
                    else
                      MovementTransactionForm(
                        key: _movementFormKey,
                        formStatus: _formStatus,
                        onSubmit: _onMovementSubmit,
                        isLoading: _isLoading,
                      ),
                    const SizedBox(height: 24), // Отступ снизу
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  String selectedCategoryId = '';
  String defaultCategoryId = '';
  String defaultCategoryName = '';
  IconData? categoryIcon;

  _TransactionItem({Category? defaultCategory}) {
    if (defaultCategory != null) {
      defaultCategoryId = defaultCategory.id;
      defaultCategoryName = defaultCategory.name;
      selectedCategoryId = defaultCategory.id;
      categoryController.text = defaultCategory.name;
      categoryIcon = defaultCategory.iconData;
    }
  }

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    categoryController.dispose();
  }
}
