import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/services.dart';

class PlanningManagerDetailScreen extends StatelessWidget {
  final String planningManagerId;

  const PlanningManagerDetailScreen({
    super.key,
    required this.planningManagerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        title: const Text(
          "Manager Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: PlanningManagerService()
            .getPlanningManagerById(planningManagerId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator(
                message: "Loading details...");
          }

          final m = snapshot.data!;
          final details = m["details"] ?? {};
          final bool isActive = m["status"] == "active";

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _card("Basic Information", [
                _info("Name", m["name"]),
                _info("Email", m["email"]),
                _info("Phone", m["phone"]),
                _info("Department", m["department"]),
                _info("Status", m["status"]),
              ]),
              const SizedBox(height: 16),
              _card("Employment Details", [
                _info("Employee ID",
                    details["employee_id"]),
                _info("Designation",
                    details["designation"]),
                _info("Reporting To",
                    details["reporting_to"]),
                _info("Join Date",
                    details["join_date"]),
                _info("Qualifications",
                    details["qualifications"]),
                _info("Notes", details["notes"]),
              ]),
              const SizedBox(height: 20),
              SwitchListTile(
                value: isActive,
                title:
                Text(isActive ? "Active" : "Inactive"),
                onChanged: (v) async {
                  await PlanningManagerService()
                      .toggleStatus(
                      planningManagerId:
                      planningManagerId,
                      activate: v);

                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PlanningManagerDetailScreen(
                              planningManagerId:
                              planningManagerId,
                            ),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(String title,
      List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _info(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(child: Text(value ?? "-")),
        ],
      ),
    );
  }
}
