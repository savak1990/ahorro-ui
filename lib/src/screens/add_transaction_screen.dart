import 'package:ahorro_ui/src/models/transaction_type.dart';
import 'package:ahorro_ui/src/services/api_service.dart';
import 'package:ahorro_ui/src/widgets/category_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/balances_provider.dart';
import '../models/transaction_entry.dart';
import '../models/category.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _selectedType = TransactionType.expense;
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Accounts
  String? _fromAccountId;
  String? _toAccountId;

  // Dynamic items
  List<_TransactionItem> _items = [
    _TransactionItem(),
  ];

  final TextEditingController _movementAmountController = TextEditingController();

  double get _totalAmount => _items.fold(0.0, (sum, item) {
    final value = double.tryParse(item.amountController.text);
    return sum + (value ?? 0.0);
  });

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    _descriptionController.dispose();
    _movementAmountController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(_TransactionItem());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectCategory(BuildContext context, _TransactionItem item) async {
    final result = await Navigator.push<Category>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CategoryPickerDialog(
          selectedCategoryId: item.selectedCategoryId,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
        opaque: false,
        barrierColor: Colors.transparent,
      ),
    );

    if (result != null) {
      debugPrint('AddTransactionScreen: Selected category: ${result.name} (id: ${result.id})');
      setState(() {
        item.selectedCategoryId = result.id;
        item.categoryController.text = result.name;
      });
    }
  }

  Future<void> _saveTransaction() async {
    debugPrint('[_saveTransaction] Start');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving transaction...'), duration: Duration(seconds: 1)),
    );
    if (_selectedType == TransactionType.movement) {
      if (_fromAccountId == null || _toAccountId == null) {
        debugPrint('[_saveTransaction] Accounts for movement are not selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both accounts for movement')),);
        return;
      }
      if (_movementAmountController.text.isEmpty) {
        debugPrint('[_saveTransaction] Movement amount is empty');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the amount')),);
        return;
      }
      final amount = double.tryParse(_movementAmountController.text) ?? 0.0;
      if (amount <= 0.0) {
        debugPrint('[_saveTransaction] Movement amount is zero or invalid');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid amount')),);
        return;
      }
    } else {
      if (_selectedType == TransactionType.expense && _fromAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an account')));
        return;
      }
      if (_selectedType == TransactionType.income && _toAccountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an account')));
        return;
      }
      if (_items.isEmpty || _totalAmount == 0) {
        debugPrint('[_saveTransaction] No items or total amount is zero');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item with amount')),);
        return;
      }
      bool hasAmountError = false;
      for (final item in _items) {
        final amount = double.tryParse(item.amountController.text);
        if (amount == null || amount <= 0) {
          hasAmountError = true;
          break;
        }
      }
      if (hasAmountError) {
        debugPrint('[_saveTransaction] Invalid or empty amount in one of the items');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fill valid amount for each item')),);
        setState(() {});
        return;
      }
    }

    setState(() { _isLoading = true; });
    debugPrint('[_saveTransaction] Validation passed, sending request...');
    try {
      if (_selectedType == TransactionType.movement) {
        debugPrint('[_saveTransaction] Posting movement transaction');
        await ApiService.postTransaction(
          type: _selectedType,
          amount: double.parse(_movementAmountController.text),
          date: _selectedDate,
          categoryId: '',
          description: 'Transfer from ${_fromAccountId!} to ${_toAccountId!}',
          merchant: 'Transfer',
          balanceId: _fromAccountId!,
        );
      } else {
        final transactionEntries = _items.where((item) {
          return item.amountController.text.isNotEmpty && double.tryParse(item.amountController.text) != null;
        }).map((item) {
          double parsedAmount = 0.0;
          try {
            parsedAmount = double.parse(item.amountController.text);
          } catch (e) {
            debugPrint('[_saveTransaction] ERROR: failed to parse amount for item: ${item.amountController.text}, error: ${e.toString()}');
            parsedAmount = 0.0;
          }
          return TransactionEntry(
            description: item.nameController.text,
            amount: parsedAmount,
            categoryId: item.selectedCategoryId.isNotEmpty 
                ? item.selectedCategoryId 
                : 'c47ac10b-58cc-4372-a567-0e02b2c3d479',
          );
        }).toList();
        if (transactionEntries.isEmpty) {
          debugPrint('[_saveTransaction] No valid transaction entries after filtering');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No valid items to save')),);
          setState(() { _isLoading = false; });
          return;
        }
        String merchant = _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : (_items.isNotEmpty ? _items.first.nameController.text : 'Unknown');
        debugPrint('[_saveTransaction] Posting income/expense transaction, entries: ${transactionEntries.length}');
        await ApiService.postTransaction(
          type: _selectedType,
          amount: _totalAmount,
          date: _selectedDate,
          categoryId: _items.isNotEmpty && _items.first.selectedCategoryId.isNotEmpty 
              ? _items.first.selectedCategoryId 
              : '',
          description: _descriptionController.text,
          merchant: merchant,
          transactionEntriesParam: transactionEntries,
          balanceId: _selectedType == TransactionType.expense ? _fromAccountId! : _toAccountId!,
        );
      }

      if (mounted) {
        debugPrint('[_saveTransaction] Transaction saved successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction saved successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('[_saveTransaction] Error: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
      debugPrint('[_saveTransaction] Finished');
    }
  }

  Widget _buildAccountSelector({
    required String title,
    required String? selectedAccountId,
    required ValueChanged<String?> onAccountSelected,
    String? excludeAccountId,
  }) {
    final balancesProvider = Provider.of<BalancesProvider>(context);
    final balances = balancesProvider.balances;
    final isLoading = balancesProvider.isLoading;
    final error = balancesProvider.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (isLoading)
          const CircularProgressIndicator()
        else if (error != null)
          Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text('Ошибка загрузки балансов')),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: balancesProvider.loadBalances,
              ),
            ],
          )
        else if (balances.isEmpty)
          const Text('Нет доступных счетов')
        else
          Wrap(
            spacing: 8.0,
            children: balances
                .where((b) => excludeAccountId == null || b.balanceId != excludeAccountId)
                .map((balance) {
              return ChoiceChip(
                label: Text(balance.title),
                selected: selectedAccountId == balance.balanceId,
                onSelected: (selected) {
                  onAccountSelected(selected ? balance.balanceId : null);
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Swipe indicator
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('New transaction', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 32),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment<TransactionType>(value: TransactionType.income, label: Text('Income'), icon: Icon(Icons.arrow_upward)),
                    ButtonSegment<TransactionType>(value: TransactionType.expense, label: Text('Expense'), icon: Icon(Icons.arrow_downward)),
                    ButtonSegment<TransactionType>(value: TransactionType.movement, label: Text('Movement'), icon: Icon(Icons.swap_horiz)),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (Set<TransactionType> selected) {
                    setState(() {
                      _selectedType = selected.first;
                      _fromAccountId = null;
                      _toAccountId = null;
                      _items = [_TransactionItem()];
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Account fields / Items
                  if (_selectedType == TransactionType.movement) ...[
                    _buildAccountSelector(
                      title: 'From Account',
                      selectedAccountId: _fromAccountId,
                      onAccountSelected: (id) => setState(() => _fromAccountId = id),
                      excludeAccountId: _selectedType == TransactionType.movement ? _toAccountId : null,
                    ),
                    const SizedBox(height: 16),
                    _buildAccountSelector(
                      title: 'To Account',
                      selectedAccountId: _toAccountId,
                      onAccountSelected: (id) => setState(() => _toAccountId = id),
                    ),
                    const SizedBox(height: 24),
                    // Amount field for transfer
                    TextField(
                      controller: _movementAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ] else ...[
                    if (_selectedType == TransactionType.income)
                      _buildAccountSelector(
                        title: 'To Account',
                        selectedAccountId: _toAccountId,
                        onAccountSelected: (id) => setState(() => _toAccountId = id),
                      )
                    else // Expense
                      _buildAccountSelector(
                        title: 'From Account',
                        selectedAccountId: _fromAccountId,
                        onAccountSelected: (id) => setState(() => _fromAccountId = id),
                      ),
                    const SizedBox(height: 24),
                    // Items section and total amount only for income/expense
                    Text('Items', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      itemBuilder: (context, i) {
                        final item = _items[i];
                        final amountValue = double.tryParse(item.amountController.text);
                        final hasError = item.amountController.text.isNotEmpty && (amountValue == null || amountValue <= 0);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Категория
                                InkWell(
                                  onTap: () => _selectCategory(context, item),
                                  borderRadius: BorderRadius.circular(20),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: item.selectedCategoryId.isEmpty
                                        ? Colors.grey[200]
                                        : Theme.of(context).colorScheme.primary.withOpacity(0.15),
                                    child: Icon(
                                      getCategoryIcon(item.categoryController.text),
                                      color: item.selectedCategoryId.isEmpty
                                          ? Colors.grey
                                          : Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Название
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: item.nameController,
                                    decoration: const InputDecoration(
                                      hintText: 'Description',
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Сумма
                                SizedBox(
                                  width: 90,
                                  child: TextField(
                                    controller: item.amountController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      hintText: '0.00',
                                      isDense: true,
                                      border: const OutlineInputBorder(),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                      labelStyle: TextStyle(color: hasError ? Theme.of(context).colorScheme.error : null),
                                    ),
                                  ),
                                ),
                                // Кнопка удаления
                                if (_items.length > 1)
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade300),
                                    onPressed: () => _removeItem(i),
                                    tooltip: 'Удалить',
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add item'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _totalAmount.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _selectedType == TransactionType.income ? Colors.green.shade700 : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Common fields
                  const SizedBox(height: 24),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: _selectedType == TransactionType.movement ? 'Description (optional)' : 'Merchant / Store (optional)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Date selection
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text('${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _isLoading ? null : _saveTransaction,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  String selectedCategoryId = '';

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    categoryController.dispose();
  }
} 