import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:formz/formz.dart';
import 'package:ahorro_ui/src/widgets/category_picker_dialog.dart';
import '../providers/balances_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/merchants_provider.dart';
import '../models/transaction_entry.dart';
import '../models/category.dart';
import '../models/merchant.dart';
import '../services/api_service.dart';
import '../constants/app_typography.dart';
import '../models/transaction_type.dart';
import '../widgets/add_balance_form.dart';
import '../widgets/balance_chips.dart';
import '../widgets/transaction_item_row.dart';

// Formz input models
class AmountInput extends FormzInput<String, String> {
  const AmountInput.pure() : super.pure('');
  const AmountInput.dirty([String value = '']) : super.dirty(value);

  @override
  String? validator(String value) {
    final amount = double.tryParse(value.replaceAll(',', '.'));
    if (value.isEmpty) return 'Обязательное поле';
    if (amount == null || amount <= 0) return 'Некорректная сумма';
    return null;
  }
}

class DescriptionInput extends FormzInput<String, String> {
  const DescriptionInput.pure() : super.pure('');
  const DescriptionInput.dirty([String value = '']) : super.dirty(value);

  @override
  String? validator(String value) {
    //if (value.trim().isEmpty) return 'Описание обязательно';
    return null;
  }
}

class BalanceIdInput extends FormzInput<String, String> {
  const BalanceIdInput.pure() : super.pure('');
  const BalanceIdInput.dirty([String value = '']) : super.dirty(value);

  @override
  String? validator(String value) {
    //if (value.isEmpty) return 'Выберите счёт';
    return null;
  }
}

class ExpenseTransactionFormData {
  final List<TransactionEntry> entries;
  final String merchant;
  final String balanceId;
  final DateTime date;
  ExpenseTransactionFormData({
    required this.entries,
    required this.merchant,
    required this.balanceId,
    required this.date,
  });
}

class ExpenseTransactionForm extends StatefulWidget {
  final ValueNotifier<FormzSubmissionStatus> formStatus;
  final ValueChanged<ExpenseTransactionFormData> onSubmit;
  final bool isLoading;
  const ExpenseTransactionForm({
    super.key,
    required this.formStatus,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  ExpenseTransactionFormState createState() => ExpenseTransactionFormState();
}

class ExpenseTransactionFormState extends State<ExpenseTransactionForm> {
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<_TransactionItem> _items = [];
  String? _fromAccountId;
  Merchant? _selectedMerchant;

  // formz state
  late List<AmountInput> _amountInputs;
  late List<DescriptionInput> _descInputs;
  late BalanceIdInput _balanceInput;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
      final defaultCategory = categoriesProvider.defaultCategory;
      setState(() {
        _items = [
          _TransactionItem(defaultCategory: defaultCategory),
        ];
        _amountInputs = [const AmountInput.pure()];
        _descInputs = [const DescriptionInput.pure()];
        _balanceInput = const BalanceIdInput.pure();
      });
      _updateFormzState();
    });
  }

  void _updateFormzState() {
    final isValid = Formz.validate([
      ..._amountInputs,
      ..._descInputs,
      _balanceInput,
    ]);
    widget.formStatus.value = isValid ? FormzSubmissionStatus.success : FormzSubmissionStatus.initial;
  }

  // Метод для автоматического выбора первого баланса
  void _selectFirstBalanceIfNeeded(List<dynamic> balances) {
    if (balances.isNotEmpty && _balanceInput.value.isEmpty) {
      setState(() {
        _balanceInput = BalanceIdInput.dirty(balances.first.balanceId);
        _updateFormzState();
      });
    }
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    _descriptionController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
      final defaultCategory = categoriesProvider.defaultCategory;
      _items.add(_TransactionItem(defaultCategory: defaultCategory));
      _amountInputs.add(const AmountInput.pure());
      _descInputs.add(const DescriptionInput.pure());
      _updateFormzState();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
      _amountInputs.removeAt(index);
      _descInputs.removeAt(index);
      _updateFormzState();
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

  double get _totalAmount => _items.fold(0.0, (sum, item) {
    final value = double.tryParse(item.amountController.text);
    return sum + (value ?? 0.0);
  });

  Future<void> _saveTransaction() async {
    _updateFormzState();
    if (widget.formStatus.value != FormzSubmissionStatus.success) return;
    final transactionEntries = List.generate(_items.length, (i) {
      final parsedAmount = double.tryParse(_amountInputs[i].value.replaceAll(',', '.')) ?? 0.0;
      return TransactionEntry(
        description: _descInputs[i].value,
        amount: (parsedAmount * 100).round(),
        categoryId: _items[i].selectedCategoryId,
      );
    });
    final data = ExpenseTransactionFormData(
      entries: transactionEntries,
      merchant: _selectedMerchant?.name ?? '',
      balanceId: _balanceInput.value,
      date: _selectedDate,
    );
    widget.onSubmit(data);
  }

  void submit() {
    _saveTransaction();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = Provider.of<CategoriesProvider>(context);
    if (categoriesProvider.isLoading || categoriesProvider.categories.isEmpty || _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final balancesProvider = Provider.of<BalancesProvider>(context);
    final balances = balancesProvider.balances;
    
    // Автоматически выбираем первый баланс если не выбран
    _selectFirstBalanceIfNeeded(balances);
    
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Items', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, i) {
              final item = _items[i];
              return TransactionItemRow(
                nameController: item.nameController,
                amountController: item.amountController,
                selectedCategoryId: item.selectedCategoryId,
                selectedCategoryIcon: item.selectedCategoryIcon,
                onCategorySelected: (selected) {
                  setState(() {
                    item.selectedCategoryId = selected.id;
                    item.selectedCategoryName = selected.name;
                    item.selectedCategoryIcon = selected.iconData;
                  });
                },
                onNameChanged: (val) {
                  _descInputs[i] = DescriptionInput.dirty(val);
                  _updateFormzState();
                  setState(() {});
                },
                onAmountChanged: (val) {
                  _amountInputs[i] = AmountInput.dirty(val);
                  _updateFormzState();
                  setState(() {});
                },
                descriptionErrorText: _descInputs[i].isNotValid ? _descInputs[i].error : null,
                hasAmountError: (_amountInputs[i].isNotValid && !_amountInputs[i].isPure),
                canRemove: _items.length > 1,
                onRemove: () => _removeItem(i),
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
          const SizedBox(height: 24),
          BalanceChips(
            selectedBalanceId: _balanceInput.value.isEmpty ? null : _balanceInput.value,
            onBalanceSelected: (balanceId) {
              setState(() {
                _balanceInput = BalanceIdInput.dirty(balanceId ?? '');
                _updateFormzState();
              });
            },
            title: 'Balance',
            allowDeselect: false,
          ),
          if (_balanceInput.isNotValid)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(_balanceInput.error ?? '', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
            ),
          const SizedBox(height: 24),
          // Text('Merchant', style: Theme.of(context).textTheme.titleMedium),
          // const SizedBox(height: 8),
          // _MerchantChips(
          //   selectedMerchant: _selectedMerchant,
          //   onMerchantSelected: (merchant) {
          //     setState(() {
          //       _selectedMerchant = merchant;
          //     });
          //   },
          // ),
          const SizedBox(height: 24),
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
          //const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TransactionItem {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String selectedCategoryId = '';
  String selectedCategoryName = '';
  IconData? selectedCategoryIcon;
  _TransactionItem({Category? defaultCategory}) {
    if (defaultCategory != null) {
      selectedCategoryId = defaultCategory.id;
      selectedCategoryName = defaultCategory.name;
      selectedCategoryIcon = defaultCategory.iconData;
    }
  }
  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class _MerchantChips extends StatelessWidget {
  final Merchant? selectedMerchant;
  final ValueChanged<Merchant?> onMerchantSelected;
  const _MerchantChips({required this.selectedMerchant, required this.onMerchantSelected});

  @override
  Widget build(BuildContext context) {
    final merchantsProvider = Provider.of<MerchantsProvider>(context);
    final merchants = List<Merchant>.from(merchantsProvider.merchants);
    merchants.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final topMerchants = merchants.take(3).toList();

    if (merchantsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (topMerchants.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed('/merchant_search').then((result) {
              if (result is Merchant) {
                onMerchantSelected(result);
              }
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add merchant'),
        ),
      );
    }

    return Wrap(
      spacing: 8.0,
      children: [
        ...topMerchants.map((merchant) => ChoiceChip(
          label: Text(merchant.name),
          avatar: merchant.imageUrl.isNotEmpty ? CircleAvatar(backgroundImage: NetworkImage(merchant.imageUrl)) : null,
          selected: selectedMerchant?.merchantId == merchant.merchantId,
          onSelected: (selected) {
            if (selected) {
              onMerchantSelected(merchant);
            } else if (selectedMerchant?.merchantId == merchant.merchantId) {
              onMerchantSelected(null);
            }
          },
        )),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamed('/merchant_search').then((result) {
              if (result is Merchant) {
                onMerchantSelected(result);
              }
            });
          },
          icon: const Icon(Icons.search),
          label: const Text('Find merchant'),
        ),
      ],
    );
  }
} 