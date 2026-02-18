import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/cloudinary_service.dart';
import '../../core/theme/app_colors.dart';
import '../shared_widgets/client_drawer.dart';
import 'services/client_services.dart';

class ClientProfileScreen extends StatefulWidget {
  final String clientId;

  const ClientProfileScreen({
    super.key,
    required this.clientId,
  });

  @override
  State<ClientProfileScreen> createState() =>
      _ClientProfileScreenState();
}

class _ClientProfileScreenState
    extends State<ClientProfileScreen> {
  bool editMode = false;
  bool saving = false;
  bool uploadingImage = false;

  File? selectedImage;

  final Map<String, TextEditingController> controllers = {};
  bool controllersInitialized = false;

  void initControllers(Map<String, dynamic> data) {
    if (controllersInitialized) return;

    final fields = [
      'companyName',
      'firstName',
      'lastName',
      'emailAddress',
      'phoneNo1',
      'phoneNo2',
      'cellphone',
      'faxNo',
      'street',
      'city',
      'state',
      'postcode',
      'country',
      'contactPerson',
    ];

    for (final f in fields) {
      controllers[f] =
          TextEditingController(text: data[f]?.toString() ?? '');
    }

    controllersInitialized = true;
  }

  Future<void> pickProfileImage() async {
    if (!editMode) return;

    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> uploadProfileImage() async {
    if (selectedImage == null) return null;

    try {
      setState(() => uploadingImage = true);
      return await CloudinaryService().uploadFile(selectedImage!);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed')),
      );
      return null;
    } finally {
      if (mounted) setState(() => uploadingImage = false);
    }
  }

  Future<void> saveProfile() async {
    try {
      setState(() => saving = true);

      final Map<String, dynamic> payload = {};

      controllers.forEach((key, controller) {
        payload[key] = controller.text.trim();
      });

      if (selectedImage != null) {
        final imageUrl = await uploadProfileImage();
        if (imageUrl != null) {
          payload['profileImage'] = imageUrl;
        }
      }

      await ClientService().updateClient(
        clientId: widget.clientId,
        data: payload,
      );

      setState(() {
        editMode = false;
        selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,

      // ================= DRAWER =================
      drawer: const ClientDrawer(
        currentRoute: '/clientProfile',
      ),

      appBar: AppBar(
        title: const Text(
          'Client Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(editMode ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                editMode = !editMode;
                selectedImage = null;
              });
            },
          ),
        ],
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: ClientService().getClientById(widget.clientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(
                child: Text('Client not found'));
          }

          final data = snapshot.data!;
          initControllers(data);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickProfileImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor:
                        AppColors.primaryBlue.withOpacity(0.1),
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : (data['profileImage'] != null &&
                            data['profileImage']
                                .toString()
                                .isNotEmpty)
                            ? NetworkImage(
                            data['profileImage'])
                            : null,
                        child: selectedImage == null &&
                            (data['profileImage'] == null ||
                                data['profileImage']
                                    .toString()
                                    .isEmpty)
                            ? const Icon(
                          Icons.business,
                          size: 40,
                          color:
                          AppColors.primaryBlue,
                        )
                            : null,
                      ),
                      if (editMode)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor:
                            AppColors.primaryBlue,
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (uploadingImage)
                        const Positioned.fill(
                          child: Center(
                            child:
                            CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                buildSection('Basic Info', [
                  buildField('Company Name', 'companyName'),
                  buildField('Contact Person', 'contactPerson'),
                  buildField('First Name', 'firstName'),
                  buildField('Last Name', 'lastName'),
                  buildField('Email', 'emailAddress'),
                ]),

                buildSection('Contact Details', [
                  buildField('Phone 1', 'phoneNo1'),
                  buildField('Phone 2', 'phoneNo2'),
                  buildField('Cellphone', 'cellphone'),
                  buildField('Fax', 'faxNo'),
                ]),

                buildSection('Address', [
                  buildField('Street', 'street'),
                  buildField('City', 'city'),
                  buildField('State', 'state'),
                  buildField('Postcode', 'postcode'),
                  buildField('Country', 'country'),
                ]),

                if (editMode)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saving ? null : saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 14),
                      ),
                      child: saving
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text('SAVE CHANGES'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget buildField(String label, String key) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
          const SizedBox(height: 4),
          editMode
              ? TextField(
            controller: controllers[key],
            decoration:
            const InputDecoration(
              border:
              OutlineInputBorder(),
              isDense: true,
            ),
          )
              : Text(
            controllers[key]!
                .text
                .isEmpty
                ? '-'
                : controllers[key]!.text,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
