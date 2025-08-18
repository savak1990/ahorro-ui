import 'package:ahorro_ui/src/models/currencies.dart';
import 'package:ahorro_ui/src/providers/transaction_stats_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionStatsChart extends StatelessWidget {
  const TransactionStatsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionStatsProvider>();
    final data = provider.data?.items ?? []; // Get the transaction stats items
    final isLoading = provider.loading;

    debugPrint(
      'TransactionStatsChart: data length = ${data.length}, isLoading = $isLoading',
    );

    // Consistent container for all states
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: _buildChartContent(isLoading, data, provider.selectedTypeLabel),
    );
  }

  Widget _buildChartContent(
    bool isLoading,
    List data,
    String selectedTypeLabel,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Validate and prepare chart data with proper error handling
    final validData = data.where((item) {
      return item.amount > 0 &&
          item.label.isNotEmpty &&
          item.amount.isFinite &&
          !item.amount.isNaN;
    }).toList();

    if (validData.isEmpty) {
      return const Center(child: Text('No valid data to display'));
    }

    var chartDataList = validData.map((item) {
      return _ChartData(
        item.label,
        item.amount / 100,
        formatAmountInt(item.amount, item.currency),
      );
    }).toList();

    var total = validData.fold<int>(
      0,
      (sum, item) => sum + (item.amount as int),
    );

    try {
      debugPrint('Attempting to create Syncfusion PieChart...');
      return SfCircularChart(
        title: ChartTitle(
          text:
              'Total $selectedTypeLabel: ${formatAmountInt(total, validData.first.currency)}',
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // Neutral and calm color palette for the entire chart
        palette: const <Color>[
          Color(0xFF6B7280), // Cool Gray
          Color(0xFF8B9DC3), // Muted Blue
          Color(0xFF9CA3AF), // Light Gray
          Color(0xFFA7C4A0), // Sage Green
          Color(0xFFB8A99A), // Warm Beige
          Color(0xFFC1A9A0), // Dusty Rose
          Color(0xFFB5A7B8), // Lavender Gray
          Color(0xFFA8B5B2), // Mint Gray
          Color(0xFFB4A995), // Taupe
          Color(0xFF9FB4C7), // Soft Blue Gray
        ],
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap, // Enable multiline legend
          textStyle: TextStyle(fontSize: 12),
          height: '25%', // Fixed height for predictable layout
          itemPadding: 8, // Spacing between legend items
        ),
        series: <CircularSeries>[
          PieSeries<_ChartData, String>(
            dataSource: chartDataList,
            xValueMapper: (_ChartData data, _) => data.label,
            yValueMapper: (_ChartData data, _) => data.amount,
            dataLabelMapper: (_ChartData data, _) =>
                '${data.label}: ${data.formattedAmount}',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            enableTooltip: true,
            animationDuration: 1000,
          ),
        ],
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'point.x: point.y',
          textStyle: const TextStyle(fontSize: 12),
        ),
      );
    } catch (e) {
      debugPrint('Error creating Syncfusion PieChart: $e');
      return Center(child: Text('Error: $e'));
    }
  }
}

// Helper class for chart data
class _ChartData {
  _ChartData(this.label, this.amount, this.formattedAmount);
  final String label;
  final double amount;
  final String formattedAmount;
}
