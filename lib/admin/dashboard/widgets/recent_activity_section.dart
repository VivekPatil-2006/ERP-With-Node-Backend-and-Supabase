import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RecentActivitySection extends StatelessWidget {
  final Map<String, dynamic> activity;

  const RecentActivitySection({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final enquiries =
    List<Map<String, dynamic>>.from(activity["enquiries"] ?? []);

    final quotations =
    List<Map<String, dynamic>>.from(activity["quotations"] ?? []);

    final payments =
    List<Map<String, dynamic>>.from(activity["payments"] ?? []);

    final allActivities = [
      ...enquiries,
      ...quotations,
      ...payments,
    ];

    // Sort by timestamp descending
    allActivities.sort((a, b) {
      final aTime = DateTime.tryParse(a["timestamp"] ?? "") ??
          DateTime(2000);
      final bTime = DateTime.tryParse(b["timestamp"] ?? "") ??
          DateTime(2000);
      return bTime.compareTo(aTime);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Activity",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        allActivities.isEmpty
            ? const Center(child: Text("No recent activity"))
            : Column(
          children: List.generate(
            allActivities.length,
                (index) => _buildActivityCard(
              allActivities[index],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> item) {
    final type = item["type"] ?? "";
    final clientName = item["clientName"] ?? "Unknown";
    final status = item["status"] ?? "";
    final amount = item["amount"];
    final timestamp = item["timestamp"];

    final date = DateTime.tryParse(timestamp ?? "");
    final formattedDate =
    date != null
        ? "${date.day}/${date.month}/${date.year}"
        : "";

    IconData icon;
    Color iconColor;

    switch (type) {
      case "Enquiry":
        icon = Icons.help_outline;
        iconColor = Colors.orange;
        break;
      case "Quotation":
        icon = Icons.description_outlined;
        iconColor = Colors.blue;
        break;
      case "Payment":
        icon = Icons.payments_outlined;
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.circle;
        iconColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "$type - $clientName",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (amount != null)
                  Text(
                    "Amount: ₹ $amount",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                if (status.isNotEmpty)
                  Text(
                    "Status: $status",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),

          Text(
            formattedDate,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
