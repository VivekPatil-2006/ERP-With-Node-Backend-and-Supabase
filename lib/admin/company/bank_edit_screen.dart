import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/company_service.dart';

class BankEditScreen extends StatefulWidget {
  const BankEditScreen({super.key});

  @override
  State<BankEditScreen> createState() => _BankEditScreenState();
}

class _BankEditScreenState extends State<BankEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final bankNameCtrl = TextEditingController();
  final branchCtrl = TextEditingController();
  final accountHolderCtrl = TextEditingController();
  final accountNoCtrl = TextEditingController();
  final ifscCtrl = TextEditingController();
  final upiCtrl = TextEditingController();

  String accountType = 'saving';
  String? qrValue;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBankData();
  }

  @override
  void dispose() {
    bankNameCtrl.dispose();
    branchCtrl.dispose();
    accountHolderCtrl.dispose();
    accountNoCtrl.dispose();
    ifscCtrl.dispose();
    upiCtrl.dispose();
    super.dispose();
  }

  // ================= LOAD =================

  Future<void> _loadBankData() async {
    try {
      final data = await CompanyService().getCompany();
      final bank = data['bankDetails'] ?? {};

      bankNameCtrl.text = bank['bankName'] ?? '';
      branchCtrl.text = bank['branchName'] ?? '';
      accountHolderCtrl.text = bank['accountHolderName'] ?? '';
      accountNoCtrl.text = bank['bankAccountNumber'] ?? '';
      ifscCtrl.text = bank['ifscCode'] ?? '';
      upiCtrl.text = bank['upiId'] ?? '';
      accountType = bank['accountType'] ?? 'saving';
      qrValue = bank['scannerImage'];

      setState(() => isLoading = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load bank details: $e")),
      );
      setState(() => isLoading = false);
    }
  }

  // ================= SAVE =================

  Future<void> _saveBank() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => isLoading = true);

      await CompanyService().updateCompany({
        'bankDetails': {
          'bankName': bankNameCtrl.text.trim(),
          'branchName': branchCtrl.text.trim(),
          'accountHolderName': accountHolderCtrl.text.trim(),
          'bankAccountNumber': accountNoCtrl.text.trim(),
          'ifscCode': ifscCtrl.text.trim(),
          'upiId': upiCtrl.text.trim(),
          'accountType': accountType,
          'scannerImage': qrValue,
        },
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bank details updated successfully")),
      );

      Navigator.pop(context, true); // 🔥 Important for real-time refresh
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
  }

  // ================= IMAGE PICKER =================

  Future<void> _pickQr() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() => qrValue = base64Encode(bytes));
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Loading bank details...'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Edit Bank Details'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // 🏦 BANK INFO
              _section('Bank Information', [
                AppTextField(
                  controller: bankNameCtrl,
                  label: 'Bank Name',
                  validator: _required,
                ),
                AppTextField(
                  controller: branchCtrl,
                  label: 'Branch Name',
                ),
                AppTextField(
                  controller: accountHolderCtrl,
                  label: 'Account Holder Name',
                  validator: _required,
                ),
                AppTextField(
                  controller: accountNoCtrl,
                  label: 'Account Number',
                  keyboardType: TextInputType.number,
                  validator: _required,
                ),
                AppTextField(
                  controller: ifscCtrl,
                  label: 'IFSC Code',
                ),
                AppTextField(
                  controller: upiCtrl,
                  label: 'UPI ID',
                ),
                DropdownButtonFormField<String>(
                  value: ['saving', 'current'].contains(accountType)
                      ? accountType
                      : 'saving',
                  decoration: const InputDecoration(
                    labelText: 'Account Type',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'saving',
                      child: Text('Saving'),
                    ),
                    DropdownMenuItem(
                      value: 'current',
                      child: Text('Current'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => accountType = v);
                    }
                  },
                ),
              ]),

              const SizedBox(height: 20),

              // 🖼️ QR IMAGE
              _section('QR / Scanner Image', [
                _imagePickerRow(
                  label: 'UPI QR Code',
                  value: qrValue,
                  onPick: _pickQr,
                ),
              ]),

              const SizedBox(height: 30),

              AppButton(
                label: 'Save Bank Details',
                isLoading: isLoading,
                onPressed: _saveBank,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          ...children.map(
                (e) => Padding(
              padding:
              const EdgeInsets.only(bottom: 12),
              child: e,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePickerRow({
    required String label,
    required String? value,
    required VoidCallback onPick,
  }) {
    return Row(
      children: [
        SizedBox(width: 140, child: Text(label)),
        Expanded(
          child: InkWell(
            onTap: onPick,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: value != null && value.isNotEmpty
                  ? value.startsWith("http")
                  ? Image.network(value)
                  : Image.memory(base64Decode(value))
                  : const Center(
                child: Text('Tap to upload QR'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _required(String? v) =>
      v == null || v.isEmpty ? 'Required' : null;
}
