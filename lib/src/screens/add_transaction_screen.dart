import 'package:flutter/material.dart';

enum TransactionType {
  income,
  expense,
  movement,
}

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _selectedType = TransactionType.expense;
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 16,
        right: 16,
      ),
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
          
          // Заголовок
          Text(
            'New transaction',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Выбор типа операции
          SegmentedButton<TransactionType>(
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
          const SizedBox(height: 24),

          // Поле ввода суммы
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              border: const OutlineInputBorder(),
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
              child: Text(
                '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Кнопка сохранения
          FilledButton(
            onPressed: () {
              // TODO: Добавить логику сохранения
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 