import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import '../constants/app_typography.dart';
import '../widgets/typography.dart';
import '../constants/app_strings.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/list_item_tile.dart';
import '../widgets/category_picker_dialog.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final String transactionId;
  const TransactionDetailsScreen({Key? key, required this.transactionId}) : super(key: key);

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  Map<String, dynamic>? transactionData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchTransactionDetails();
  }

  Future<void> fetchTransactionDetails() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await ApiService.getTransactionById(widget.transactionId);
      if (kDebugMode) {
        try {
          final entries = (data['TransactionEntries'] as List?) ?? const [];
          debugPrint('[TX_DETAILS] Loaded transaction ${widget.transactionId}: keys=${data.keys.toList()}');
          debugPrint('[TX_DETAILS] Entries count: ${entries.length}');
          for (int i = 0; i < entries.length; i++) {
            final e = entries[i] as Map<String, dynamic>;
            final catObj = e['Category'];
            String catNameFromObj = '-';
            String catNameLegacy = '-';
            if (catObj is Map<String, dynamic>) {
              catNameFromObj = (catObj['Name'] ?? '-').toString();
              catNameLegacy = (catObj['CategoryName'] ?? '-').toString();
            }
            debugPrint('[TX_DETAILS] Entry[$i]: NameField="${e['Name']}", Category.Name="$catNameFromObj", Category.CategoryName="$catNameLegacy", Amount=${e['Amount']}, Description=${e['Description']}');
          }
        } catch (logErr) {
          debugPrint('[TX_DETAILS] Logging error: $logErr');
        }
      }
      setState(() {
        transactionData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Ошибка: $e';
        isLoading = false;
      });
    }
  }

  Color _typeColor(String type, ThemeData theme) {
    return theme.colorScheme.primary;
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return Icons.trending_up;
      case 'expense':
        return Icons.trending_down;
      case 'movement':
        return Icons.swap_horiz;
      default:
        return Icons.category;
    }
  }

  // Используем общий маппинг иконок категорий из getCategoryIcon (category_picker_dialog.dart)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final type = transactionData?['Type'] ?? '-';
    final displayType = type[0].toUpperCase() + type.substring(1);
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : transactionData == null
                  ? const Center(child: Text('Нет данных'))
                  : _buildDetails(context, theme, textTheme),
    );
  }

  Widget _buildDetails(BuildContext context, ThemeData theme, TextTheme textTheme) {
    final tx = transactionData!;
    final type = tx['Type'] ?? '-';
    final String _typeStr = type.toString();
    final String displayType = _typeStr.isNotEmpty
        ? _typeStr[0].toUpperCase() + _typeStr.substring(1)
        : '-';
    final entries = (tx['TransactionEntries'] as List?) ?? [];
    double totalAmount = 0.0;
    for (final entry in entries) {
      final amt = (entry as Map<String, dynamic>)['Amount'];
      if (amt != null) {
        totalAmount += (double.tryParse(amt.toString()) ?? 0.0) / 100;
      }
    }
    if (kDebugMode) {
      debugPrint('[TX_DETAILS] Building UI: type=$_typeStr, entries=${entries.length}');
    }
    final mainEntry = entries.isNotEmpty ? entries[0] as Map<String, dynamic> : null;
    final description = mainEntry != null ? mainEntry['Description'] : null;
    final date = tx['TransactedAt'] ?? tx['ApprovedAt'] ?? tx['CreatedAt'];
    final balance = tx['Balance']?['Title'] ?? '-';
    final merchant = tx['Merchant'] ?? '-';
    final currency = tx['Balance']?['Currency'] ?? 'EUR';
    final parsedDate = date != null ? DateTime.tryParse(date) : null;
    final formattedDate = parsedDate != null ? DateFormat('dd.MM.yyyy HH:mm').format(parsedDate) : '-';
    final approvedAt = tx['ApprovedAt'] ?? '-';
    final formattedApprovedAt = approvedAt != '-' && approvedAt != null
        ? DateFormat('dd.MM.yyyy').format(DateTime.tryParse(approvedAt) ?? DateTime.now())
        : '-';

    Color valueColor = theme.colorScheme.onSurfaceVariant;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GENERAL (тип и сумма)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeadlineEmphasizedLarge(
                        text: displayType,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${totalAmount.toStringAsFixed(2)} ',
                            style: AppTypography.displayLarge.copyWith(
                              color: _typeColor(type, theme),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currency,
                            style: AppTypography.titleLarge.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // INFORMATION
            const TitleEmphasizedLarge(text: AppStrings.transactionDetailsInformationTitle),
            const SizedBox(height: 8),
            SettingsSectionCard(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              children: [
                ListItemTile(
                  title: 'Wallet',
                  icon: Icons.account_balance_wallet,
                  iconColor: theme.colorScheme.primary,
                  trailing: Text(
                    (balance == null || balance.toString().isEmpty || balance == '-') ? 'unknown' : balance.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (description != null && description.toString().isNotEmpty)
                  ListItemTile(
                    title: 'Description',
                    icon: Icons.description,
                    iconColor: theme.colorScheme.primary,
                    trailing: Text(
                      description.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // PERIOD
            const TitleEmphasizedLarge(text: AppStrings.transactionDetailsPeriodTitle),
            const SizedBox(height: 8),
            SettingsSectionCard(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              children: [
                ListItemTile(
                  title: 'Approved at',
                  icon: Icons.calendar_today,
                  iconColor: theme.colorScheme.primary,
                  trailing: Text(
                    (formattedApprovedAt.isEmpty || formattedApprovedAt == '-') ? 'unknown' : formattedApprovedAt,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ENTRIES
            if (entries.isNotEmpty) ...[
              const TitleEmphasizedLarge(text: AppStrings.transactionDetailsEntriesTitle),
              const SizedBox(height: 8),
              SettingsSectionCard(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                children: [
                  for (int i = 0; i < entries.length; i++)
                    Builder(builder: (context) {
                      final e = entries[i] as Map<String, dynamic>;
                      final cat = (e['Category']?['Name'] ?? e['Name'] ?? e['Category']?['CategoryName'] ?? '-').toString();
                      final amt = e['Amount'] != null ? (double.tryParse(e['Amount'].toString()) ?? 0.0) / 100 : 0.0;
                      final desc = e['Description'] ?? '';
                      final iconData = getCategoryIcon(cat);
                      if (kDebugMode) {
                        debugPrint('[TX_DETAILS] Render Entry[$i]: Name="${e['Name']}", catResolved="$cat", iconCode=${iconData.codePoint}, family=${iconData.fontFamily}, desc="$desc"');
                      }
                      return ListItemTile(
                        title: cat,
                        subtitle: desc.toString().isNotEmpty ? desc.toString() : null,
                        icon: iconData,
                        iconColor: theme.colorScheme.primary,
                        trailing: Text(
                          '${amt.toStringAsFixed(2)} $currency',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: valueColor,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
} 