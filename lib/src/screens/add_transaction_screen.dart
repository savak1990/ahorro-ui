import 'package:ahorro_ui/src/models/transaction_type.dart';
import 'package:ahorro_ui/src/services/api_service.dart';
import 'package:ahorro_ui/src/widgets/category_picker_dialog.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController _accountFromController = TextEditingController();
  final TextEditingController _accountToController = TextEditingController();

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
    _accountFromController.dispose();
    _accountToController.dispose();
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
    final result = await showDialog<CategoryData>(
      context: context,
      builder: (context) => CategoryPickerDialog(
        selectedCategoryId: item.selectedCategoryId,
      ),
    );

    if (result != null) {
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
      if (_movementAmountController.text.isEmpty) {
        debugPrint('[_saveTransaction] Movement amount is empty');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the amount')),);
        return;
      }
      final amount = double.tryParse(_movementAmountController.text) ?? 0.0;
      if (amount == 0.0) {
        debugPrint('[_saveTransaction] Movement amount is zero or invalid');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid amount')),);
        return;
      }
    } else {
      if (_items.isEmpty || _totalAmount == 0) {
        debugPrint('[_saveTransaction] No items or total amount is zero');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item with amount')),);
        return;
      }
      bool hasAmountError = false;
      for (final item in _items) {
        if (item.amountController.text.isEmpty || double.tryParse(item.amountController.text) == null) {
          hasAmountError = true;
        }
      }
      if (hasAmountError) {
        debugPrint('[_saveTransaction] Invalid or empty amount in one of the items');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fill valid amount for each item')),);
        setState(() {}); // Чтобы обновить подсветку
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
          category: 'Transfer',
          description: 'Transfer from \\${_accountFromController.text.isEmpty ? 'Unknown' : _accountFromController.text} to \\${_accountToController.text.isEmpty ? 'Unknown' : _accountToController.text}',
          merchant: 'Transfer',
        );
      } else {
        final transactionEntries = _items.where((item) {
          // Только если amount валиден
          return item.amountController.text.isNotEmpty && double.tryParse(item.amountController.text) != null;
        }).map((item) {
          double parsedAmount = 0.0;
          try {
            parsedAmount = double.parse(item.amountController.text);
          } catch (e) {
            debugPrint('[_saveTransaction] ERROR: failed to parse amount for item: \\${item.amountController.text}, error: \\${e.toString()}');
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
        debugPrint('[_saveTransaction] Posting income/expense transaction, entries: \\${transactionEntries.length}');
        await ApiService.postTransaction(
          type: _selectedType,
          amount: _totalAmount,
          date: _selectedDate,
          category: _items.isNotEmpty && _items.first.categoryController.text.isNotEmpty 
              ? _items.first.categoryController.text 
              : 'Uncategorized',
          description: _descriptionController.text,
          merchant: merchant,
          transactionEntriesParam: transactionEntries,
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
      debugPrint('[_saveTransaction] Error: \\${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \\${e.toString()}'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
      debugPrint('[_saveTransaction] Finished');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Swipe indicator
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
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
                setState(() { _selectedType = selected.first; });
              },
            ),
            const SizedBox(height: 24),
            // Account field
            if (_selectedType == TransactionType.movement) ...[
              TextField(
                controller: _accountFromController,
                decoration: const InputDecoration(
                  labelText: 'From account',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _accountToController,
                decoration: const InputDecoration(
                  labelText: 'To account',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              // Amount field for transfer
              TextField(
                controller: _movementAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              TextField(
                controller: _accountFromController,
                decoration: InputDecoration(
                  labelText: _selectedType == TransactionType.income ? 'To account' : 'From account',
                  border: const OutlineInputBorder(),
                ),
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
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Первая строка: Name и Amount
                            Row(
                              children: [
                                // Name (60% ширины)
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: item.nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Amount (40% ширины)
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    controller: item.amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Amount',
                                      border: const OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                      labelStyle: TextStyle(
                                        color: (item.amountController.text.isEmpty || double.tryParse(item.amountController.text) == null)
                                            ? Colors.red
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Вторая строка: Category и кнопка удаления
                            Row(
                              children: [
                                // Category как иконка + название
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () => _selectCategory(context, item),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: item.selectedCategoryId.isNotEmpty
                                                ? Icon(
                                                    getCategoryIcon(item.categoryController.text),
                                                    size: 14,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  )
                                                : const Icon(Icons.category, size: 14, color: Colors.grey),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              item.categoryController.text.isEmpty
                                                  ? 'Select category'
                                                  : item.categoryController.text,
                                              style: TextStyle(
                                                color: item.categoryController.text.isEmpty
                                                    ? Colors.grey[600]
                                                    : null,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Кнопка удаления
                                if (_items.length > 1)
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, color: Colors.grey[500], size: 20),
                                    onPressed: () => _removeItem(i),
                                    tooltip: 'Delete',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Тонкая линия между items
                      if (i < _items.length - 1)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey[300],
                        ),
                    ],
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
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _totalAmount == 0 ? '0' : _totalAmount.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            // Description input field
            if (_selectedType == TransactionType.movement)
              ...[
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
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
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _saveTransaction,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
            const SizedBox(height: 16),
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

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    categoryController.dispose();
  }
} 