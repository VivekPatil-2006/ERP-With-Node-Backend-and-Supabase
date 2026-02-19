import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TopManagersSection extends StatelessWidget {
  final List<Map<String, dynamic>> managers;

  const TopManagersSection({
    super.key,
    required this.managers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Top Sales Managers",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        managers.isEmpty
            ? const Center(child: Text("No manager data"))
            : Column(
          children: List.generate(
            managers.length,
                (index) => _buildManagerCard(
              managers[index],
              index + 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManagerCard(
      Map<String, dynamic> manager,
      int rank,
      ) {
    final name = manager["name"] ?? "Unknown";
    final revenue =
    (manager["totalRevenue"] ?? 0).toString();
    final paymentCount =
    (manager["paymentCount"] ?? 0).toString();
    final profileImage = manager["profileImage"];

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

          /// Rank
          CircleAvatar(
            radius: 16,
            backgroundColor:
            AppColors.primaryBlue.withOpacity(0.1),
            child: Text(
              "$rank",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// Profile Image
          CircleAvatar(
            radius: 22,
            backgroundImage: profileImage != null &&
                profileImage.toString().isNotEmpty
                ? NetworkImage(profileImage)
                : null,
            child: profileImage == null ||
                profileImage.toString().isEmpty
                ? const Icon(Icons.person)
                : null,
          ),

          const SizedBox(width: 14),

          /// Name + Revenue
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Revenue: ₹ $revenue",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          /// Payment Count
          Column(
            children: [
              Text(
                paymentCount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primaryBlue,
                ),
              ),
              const Text(
                "Payments",
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
        ],
      ),
    );
  }
}
