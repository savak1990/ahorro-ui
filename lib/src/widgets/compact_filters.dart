import 'package:flutter/material.dart';
import '../models/filter_option.dart';
import 'filter_chips.dart';

class CompactFilters extends StatefulWidget {
  final List<FilterOption> typeOptions;
  final List<FilterOption> accountOptions;
  final List<FilterOption> categoryOptions;
  final Set<String> selectedTypes;
  final Set<String> selectedAccounts;
  final Set<String> selectedCategories;
  final Function(String, bool) onTypeFilterChanged;
  final Function(String, bool) onAccountFilterChanged;
  final Function(String, bool) onCategoryFilterChanged;
  final VoidCallback onClearAll;

  const CompactFilters({
    super.key,
    required this.typeOptions,
    required this.accountOptions,
    required this.categoryOptions,
    required this.selectedTypes,
    required this.selectedAccounts,
    required this.selectedCategories,
    required this.onTypeFilterChanged,
    required this.onAccountFilterChanged,
    required this.onCategoryFilterChanged,
    required this.onClearAll,
  });

  @override
  State<CompactFilters> createState() => _CompactFiltersState();
}

class _CompactFiltersState extends State<CompactFilters> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isExpanded)
            InkWell(
              onTap: () => setState(() => _isExpanded = true),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt, color: colorScheme.primary),
                    SizedBox(width: 8),
                    Expanded(child: _buildSelectedFiltersSummary()),
                    Icon(Icons.expand_more, color: colorScheme.primary),
                  ],
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.filter_alt, color: colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: widget.onClearAll,
                    child: Text('Reset', style: textTheme.bodySmall?.copyWith(color: colorScheme.primary)),
                  ),
                  IconButton(
                    icon: Icon(Icons.expand_less, color: colorScheme.primary),
                    onPressed: () => setState(() => _isExpanded = false),
                  ),
                ],
              ),
            ),
            // Тип транзакции
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.category, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Type', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            FilterChips(
              options: widget.typeOptions,
              selectedValues: widget.selectedTypes.isEmpty ? {'all'} : widget.selectedTypes,
              onSelectionChanged: widget.onTypeFilterChanged,
              multiSelect: true,
            ),
            const SizedBox(height: 12),
            // Счет
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.account_balance, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Balance', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            FilterChips(
              options: widget.accountOptions,
              selectedValues: widget.selectedAccounts.isEmpty ? {'all'} : widget.selectedAccounts,
              onSelectionChanged: widget.onAccountFilterChanged,
              multiSelect: true,
            ),
            const SizedBox(height: 12),
            // Категория
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.label, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Category', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            FilterChips(
              options: widget.categoryOptions,
              selectedValues: widget.selectedCategories.isEmpty ? {'all'} : widget.selectedCategories,
              onSelectionChanged: widget.onCategoryFilterChanged,
              multiSelect: true,
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedFiltersSummary() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final selectedFilters = <String>[];
    if (widget.selectedTypes.isNotEmpty && widget.selectedTypes.first != 'all') {
      final typeLabels = widget.selectedTypes.map((type) {
        final option = widget.typeOptions.firstWhere((opt) => opt.value == type, orElse: () => FilterOption(value: type, label: type));
        return option.label;
      }).toList();
      selectedFilters.add('Type: ${typeLabels.join(", ")}');
    }
    if (widget.selectedAccounts.isNotEmpty && widget.selectedAccounts.first != 'all') {
      final accountLabels = widget.selectedAccounts.map((account) {
        final option = widget.accountOptions.firstWhere((opt) => opt.value == account, orElse: () => FilterOption(value: account, label: account));
        return option.label;
      }).toList();
      selectedFilters.add('Balance: ${accountLabels.join(", ")}');
    }
    if (widget.selectedCategories.isNotEmpty && widget.selectedCategories.first != 'all') {
      final categoryLabels = widget.selectedCategories.map((category) {
        final option = widget.categoryOptions.firstWhere((opt) => opt.value == category, orElse: () => FilterOption(value: category, label: category));
        return option.label;
      }).toList();
      selectedFilters.add('Category: ${categoryLabels.join(", ")}');
    }
    if (selectedFilters.isEmpty) {
      return Text(
        'No selected filters',
        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      );
    }
    return Text(
      selectedFilters.join('  •  '),
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
} 