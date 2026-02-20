import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'services/services.dart';
import '../shared/widgets/planning_manager_drawer.dart';

class PlanningManagerProfileScreen extends StatefulWidget {
  const PlanningManagerProfileScreen({super.key});

  @override
  State<PlanningManagerProfileScreen> createState() =>
      _PlanningManagerProfileScreenState();
}

class _PlanningManagerProfileScreenState
    extends State<PlanningManagerProfileScreen> {
  bool loading = true;
  bool editing = false;

  Map<String, dynamic>? profile;
  Map<String, dynamic>? details;
  String? companyName;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _reportingToCtrl = TextEditingController();
  final _qualificationsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final service = PlanningManagerService();
    final id = await service.getPlanningManagerId();
    final data = await service.getPlanningManagerProfile(id);

    setState(() {
      profile = data;
      details = data["details"];
      companyName = data["company_name"];

      _nameCtrl.text = profile?["name"] ?? "";
      _phoneCtrl.text = profile?["phone"] ?? "";
      _designationCtrl.text = details?["designation"] ?? "";
      _reportingToCtrl.text = details?["reporting_to"] ?? "";
      _qualificationsCtrl.text = details?["qualifications"] ?? "";
      _notesCtrl.text = details?["notes"] ?? "";

      loading = false;
    });
  }

  Future<void> _saveProfile() async {
    final service = PlanningManagerService();
    final id = await service.getPlanningManagerId();

    setState(() => loading = true);

    final updated = await service.updatePlanningManager(
      planningManagerId: id,
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      designation: _designationCtrl.text,
      reportingTo: _reportingToCtrl.text,
      qualifications: _qualificationsCtrl.text,
      notes: _notesCtrl.text,
    );

    setState(() {
      profile = updated;
      details = updated["details"];
      editing = false;
      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      drawer: const PlanningManagerDrawer(
        currentRoute: '/planning_manager/profile',
      ),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: Icon(editing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => editing = !editing),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section("Basic Information"),
            editing
                ? _input("Name", _nameCtrl)
                : _row("Name", profile!["name"]),
            editing
                ? _input("Phone", _phoneCtrl)
                : _row("Phone", profile!["phone"]),
            _row("Email", profile!["email"]),

            const SizedBox(height: 20),
            _section("Employment Details"),
            editing
                ? _input("Designation", _designationCtrl)
                : _row("Designation", details?["designation"]),
            editing
                ? _input("Reporting To", _reportingToCtrl)
                : _row("Reporting To", details?["reporting_to"]),

            const SizedBox(height: 20),
            _section("Additional Information"),
            editing
                ? _input("Qualifications", _qualificationsCtrl)
                : _row("Qualifications", details?["qualifications"]),
            editing
                ? _input("Notes", _notesCtrl, maxLines: 3)
                : _row("Notes", details?["notes"]),

            const SizedBox(height: 20),
            _section("Account Information"),
            _row("Company", companyName),
            _row("Created At", profile!["created_at"]),

            if (editing)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => editing = false);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          side: BorderSide(color: AppColors.navy),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )

          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title,
        style:
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget _row(String label, String? value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(
            width: 140,
            child: Text(label,
                style:
                const TextStyle(fontWeight: FontWeight.w600))),
        Expanded(child: Text(value ?? "-")),
      ],
    ),
  );

  Widget _input(String label, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
