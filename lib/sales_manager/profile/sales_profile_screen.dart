import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/cloudinary_service.dart';
import '../../core/theme/app_colors.dart';
import '../../../../services/api_service.dart';

class SalesProfileScreen extends StatefulWidget {
  const SalesProfileScreen({super.key});

  @override
  State<SalesProfileScreen> createState() => _SalesProfileScreenState();
}

class _SalesProfileScreenState extends State<SalesProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final genderCtrl = TextEditingController();

  final address1Ctrl = TextEditingController();
  final address2Ctrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final postcodeCtrl = TextEditingController();

  File? imageFile;
  String profileUrl = "";

  bool loading = false;
  bool pageLoading = true;

  String get salesManagerId => auth.currentUser!.uid;

  // =====================================================
  // LOAD PROFILE (API)
  // =====================================================

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final res =
      await ApiService.get('/sales-managers/$salesManagerId');

      final data = res['salesManager'];

      nameCtrl.text = data['name'] ?? "";
      phoneCtrl.text = data['phone'] ?? "";
      emailCtrl.text = data['email'] ?? auth.currentUser?.email ?? "";
      dobCtrl.text = data['dob'] ?? "";
      genderCtrl.text = data['gender'] ?? "";

      address1Ctrl.text = data['addressLine1'] ?? "";
      address2Ctrl.text = data['addressLine2'] ?? "";
      cityCtrl.text = data['city'] ?? "";
      stateCtrl.text = data['state'] ?? "";
      postcodeCtrl.text = data['postcode'] ?? "";

      profileUrl = data['profileImage'] ?? "";
    } catch (e) {
      debugPrint("LOAD PROFILE ERROR => $e");
      showMsg("Failed to load profile");
    } finally {
      if (mounted) setState(() => pageLoading = false);
    }
  }

  // =====================================================
  // PICK IMAGE
  // =====================================================

  Future<void> pickImage() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  // =====================================================
  // UPDATE PROFILE
  // =====================================================

  Future<void> updateProfile() async {
    if (nameCtrl.text.trim().isEmpty ||
        phoneCtrl.text.trim().isEmpty) {
      showMsg("Name and phone are required");
      return;
    }

    try {
      setState(() => loading = true);

      String imageUrl = profileUrl;

      if (imageFile != null) {
        imageUrl = await CloudinaryService().uploadFile(imageFile!);
      }

      await ApiService.patch(
        '/sales-managers/$salesManagerId',
        {
          'name': nameCtrl.text.trim(),
          'phone': phoneCtrl.text.trim(),
          'gender': genderCtrl.text.trim(),
          'dob': dobCtrl.text.trim(),
          'profileImage': imageUrl,
          'addressLine1': address1Ctrl.text.trim(),
          'addressLine2': address2Ctrl.text.trim(),
          'city': cityCtrl.text.trim(),
          'state': stateCtrl.text.trim(),
          'postcode': postcodeCtrl.text.trim(),
        },
      );

      if (emailCtrl.text.trim() != auth.currentUser?.email) {
        try {
          await auth.currentUser!
              .updateEmail(emailCtrl.text.trim());
        } catch (_) {
          showMsg("Re-login required to update email");
        }
      }

      showMsg("Profile updated successfully");
    } catch (e) {
      debugPrint("UPDATE PROFILE ERROR => $e");
      showMsg("Failed to update profile");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatar;

    if (imageFile != null) {
      avatar = FileImage(imageFile!);
    } else if (profileUrl.isNotEmpty) {
      avatar = NetworkImage(profileUrl);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: pageLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: avatar,
                child: avatar == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            buildField("Name", nameCtrl),
            buildField("Phone", phoneCtrl,
                keyboard: TextInputType.phone),
            buildField("Email", emailCtrl,
                keyboard: TextInputType.emailAddress),
            buildField("Gender", genderCtrl),
            buildField("DOB (YYYY-MM-DD)", dobCtrl),

            const Divider(height: 32),

            buildField("Address Line 1", address1Ctrl),
            buildField("Address Line 2", address2Ctrl),
            buildField("City", cityCtrl),
            buildField("State", stateCtrl),
            buildField("Postcode", postcodeCtrl),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: loading ? null : updateProfile,
                child: loading
                    ? const CircularProgressIndicator(
                    color: Colors.white)
                    : const Text(
                  "UPDATE PROFILE",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================

  Widget buildField(
      String label,
      TextEditingController controller, {
        TextInputType keyboard = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    dobCtrl.dispose();
    genderCtrl.dispose();
    address1Ctrl.dispose();
    address2Ctrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    postcodeCtrl.dispose();
    super.dispose();
  }
}
