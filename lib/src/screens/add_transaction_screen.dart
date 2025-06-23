import 'package:ahorro_ui/src/models/transaction_type.dart';
import 'package:ahorro_ui/src/services/api_service.dart';
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

  // Счета
  final TextEditingController _accountFromController = TextEditingController();
  final TextEditingController _accountToController = TextEditingController();

  // Динамические позиции
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

  Future<void> _saveTransaction() async {
    double amount = 0.0;
    String category = '';
    if (_selectedType == TransactionType.movement) {
      if (_movementAmountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the amount')),);
        return;
      }
      amount = double.tryParse(_movementAmountController.text) ?? 0.0;
      if (amount == 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid amount')),);
        return;
      }
    } else {
      if (_items.isEmpty || _totalAmount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item with amount')),);
        return;
      }
      for (final item in _items) {
        if (item.nameController.text.isEmpty || item.amountController.text.isEmpty || item.categoryController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fill all fields for each item')),);
          return;
        }
        if (double.tryParse(item.amountController.text) == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid amount in one of the items')),);
          return;
        }
      }
      amount = _totalAmount;
      category = _items.first.categoryController.text;
    }
    // Проверка счета
    if (_selectedType == TransactionType.movement) {
      if (_accountFromController.text.isEmpty || _accountToController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill both accounts for transfer')),);
        return;
      }
    } else {
      if (_accountFromController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill the account')),);
        return;
      }
    }
    setState(() { _isLoading = true; });
    try {
      await ApiService.postTransaction(
        type: _selectedType,
        amount: amount,
        date: _selectedDate,
        category: category,
        description: _descriptionController.text,
        // TODO: account info можно добавить в API
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction saved successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
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
            // Индикатор для свайпа
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
            // Поле счета
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
              // Поле суммы для перевода
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
              // Секция позиций и итоговая сумма только для income/expense
              Text('Items', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final item = _items[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // Название
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: item.nameController,
                            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Стоимость
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: item.amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Категория
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: item.categoryController,
                            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Кнопка удаления
                        if (_items.length > 1)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _removeItem(i),
                          ),
                      ],
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
              const SizedBox(height: 16),
              // Итоговая сумма
              TextField(
                controller: TextEditingController(text: _totalAmount == 0 ? '' : _totalAmount.toStringAsFixed(2)),
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Total amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Поле ввода описания
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            // Выбор даты
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

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    categoryController.dispose();
  }
} 