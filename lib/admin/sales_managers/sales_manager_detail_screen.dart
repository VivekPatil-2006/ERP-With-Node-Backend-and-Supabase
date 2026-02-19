import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/sales_manager_service.dart';

class SalesManagerDetailScreen extends StatefulWidget {
  final String managerId;

  const SalesManagerDetailScreen({
    super.key,
    required this.managerId,
  });

  @override
  State<SalesManagerDetailScreen> createState() =>
      _SalesManagerDetailScreenState();
}

class _SalesManagerDetailScreenState
    extends State<SalesManagerDetailScreen> {

  Map<String, dynamic>? manager;
  bool isLoading = true;
  bool isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadManager();
  }

  Future<void> _loadManager() async {
    final data =
    await SalesManagerService().getSalesManagerById(widget.managerId);

    setState(() {
      manager = data;
      isLoading = false;
    });
  }

  Future<void> _toggleStatus(bool value) async {
    if (manager == null) return;

    setState(() => isUpdatingStatus = true);

    await SalesManagerService().toggleStatus(
      managerId: widget.managerId,
      activate: value,
    );

    setState(() {
      manager!["status"] = value ? "active" : "inactive";
      isUpdatingStatus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: "Loading manager..."),
      );
    }

    final m = manager!;
    final bool isActive = m["status"] == "active";

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Sales Manager Details",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// ================= PROFILE CARD =================
            _profileCard(m),

            const SizedBox(height: 24),

            _section("Contact Information", [
              _row("Name", m["name"]),
              _row("Email", m["email"]),
              _row("Phone", m["phone"]),
              _row("Gender", m["gender"]),
              _row("DOB", m["dob"]),
            ]),

            const SizedBox(height: 20),

            _section("Address", [
              _row("Address 1", m["addressLine1"]),
              _row("Address 2", m["addressLine2"]),
              _row("City", m["city"]),
              _row("State", m["state"]),
              _row("Postcode", m["postcode"]),
            ]),

            const SizedBox(height: 20),

            _section("Sales Target", [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Monthly Target"),
                subtitle: Text("₹ ${m["salesTarget"] ?? 0}"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit,
                      color: AppColors.primaryBlue),
                  onPressed: _editTarget,
                ),
              ),
            ]),

            const SizedBox(height: 20),

            _statusCard(isActive),
          ],
        ),
      ),
    );
  }

  /// ================= PROFILE UI =================

  Widget _profileCard(Map<String, dynamic> m) {
    final imageUrl = m["profileImage"];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonBlue.withOpacity(0.08),
            blurRadius: 20,
          ),
        ],
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
                ? const Icon(Icons.person,
                size: 45,
                color: AppColors.primaryBlue)
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            m["name"] ?? "",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            m["email"] ?? "",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy)),
          const SizedBox(height: 14),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
              width: 130,
              child:
              Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : "-",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(bool isActive) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text("Account Status",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
              const SizedBox(height: 6),
              Text(
                isActive ? "Active" : "Inactive",
                style: TextStyle(
                  color:
                  isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Switch(
            value: isActive,
            activeColor: AppColors.primaryBlue,
            onChanged:
            isUpdatingStatus ? null : _toggleStatus,
          ),
        ],
      ),
    );
  }

  Future<void> _editTarget() async {
    final controller = TextEditingController(
      text: (manager?["salesTarget"] ?? 0).toString(),
    );

    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Set Sales Target"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration:
          const InputDecoration(labelText: "Target Amount"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, controller.text),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null) {
      final newTarget = int.tryParse(result);
      if (newTarget != null) {
        await SalesManagerService()
            .updateSalesTarget(
          managerId: widget.managerId,
          target: newTarget,
        );

        _loadManager();
      }
    }
  }
}
