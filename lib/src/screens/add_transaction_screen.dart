import 'package:ahorro_ui/src/models/transaction_type.dart';
import 'package:ahorro_ui/src/services/api_service.dart';
import 'package:ahorro_ui/src/widgets/category_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/balances_provider.dart';
import '../providers/categories_provider.dart';
import '../models/transaction_entry.dart';
import '../models/category.dart';
import '../widgets/add_balance_form.dart';
import '../constants/app_typography.dart';
import '../widgets/expense_transaction_form.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TransactionType _selectedType = TransactionType.expense;

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                Text(
                  'New transaction',
                  style: AppTypography.displaySmall,
                  textAlign: TextAlign.left,
                ),
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
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (_selectedType == TransactionType.expense) {
                  return const ExpenseTransactionForm();
                } else {
                  return const Center(child: Text('Пока реализован только расход'));
                }
              },
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
  String defaultCategoryId = '';
  String defaultCategoryName = '';
  IconData? categoryIcon;

  _TransactionItem({
    Category? defaultCategory,
  }) {
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

// Новый виджет для выбора мерчанта чипами
class _MerchantChips extends StatefulWidget {
  final String selectedMerchant;
  final ValueChanged<String> onMerchantSelected;
  const _MerchantChips({required this.selectedMerchant, required this.onMerchantSelected});

  @override
  State<_MerchantChips> createState() => _MerchantChipsState();
}

class _MerchantChipsState extends State<_MerchantChips> {
  List<String> _merchants = [];
  @override
  void initState() {
    super.initState();
    _loadMerchants();
  }
  void _loadMerchants() async {
    // TODO: Заменить на реальный источник (например, из транзакций)
    // Здесь просто пример
    setState(() {
      _merchants = ['Mercadona', 'Amazon', 'Lidl', 'Carrefour'];
    });
  }
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: [
        ..._merchants.map((merchant) => ChoiceChip(
          label: Text(merchant),
          selected: widget.selectedMerchant == merchant,
          onSelected: (selected) {
            if (selected) widget.onMerchantSelected(merchant);
          },
        )),
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          icon: const Icon(Icons.search),
          label: const Text('Find merchant'),
          onPressed: () async {
            final newMerchant = await showDialog<String>(
              context: context,
              builder: (context) {
                final controller = TextEditingController();
                return AlertDialog(
                  title: const Text('Find merchant'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Merchant name'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, controller.text.trim()),
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
            if (newMerchant != null && newMerchant.isNotEmpty) {
              setState(() {
                _merchants.add(newMerchant);
              });
              widget.onMerchantSelected(newMerchant);
            }
          },
        ),
      ],
    );
  }
} 