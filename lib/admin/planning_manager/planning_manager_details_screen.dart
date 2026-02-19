import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/services.dart';

class PlanningManagerDetailScreen extends StatefulWidget {
  final String planningManagerId;

  const PlanningManagerDetailScreen({
    super.key,
    required this.planningManagerId,
  });

  @override
  State<PlanningManagerDetailScreen> createState() =>
      _PlanningManagerDetailScreenState();
}

class _PlanningManagerDetailScreenState
    extends State<PlanningManagerDetailScreen> {

  Map<String, dynamic>? manager;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await PlanningManagerService()
        .getPlanningManagerById(widget.planningManagerId);

    setState(() {
      manager = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: "Loading details..."),
      );
    }

    final m = manager!;
    final details = m["details"] ?? {};
    final bool isActive = m["status"] == "active";

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Planning Manager Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          /// ================= PROFILE CARD =================
          _profileCard(m),

          const SizedBox(height: 20),

          _card("Basic Information", [
            _info("Name", m["name"]),
            _info("Email", m["email"]),
            _info("Phone", m["phone"]),
            _info("Department", m["department"]),
            _info("Company", m["companyName"]),
            _info("Status", m["status"]),
          ]),

          const SizedBox(height: 16),

          _card("Employment Details", [
            _info("Employee ID", details["employee_id"]),
            _info("Designation", details["designation"]),
            _info("Reporting To", details["reporting_to"]),
            _info("Join Date", details["join_date"]),
            _info("Qualifications", details["qualifications"]),
            _info("Notes", details["notes"]),
          ]),

          const SizedBox(height: 20),

          SwitchListTile(
            value: isActive,
            title: Text(isActive ? "Active" : "Inactive"),
            onChanged: (v) async {
              await PlanningManagerService().toggleStatus(
                planningManagerId: widget.planningManagerId,
                activate: v,
              );
              _load();
            },
          ),
        ],
      ),
    );
  }

  Widget _profileCard(Map<String, dynamic> m) {
    final imageUrl = m["profileImage"];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor:
            AppColors.primaryBlue.withOpacity(0.15),
            backgroundImage: imageUrl != null &&
                imageUrl.toString().isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
            child: imageUrl == null ||
                imageUrl.toString().isEmpty
                ? const Icon(Icons.engineering,
                size: 45,
                color: AppColors.primaryBlue)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            m["name"] ?? "",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            m["email"] ?? "",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          SizedBox(width: 130, child: Text(label)),
          Expanded(child: Text(value?.toString().isNotEmpty == true ? value.toString() : "-")),
        ],
      ),
    );
  }
}
