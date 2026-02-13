import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../shared/widgets/admin_drawer.dart';
import 'services/services.dart';

class PlanningManagerCreateScreen extends StatefulWidget {
  const PlanningManagerCreateScreen({super.key});

  @override
  State<PlanningManagerCreateScreen> createState() =>
      _PlanningManagerCreateScreenState();
}

class _PlanningManagerCreateScreenState
    extends State<PlanningManagerCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final profileImageCtrl = TextEditingController();
  final departmentCtrl =
  TextEditingController(text: "Planning & Production");
  final passwordCtrl = TextEditingController();
  final employeeIdCtrl = TextEditingController();
  final designationCtrl =
  TextEditingController(text: "Planning Manager");
  // final reportingToCtrl = TextEditingController();
  final joinDateCtrl = TextEditingController();
  final qualificationCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  String status = "active";
  bool isLoading = false;

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await PlanningManagerService().createPlanningManager(
        body: {
          "name": nameCtrl.text.trim(),
          "email": emailCtrl.text.trim(),
          "phone": phoneCtrl.text.trim(),
          "profile_image": profileImageCtrl.text.trim(),
          "department": departmentCtrl.text.trim(),
          "password": passwordCtrl.text.trim(),
          "employee_id": employeeIdCtrl.text.trim(),
          "designation": designationCtrl.text.trim(),
          // "reporting_to": reportingToCtrl.text.trim(),
          "join_date": joinDateCtrl.text.trim(),
          "qualifications": qualificationCtrl.text.trim(),
          "notes": notesCtrl.text.trim(),
          "status": status,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Planning Manager created.\nPassword reset email sent."),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
          context, '/listPlanningManager', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      joinDateCtrl.text =
      "${date.day}/${date.month}/${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text("Create Planning Manager",
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _sectionCard(
                title: "Basic Information",
                children: [
                  AppTextField(
                      controller: nameCtrl,
                      label: "Full Name",
                      validator: _required),
                  AppTextField(
                      controller: emailCtrl,
                      label: "Email",
                      validator: _required),
                  AppTextField(
                      controller: phoneCtrl,
                      label: "Phone"),
                  AppTextField(
                      controller: profileImageCtrl,
                      label: "Profile Image URL"),
                  AppTextField(
                      controller: departmentCtrl,
                      label: "Department"),
                  AppTextField(
                      controller: passwordCtrl,
                      label: "Password",
                      obscureText: true,
                      validator: _required),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration:
                    _dropdownDecoration("Status"),
                    items: const [
                      DropdownMenuItem(
                          value: "active",
                          child: Text("Active")),
                      DropdownMenuItem(
                          value: "inactive",
                          child: Text("Inactive")),
                    ],
                    onChanged: (v) => status = v!,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _sectionCard(
                title: "Employment Details",
                children: [
                  AppTextField(
                      controller: employeeIdCtrl,
                      label: "Employee ID"),
                  AppTextField(
                      controller: designationCtrl,
                      label: "Designation"),
                  // AppTextField(
                  //     controller: reportingToCtrl,
                  //     label: "Reporting To"),
                  AppTextField(
                    controller: joinDateCtrl,
                    label: "Join Date",
                    readOnly: true,
                    onTap: _pickDate,
                  ),
                  AppTextField(
                      controller: qualificationCtrl,
                      label: "Qualifications"),
                  AppTextField(
                      controller: notesCtrl,
                      label: "Notes",
                      maxLines: 3),
                ],
              ),

              const SizedBox(height: 30),

              AppButton(
                label: "Create Planning Manager",
                isLoading: isLoading,
                onPressed: _create,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border:
        Border.all(color: AppColors.navy, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy)),
          const SizedBox(height: 16),
          ...children
              .map((e) => Padding(
            padding:
            const EdgeInsets.only(bottom: 14),
            child: e,
          ))
              .toList(),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(
      String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  String? _required(String? v) =>
      v == null || v.isEmpty ? "Required" : null;
}


class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;

  // ✅ ADD THESE TWO
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.readOnly = false, // ✅ default
    this.onTap,            // ✅ optional
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,   // ✅ use it
      onTap: onTap,         // ✅ use it
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
