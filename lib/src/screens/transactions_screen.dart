import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../widgets/transaction_tile.dart';
import '../models/filter_option.dart';
import 'add_transaction_screen.dart';
import '../widgets/date_filter_bottom_sheet.dart';
import 'package:ahorro_ui/src/widgets/filters_bottom_sheet.dart';
import '../models/transaction_display_data.dart';
import '../models/grouping_type.dart';
import '../models/date_filter_type.dart';
import '../widgets/grouped_transactions_sliver.dart';
import '../widgets/active_filters_summary.dart';
import '../widgets/active_date_filters_summary.dart';
import 'transaction_details_screen.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_entries_provider.dart';
import '../providers/transactions_filter_provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../widgets/typography.dart';

class TransactionsScreen extends StatefulWidget {
  final String? initialType;
  const TransactionsScreen({super.key, this.initialType});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _showAppBarTitle = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Данные транзакций загружаются при старте приложения через AppStateProvider.initializeApp()
    // Если initialType задан, выставляем фильтр по типу
    if (widget.initialType != null && widget.initialType!.isNotEmpty) {
      // Установим стартовый фильтр через провайдер после первой сборки
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final filter = Provider.of<TransactionsFilterProvider>(context, listen: false);
        filter.toggleType(widget.initialType!, true);
      });
    }
    
    // Добавляем слушатель скролла
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Показываем заголовок в AppBar когда скроллим вниз больше 100px
    final showTitle = _scrollController.offset > 100;
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }
  }

  void _refreshTransactions() {
    Provider.of<TransactionEntriesProvider>(context, listen: false).loadEntries();
  }

  // moved to provider

  // moved to provider

  // Группировка перенесена в провайдер

  void _showDateFilterBottomSheet() async {
    final filter = Provider.of<TransactionsFilterProvider>(context, listen: false);
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DateFilterBottomSheet(
        initialFilterType: filter.dateFilterType.name,
        initialYear: filter.selectedYear,
        initialMonth: filter.selectedMonth,
        initialStartDate: filter.startDate,
        initialEndDate: filter.endDate,
        availableYears: filter.availableYears,
      ),
    );

    if (result != null) {
      final String typeStr = result['filterType'] as String;
      filter.setDateFilterType(typeStr == 'period' ? DateFilterType.period : DateFilterType.month);
      filter.setYear(result['year']);
      filter.setMonth(result['month']);
      filter.setStartDate(result['startDate']);
      filter.setEndDate(result['endDate']);
      _refreshTransactions();
    }
  }

  void _onTypeFilterChanged(String value, bool selected) {
    Provider.of<TransactionsFilterProvider>(context, listen: false).toggleType(value, selected);
  }

  void _onAccountFilterChanged(String value, bool selected) {
    Provider.of<TransactionsFilterProvider>(context, listen: false).toggleAccount(value, selected);
  }

  void _onCategoryFilterChanged(String value, bool selected) {
    Provider.of<TransactionsFilterProvider>(context, listen: false).toggleCategory(value, selected);
  }

  void _clearAllFilters() {
    Provider.of<TransactionsFilterProvider>(context, listen: false).clearAllFilters();
    _refreshTransactions();
  }

  // removed: icon mapping now handled via Category.getCategoryIcon in provider

  List<FilterOption> _getTypeFilterOptions() => Provider.of<TransactionsFilterProvider>(context, listen: false).getTypeFilterOptions();

  List<FilterOption> _getAccountFilterOptions() => Provider.of<TransactionsFilterProvider>(context, listen: false).getAccountFilterOptions();

  List<FilterOption> _getCategoryFilterOptions() => Provider.of<TransactionsFilterProvider>(context, listen: false).getCategoryFilterOptions();

  // moved to provider

  // moved to provider

  // moved to provider

  void _showFiltersBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, Set<String>>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => FiltersBottomSheet(
        typeOptions: _getTypeFilterOptions(),
        accountOptions: _getAccountFilterOptions(),
        categoryOptions: _getCategoryFilterOptions(),
        initialSelectedTypes: Provider.of<TransactionsFilterProvider>(context, listen: false).selectedTypes,
        initialSelectedAccounts: Provider.of<TransactionsFilterProvider>(context, listen: false).selectedAccounts,
        initialSelectedCategories: Provider.of<TransactionsFilterProvider>(context, listen: false).selectedCategories,
      ),
    );

    if (result != null) {
      debugPrint('Filters result: $result');
      Provider.of<TransactionsFilterProvider>(context, listen: false).updateSelections(
        types: result['types'],
        accounts: result['accounts'],
        categories: result['categories'],
      );
      debugPrint('Updated filters via provider');
    }
  }

  void _showGroupingOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Group by',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Date'),
              trailing: Provider.of<TransactionsFilterProvider>(context, listen: false).groupingType == GroupingType.date ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () {
                setState(() {
                  Provider.of<TransactionsFilterProvider>(context, listen: false).groupingType = GroupingType.date;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Category'),
              trailing: Provider.of<TransactionsFilterProvider>(context, listen: false).groupingType == GroupingType.category ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () {
                setState(() {
                  Provider.of<TransactionsFilterProvider>(context, listen: false).groupingType = GroupingType.category;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final DateTime month = args?['month'] ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: _showAppBarTitle 
            ? Text(
                AppStrings.transactionsTitle,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              )
            : const Text(''),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        bottom: (Provider.of<TransactionsFilterProvider>(context).hasActiveDateFilters ||
                Provider.of<TransactionsFilterProvider>(context).hasActiveNonDateFilters)
            ? PreferredSize(
                preferredSize: Size.fromHeight(
                  (Provider.of<TransactionsFilterProvider>(context).hasActiveDateFilters ? 40 : 0) +
                      (Provider.of<TransactionsFilterProvider>(context).hasActiveNonDateFilters ? 40 : 0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (Provider.of<TransactionsFilterProvider>(context).hasActiveDateFilters)
                      ActiveDateFiltersSummary(
                        dateFilterType: Provider.of<TransactionsFilterProvider>(context).dateFilterType,
                        selectedYear: Provider.of<TransactionsFilterProvider>(context).selectedYear,
                        selectedMonth: Provider.of<TransactionsFilterProvider>(context).selectedMonth,
                        startDate: Provider.of<TransactionsFilterProvider>(context).startDate,
                        endDate: Provider.of<TransactionsFilterProvider>(context).endDate,
                        onClear: () => Provider.of<TransactionsFilterProvider>(context, listen: false).clearDateFilters(),
                      ),
                    if (Provider.of<TransactionsFilterProvider>(context).hasActiveNonDateFilters)
                      ActiveFiltersSummary(
                        selectedTypes: Provider.of<TransactionsFilterProvider>(context).selectedTypes,
                        selectedAccounts: Provider.of<TransactionsFilterProvider>(context).selectedAccounts,
                        selectedCategories: Provider.of<TransactionsFilterProvider>(context).selectedCategories,
                        onClear: _clearAllFilters,
                      ),
                  ],
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(
              Icons.format_list_bulleted,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: _showGroupingOptions,
          ),
          IconButton(
            icon: Icon(
              Icons.tune,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: _showFiltersBottomSheet,
          ),
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: _showDateFilterBottomSheet,
          ),
        ],
      ),
      body: Consumer2<TransactionEntriesProvider, TransactionsFilterProvider>(
        builder: (context, entriesProvider, filterProvider, _) {
          if (entriesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (entriesProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('Error loading transactions', style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _refreshTransactions,
                    child: Text('Retry', style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary)),
                  ),
                ],
              ),
            );
          }

          // Преобразуем entries в display-структуру (группировка и т.д.)
          // Передаём entries провайдеру фильтров после кадра, чтобы избежать notify во время build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            filterProvider.setEntries(entriesProvider.entries);
          });

          // Получаем сгруппированные данные из провайдера
          final groupedTransactions = filterProvider.groupedTransactions;

          if (groupedTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (filterProvider.hasActiveDateFilters || filterProvider.hasActiveNonDateFilters)
                        ? 'with current filters'
                        : 'for ${_getMonthName(month)}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshTransactions();
              // Ждем немного, чтобы показать анимацию
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              controller: _scrollController, // Добавляем контроллер скролла
              slivers: [
                // Большой заголовок Transactions как часть экрана
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.horizontalPadding,
                      24,
                      AppConstants.horizontalPadding,
                      AppConstants.screenPadding,
                    ),
                    child: const HeadlineEmphasizedLarge(
                      text: AppStrings.transactionsTitle,
                    ),
                  ),
                ),
                // Список транзакций
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 8),
                  sliver: GroupedTransactionsSliver(
                    groupedTransactions: groupedTransactions,
                    onTapTransaction: (tx) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailsScreen(transactionId: tx.id),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Container(
                color: Colors.white,
                child: const AddTransactionScreen(),
              ),
            ),
          ).then((_) {
            _refreshTransactions();
          });
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // moved to provider

  String _getMonthName(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }

  // moved to provider

  // moved to provider

  void _clearDateFilters() {
    Provider.of<TransactionsFilterProvider>(context, listen: false).clearDateFilters();
    _refreshTransactions();
  }

  // moved to provider

  // moved to separate widget

  // moved to separate widget
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// moved to ../models/transaction_display_data.dart