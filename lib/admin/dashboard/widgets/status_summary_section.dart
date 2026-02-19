import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StatusSummarySection extends StatelessWidget {
  final Map<String, dynamic> status;

  const StatusSummarySection({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final enquiry = status["enquiry"] ?? {};
    final quotation = status["quotation"] ?? {};
    final loi = status["loi"] ?? {};
    final payment = status["payment"] ?? {};

    final screenWidth = MediaQuery.of(context).size.width;

    final cardWidth = screenWidth < 450
        ? screenWidth * 0.90
        : screenWidth < 900
        ? screenWidth * 0.55
        : 320.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Business Flow Analytics",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),

        SizedBox(
          height: 340,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildDonutCard(
                width: cardWidth,
                title: "Enquiry Analytics",
                subtitle: "Status breakdown",
                data: {
                  "Raised": enquiry["raised"] ?? 0,
                  "Quoted": enquiry["quoted"] ?? 0,
                },
                colors: {
                  "Raised": Colors.blue,
                  "Quoted": Colors.green,
                },
              ),

              _buildDonutCard(
                width: cardWidth,
                title: "Quotation Analytics",
                subtitle: "Quotation distribution",
                data: {
                  "LOI Sent": quotation["loi_sent"] ?? 0,
                  "Payment Done": quotation["payment_done"] ?? 0,
                },
                colors: {
                  "LOI Sent": Colors.purple,
                  "Payment Done": Colors.green,
                },
              ),

              _buildDonutCard(
                width: cardWidth,
                title: "LOI Analytics",
                subtitle: "Letter of intent overview",
                data: {
                  "Accepted": loi["accepted"] ?? 0,
                  "Pending": loi["pending"] ?? 0,
                  "Rejected": loi["rejected"] ?? 0,
                },
                colors: {
                  "Accepted": Colors.green,
                  "Pending": Colors.orange,
                  "Rejected": Colors.red,
                },
              ),

              _buildDonutCard(
                width: cardWidth,
                title: "Payment Analytics",
                subtitle: "Payment completion overview",
                data: {
                  "Completed": payment["completed"] ?? 0,
                  "Pending": payment["pending"] ?? 0,
                  "Rejected": payment["rejected"] ?? 0,
                },
                colors: {
                  "Completed": Colors.green,
                  "Pending": Colors.orange,
                  "Rejected": Colors.red,
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonutCard({
    required double width,
    required String title,
    required String subtitle,
    required Map<String, dynamic> data,
    required Map<String, Color> colors,
  }) {
    final total = data.values.fold<num>(
      0,
          (sum, value) => sum + (value ?? 0),
    );

    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Title
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 20),

          /// Donut Chart
          Center(
            child: SizedBox(
              height: 140,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 45,
                  sectionsSpace: 3,
                  sections: data.entries.map((entry) {
                    final value =
                    (entry.value ?? 0).toDouble();

                    if (value == 0) {
                      return PieChartSectionData(
                        value: 0,
                        color: Colors.transparent,
                        title: "",
                        radius: 40,
                      );
                    }

                    return PieChartSectionData(
                      value: value,
                      color: colors[entry.key],
                      title: "",
                      radius: 40,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          /// Legend
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: data.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[entry.key],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${entry.key} (${entry.value})",
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
