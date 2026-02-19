import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RevenueChartSection extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const RevenueChartSection({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive height
    final chartHeight = screenWidth < 400 ? 240.0 : 280.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Monthly Revenue",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          height: chartHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: data.isEmpty
              ? const Center(child: Text("No revenue data"))
              : _buildChart(),
        ),
      ],
    );
  }

  Widget _buildChart() {
    final revenues = data
        .map((e) => (e["revenue"] ?? 0).toDouble())
        .toList();

    final maxRevenue =
    revenues.isEmpty ? 0 : revenues.reduce((a, b) => a > b ? a : b);

    final maxY = maxRevenue == 0 ? 100 : maxRevenue * 1.2;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxY / 5,
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    _formatCompactCurrency(value),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[index]["month"] ?? "",
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.length,
                  (index) => FlSpot(
                index.toDouble(),
                (data[index]["revenue"] ?? 0).toDouble(),
              ),
            ),
            isCurved: true,
            color: AppColors.primaryBlue,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color:
              AppColors.primaryBlue.withOpacity(0.15),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  String _formatCompactCurrency(double value) {
    if (value >= 10000000) {
      return "₹${(value / 10000000).toStringAsFixed(1)}Cr";
    } else if (value >= 100000) {
      return "₹${(value / 100000).toStringAsFixed(1)}L";
    } else if (value >= 1000) {
      return "₹${(value / 1000).toStringAsFixed(1)}K";
    } else {
      return "₹${value.toInt()}";
    }
  }
}
