// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// //
// // import '../../core/theme/app_colors.dart';
// //
// // class CreateEnquiryScreen extends StatefulWidget {
// //   const CreateEnquiryScreen({super.key});
// //
// //   @override
// //   State<CreateEnquiryScreen> createState() => _CreateEnquiryScreenState();
// // }
// //
// // class _CreateEnquiryScreenState extends State<CreateEnquiryScreen> {
// //
// //   final firestore = FirebaseFirestore.instance;
// //   final auth = FirebaseAuth.instance;
// //
// //   String? selectedClientId;
// //   String? selectedProductId;
// //
// //   Map<String, dynamic>? selectedProductData;
// //
// //   String companyId = "";
// //
// //   final titleCtrl = TextEditingController();
// //   final descCtrl = TextEditingController();
// //   final qtyCtrl = TextEditingController(text: "1");
// //
// //   DateTime? expectedDate;
// //   String? selectedSource;
// //
// //   final List<String> enquirySources = [
// //     "by walking",
// //     "by email",
// //     "by reference",
// //     "by phone",
// //     "other",
// //   ];
// //
// //   bool loading = false;
// //
// //   // ============================
// //   // INIT
// //   // ============================
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     loadCompanyId();
// //   }
// //
// //   Future<void> loadCompanyId() async {
// //
// //     final uid = auth.currentUser!.uid;
// //
// //     final snap = await firestore
// //         .collection("sales_managers")
// //         .doc(uid)
// //         .get();
// //
// //     companyId = snap.data()?['companyId'] ?? "";
// //
// //     if (mounted) {
// //       setState(() {});
// //     }
// //   }
// //
// //   // ============================
// //   // FETCH CLIENTS
// //   // ============================
// //
// //   Future<List<QueryDocumentSnapshot>> fetchClients() async {
// //
// //     if (companyId.isEmpty) return [];
// //
// //     final snap = await firestore
// //         .collection("clients")
// //         .where("companyId", isEqualTo: companyId)
// //         .get();
// //
// //     return snap.docs;
// //   }
// //
// //   // ============================
// //   // FETCH PRODUCTS
// //   // ============================
// //
// //   Future<List<QueryDocumentSnapshot>> fetchProducts() async {
// //
// //     if (companyId.isEmpty) return [];
// //
// //     final snap = await firestore
// //         .collection("products")
// //         .where("companyId", isEqualTo: companyId)
// //         .where("active", isEqualTo: true)
// //         .get();
// //
// //     return snap.docs;
// //   }
// //
// //   // ============================
// //   // CREATE ENQUIRY
// //   // ============================
// //
// //   Future<void> createEnquiry() async {
// //
// //     if (selectedClientId == null) {
// //       showMsg("Select client");
// //       return;
// //     }
// //
// //     if (selectedProductId == null) {
// //       showMsg("Select product");
// //       return;
// //     }
// //
// //     if (selectedSource == null) {
// //       showMsg("Select enquiry source");
// //       return;
// //     }
// //
// //     if (expectedDate == null) {
// //       showMsg("Select expected date");
// //       return;
// //     }
// //
// //     if (titleCtrl.text.trim().isEmpty) {
// //       showMsg("Enter enquiry title");
// //       return;
// //     }
// //
// //     final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;
// //
// //     if (qty <= 0) {
// //       showMsg("Enter valid quantity");
// //       return;
// //     }
// //
// //     try {
// //
// //       setState(() => loading = true);
// //
// //       await firestore.collection("enquiries").add({
// //
// //         "companyId": companyId,
// //
// //         "clientId": selectedClientId,
// //         "salesManagerId": auth.currentUser!.uid,
// //
// //         "productId": selectedProductId,
// //         "quantity": qty,
// //
// //         "productSnapshot": selectedProductData,
// //
// //         "title": titleCtrl.text.trim(),
// //         "description": descCtrl.text.trim(),
// //
// //         "source": selectedSource,
// //         "expectedDate": Timestamp.fromDate(expectedDate!), // ✅ correct
// //
// //         "status": "raised",
// //         "createdAt": Timestamp.now(),
// //       });
// //
// //       showMsg("Enquiry Created Successfully");
// //       Navigator.pop(context);
// //
// //     } catch (e) {
// //
// //       debugPrint("Create Enquiry Error => $e");
// //       showMsg("Failed to create enquiry");
// //
// //     } finally {
// //
// //       if (mounted) {
// //         setState(() => loading = false);
// //       }
// //     }
// //   }
// //
// //   // ============================
// //   // DATE PICKER
// //   // ============================
// //
// //   Future<void> pickExpectedDate() async {
// //
// //     final picked = await showDatePicker(
// //       context: context,
// //       firstDate: DateTime.now(),
// //       lastDate: DateTime.now().add(const Duration(days: 365)),
// //       initialDate: DateTime.now(),
// //     );
// //
// //     if (picked != null) {
// //       setState(() => expectedDate = picked);
// //     }
// //   }
// //
// //   // ============================
// //   // SNACKBAR
// //   // ============================
// //
// //   void showMsg(String msg) {
// //     ScaffoldMessenger.of(context)
// //         .showSnackBar(SnackBar(content: Text(msg)));
// //   }
// //
// //   // ============================
// //   // UI
// //   // ============================
// //
// //   @override
// //   Widget build(BuildContext context) {
// //
// //     return Scaffold(
// //
// //       appBar: AppBar(
// //         title: const Text("Create Enquiry"),
// //         backgroundColor: AppColors.darkBlue,
// //         foregroundColor: Colors.white,
// //       ),
// //
// //       bottomNavigationBar: Padding(
// //         padding: const EdgeInsets.all(12),
// //
// //         child: ElevatedButton(
// //           style: ElevatedButton.styleFrom(
// //             backgroundColor: AppColors.darkBlue,
// //             padding: const EdgeInsets.symmetric(vertical: 16),
// //           ),
// //
// //           onPressed: loading ? null : createEnquiry,
// //
// //           child: loading
// //               ? const SizedBox(
// //             height: 20,
// //             width: 20,
// //             child: CircularProgressIndicator(
// //               strokeWidth: 2,
// //               color: Colors.white,
// //             ),
// //           )
// //               : const Text(
// //             "CREATE ENQUIRY",
// //             style: TextStyle(fontSize: 16, color: Colors.white),
// //           ),
// //         ),
// //       ),
// //
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(16),
// //
// //         child: Column(
// //           children: [
// //
// //             // ================= CLIENT =================
// //
// //             buildCard(
// //               title: "Client Selection",
// //               icon: Icons.people,
// //
// //               child: FutureBuilder(
// //                 future: fetchClients(),
// //
// //                 builder: (context, snapshot) {
// //
// //                   if (!snapshot.hasData) {
// //                     return const LinearProgressIndicator();
// //                   }
// //
// //                   final clients = snapshot.data!;
// //
// //                   if (clients.isEmpty) {
// //                     return const Text("No clients found");
// //                   }
// //
// //                   return DropdownButtonFormField<String>(
// //                     decoration: const InputDecoration(
// //                       prefixIcon: Icon(Icons.person),
// //                       border: OutlineInputBorder(),
// //                       labelText: "Select Client",
// //                     ),
// //
// //                     items: clients.map((c) {
// //                       return DropdownMenuItem(
// //                         value: c.id,
// //                         child: Text(c['companyName']),
// //                       );
// //                     }).toList(),
// //
// //                     onChanged: (val) {
// //                       selectedClientId = val;
// //                     },
// //                   );
// //                 },
// //               ),
// //             ),
// //
// //             const SizedBox(height: 16),
// //
// //             // ================= PRODUCT =================
// //
// //             buildCard(
// //               title: "Product Selection",
// //               icon: Icons.shopping_bag,
// //
// //               child: FutureBuilder(
// //                 future: fetchProducts(),
// //
// //                 builder: (context, snapshot) {
// //
// //                   if (!snapshot.hasData) {
// //                     return const LinearProgressIndicator();
// //                   }
// //
// //                   final products = snapshot.data!;
// //
// //                   if (products.isEmpty) {
// //                     return const Text("No active products");
// //                   }
// //
// //                   return DropdownButtonFormField<String>(
// //                     decoration: const InputDecoration(
// //                       prefixIcon: Icon(Icons.inventory),
// //                       border: OutlineInputBorder(),
// //                       labelText: "Select Product",
// //                     ),
// //
// //                     items: products.map((p) {
// //
// //                       final data =
// //                       p.data() as Map<String, dynamic>;
// //
// //                       return DropdownMenuItem(
// //                         value: p.id,
// //                         child: Text(data['title']),
// //                       );
// //                     }).toList(),
// //
// //                     onChanged: (val) async {
// //
// //                       if (val == null) return;
// //
// //                       selectedProductId = val;
// //                       selectedProductData = null;
// //
// //                       final snap = await firestore
// //                           .collection("products")
// //                           .doc(val)
// //                           .get();
// //
// //                       if (snap.exists) {
// //                         setState(() {
// //                           selectedProductData = snap.data();
// //                         });
// //                       }
// //                     },
// //                   );
// //                 },
// //               ),
// //             ),
// //
// //             // ================= PRODUCT PREVIEW =================
// //
// //             if (selectedProductData != null) ...[
// //
// //               const SizedBox(height: 14),
// //
// //               buildProductPreview(selectedProductData!),
// //
// //               const SizedBox(height: 12),
// //
// //               buildInput(
// //                 controller: qtyCtrl,
// //                 label: "Quantity",
// //                 icon: Icons.production_quantity_limits,
// //                 isNumber: true,
// //               ),
// //             ],
// //
// //             const SizedBox(height: 16),
// //
// //             // ================= ENQUIRY DETAILS =================
// //
// //             buildCard(
// //               title: "Enquiry Details",
// //               icon: Icons.assignment,
// //
// //               child: Column(
// //                 children: [
// //
// //                   DropdownButtonFormField<String>(
// //                     value: selectedSource,
// //                     decoration: const InputDecoration(
// //                       prefixIcon: Icon(Icons.source),
// //                       border: OutlineInputBorder(),
// //                       labelText: "Source Of Enquiry",
// //                     ),
// //
// //                     items: enquirySources.map((e) {
// //                       return DropdownMenuItem(
// //                         value: e,
// //                         child: Text(e),
// //                       );
// //                     }).toList(),
// //
// //                     onChanged: (val) {
// //                       setState(() => selectedSource = val);
// //                     },
// //                   ),
// //
// //                   const SizedBox(height: 12),
// //
// //                   OutlinedButton.icon(
// //                     icon: const Icon(Icons.calendar_today),
// //                     label: Text(
// //                       expectedDate == null
// //                           ? "Select Expected Date"
// //                           : expectedDate!
// //                           .toString()
// //                           .split(" ")[0],
// //                     ),
// //                     onPressed: pickExpectedDate,
// //                   ),
// //
// //                   const SizedBox(height: 12),
// //
// //                   buildInput(
// //                     controller: titleCtrl,
// //                     label: "Enquiry Title",
// //                     icon: Icons.title,
// //                   ),
// //
// //                   const SizedBox(height: 12),
// //
// //                   buildInput(
// //                     controller: descCtrl,
// //                     label: "Description",
// //                     icon: Icons.description,
// //                     maxLines: 3,
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ================= PRODUCT PREVIEW =================
// //
// //   Widget buildProductPreview(Map<String, dynamic> p) {
// //
// //     final pricing = p['pricing'] ?? {};
// //
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //
// //       decoration: BoxDecoration(
// //         color: AppColors.lightGrey,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey.shade300),
// //       ),
// //
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //
// //           Text(
// //             p['title'],
// //             style: const TextStyle(fontWeight: FontWeight.bold),
// //           ),
// //
// //           const Divider(),
// //
// //           infoRow("Item No", p['itemNo'] ?? "-"),
// //           infoRow("Base Price", "₹ ${pricing['basePrice'] ?? '-'}"),
// //           infoRow("Discount", "${p['discountPercent'] ?? 0}%"),
// //           infoRow("Stock", p['stock']?.toString() ?? "-"),
// //           infoRow("Size", p['size'] ?? "-"),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget infoRow(String label, String value) {
// //
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 4),
// //
// //       child: Row(
// //         children: [
// //           SizedBox(
// //             width: 120,
// //             child: Text("$label:",
// //                 style: const TextStyle(fontWeight: FontWeight.w600)),
// //           ),
// //           Expanded(child: Text(value)),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ================= UI HELPERS =================
// //
// //   Widget buildCard({
// //     required String title,
// //     required IconData icon,
// //     required Widget child,
// //   }) {
// //
// //     return Container(
// //       padding: const EdgeInsets.all(14),
// //
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(14),
// //         boxShadow: [
// //           BoxShadow(
// //             blurRadius: 6,
// //             color: Colors.black.withOpacity(0.05),
// //           ),
// //         ],
// //       ),
// //
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //
// //           Row(
// //             children: [
// //               Icon(icon, color: AppColors.darkBlue),
// //               const SizedBox(width: 8),
// //               Text(title,
// //                   style: const TextStyle(fontWeight: FontWeight.bold)),
// //             ],
// //           ),
// //
// //           const Divider(),
// //
// //           child,
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget buildInput({
// //     required TextEditingController controller,
// //     required String label,
// //     required IconData icon,
// //     int maxLines = 1,
// //     bool isNumber = false,
// //   }) {
// //
// //     return TextField(
// //       controller: controller,
// //       maxLines: maxLines,
// //       keyboardType:
// //       isNumber ? TextInputType.number : TextInputType.text,
// //
// //       decoration: InputDecoration(
// //         labelText: label,
// //         prefixIcon: Icon(icon),
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     titleCtrl.dispose();
// //     descCtrl.dispose();
// //     qtyCtrl.dispose();
// //     super.dispose();
// //   }
// // }
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '../../core/theme/app_colors.dart';
// import 'services/services.dart';
//
// class EnquiryDetailsScreen extends StatefulWidget {
//   final String enquiryId;
//
//   const EnquiryDetailsScreen({super.key, required this.enquiryId});
//
//   @override
//   State<EnquiryDetailsScreen> createState() =>
//       _EnquiryDetailsScreenState();
// }
//
// class _EnquiryDetailsScreenState extends State<EnquiryDetailsScreen> {
//   bool loading = true;
//   Map<String, dynamic>? enquiry;
//
//   @override
//   void initState() {
//     super.initState();
//     loadDetails();
//   }
//
//   Future<void> loadDetails() async {
//     try {
//       enquiry =
//       await EnquiryService().getEnquiryDetails(widget.enquiryId);
//     } finally {
//       setState(() => loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final createdAt = enquiry?['createdAt'] != null
//         ? DateTime.tryParse(enquiry!['createdAt'])
//         : null;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Enquiry Details"),
//         backgroundColor: AppColors.darkBlue,
//         foregroundColor: Colors.white,
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : enquiry == null
//           ? const Center(child: Text("Enquiry not found"))
//           : Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Title: ${enquiry!['title']}"),
//             Text("Status: ${enquiry!['status']}"),
//             Text("Source: ${enquiry!['source']}"),
//             if (createdAt != null)
//               Text(
//                 "Created: ${DateFormat.yMMMd().format(createdAt)}",
//               ),
//             const SizedBox(height: 12),
//             Text(enquiry!['description'] ?? "-"),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../../../services/api_service.dart';
import 'services/services.dart';

class CreateEnquiryScreen extends StatefulWidget {
  const CreateEnquiryScreen({super.key});

  @override
  State<CreateEnquiryScreen> createState() => _CreateEnquiryScreenState();
}

class _CreateEnquiryScreenState extends State<CreateEnquiryScreen> {
  // ============================
  // STATE
  // ============================

  bool selecting = false;

  String? selectedClientId;
  String? selectedProductId;

  Map<String, dynamic>? selectedClientData;
  Map<String, dynamic>? selectedProductData;

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: "1");

  DateTime? expectedDate;
  String? selectedSource;

  bool loading = false;

  final List<String> enquirySources = const [
    "by walking",
    "by email",
    "by reference",
    "by phone",
    "other",
  ];

  // ============================
  // FETCH CLIENTS
  // ============================

  Future<List<Map<String, dynamic>>> fetchClients() async {
    final response = await ApiService.get('/clients');
    return List<Map<String, dynamic>>.from(response['clients'] ?? []);
  }

  // ============================
  // FETCH PRODUCTS
  // ============================

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final response = await ApiService.get('/products');
    return List<Map<String, dynamic>>.from(response['products'] ?? []);
  }

  // ============================
  // CREATE ENQUIRY
  // ============================

  Future<void> createEnquiry() async {
    if (selectedClientId == null) {
      showMsg("Select client");
      return;
    }
    if (selectedProductId == null) {
      showMsg("Select product");
      return;
    }
    if (selectedSource == null) {
      showMsg("Select enquiry source");
      return;
    }
    if (expectedDate == null) {
      showMsg("Select expected date");
      return;
    }
    if (titleCtrl.text.trim().isEmpty) {
      showMsg("Enter enquiry title");
      return;
    }

    final qtyText = qtyCtrl.text.trim();
    final int? qty =
    qtyText.isNotEmpty ? int.tryParse(qtyText) : null;

    if (qtyText.isNotEmpty && (qty == null || qty <= 0)) {
      showMsg("Enter valid quantity");
      return;
    }

    try {
      setState(() => loading = true);

      await EnquiryService().createEnquiry(
        clientId: selectedClientId!,
        productId: selectedProductId!,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        quantity: qty, // ✅ optional quantity
        source: selectedSource,
        expectedDate: expectedDate,
      );

      showMsg("Enquiry Created Successfully");
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Create Enquiry Error => $e");
      showMsg("Failed to create enquiry");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ============================
  // DATE PICKER
  // ============================

  Future<void> pickExpectedDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (picked != null) setState(() => expectedDate = picked);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ============================
  // UI
  // ============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Enquiry"),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),



      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: loading ? null : createEnquiry,
          child: loading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text(
            "CREATE ENQUIRY",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),

      body: Stack(
          children: [
      SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          // ================= CLIENT =================
            buildCard(
              title: "Client Selection",
              icon: Icons.people,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchClients(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final clients = snapshot.data!;
                  if (clients.isEmpty) {
                    return const Text("No clients found");
                  }

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      labelText: "Select Client",
                    ),
                    items: clients.map((c) {
                      final name =
                      "${c['firstName'] ?? ''} ${c['lastName'] ?? ''}"
                          .trim();
                      return DropdownMenuItem<String>(
                        value: c['clientId'],
                        child: Text(
                          name.isNotEmpty
                              ? name
                              : (c['companyName'] ?? "-"),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) async {
                      setState(() => selecting = true);

                      await Future.delayed(const Duration(milliseconds: 400));

                      selectedClientId = val;
                      selectedClientData =
                          clients.firstWhere((c) => c['clientId'] == val);

                      if (mounted) {
                        setState(() => selecting = false);
                      }
                    },
                  );
                },
              ),
            ),

            // ================= CLIENT PREVIEW =================
            if (selectedClientData != null) ...[
              const SizedBox(height: 12),
              buildClientPreview(selectedClientData!),
            ],

            const SizedBox(height: 16),

            // ================= PRODUCT =================
            buildCard(
              title: "Product Selection",
              icon: Icons.shopping_bag,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchProducts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  final products = snapshot.data!;
                  if (products.isEmpty) {
                    return const Text("No active products");
                  }

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.inventory),
                      border: OutlineInputBorder(),
                      labelText: "Select Product",
                    ),
                    items: products.map((p) {
                      return DropdownMenuItem<String>(
                        value: p['productId'],
                        child: Text(p['title']),
                      );
                    }).toList(),
                    onChanged: (val) async {
                      setState(() => selecting = true);

                      await Future.delayed(const Duration(milliseconds: 400));

                      selectedProductId = val;
                      selectedProductData =
                          products.firstWhere((p) => p['productId'] == val);

                      if (mounted) {
                        setState(() => selecting = false);
                      }
                    },

                  );
                },
              ),
            ),

            if (selectedProductData != null) ...[
              const SizedBox(height: 14),
              buildProductPreview(selectedProductData!),
              const SizedBox(height: 12),
              buildInput(
                controller: qtyCtrl,
                label: "Quantity",
                icon: Icons.production_quantity_limits,
                isNumber: true,
              ),
            ],

            const SizedBox(height: 16),

            // ================= ENQUIRY DETAILS =================
            buildCard(
              title: "Enquiry Details",
              icon: Icons.assignment,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedSource,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.source),
                      border: OutlineInputBorder(),
                      labelText: "Source Of Enquiry",
                    ),
                    items: enquirySources
                        .map(
                          (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ),
                    )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedSource = val),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      expectedDate == null
                          ? "Select Expected Date"
                          : expectedDate!.toString().split(" ")[0],
                    ),
                    onPressed: pickExpectedDate,
                  ),
                  const SizedBox(height: 12),
                  buildInput(
                    controller: titleCtrl,
                    label: "Enquiry Title",
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 12),
                  buildInput(
                    controller: descCtrl,
                    label: "Description",
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
            // ✅ LOADER OVERLAY
            if (selecting)
              Container(
                color: Colors.black.withOpacity(0.15),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget buildClientPreview(Map<String, dynamic> c) {
    final fullName =
    "${c['firstName'] ?? ''} ${c['lastName'] ?? ''}".trim();

    return buildPreviewCard(
      title: c['companyName']?.toString().isNotEmpty == true
          ? c['companyName']
          : (fullName.isNotEmpty ? fullName : "Client Details"),
      rows: {
        "Client ID": c['clientId'] ?? "-",
        "Status": c['status'] ?? "active",

        "First Name": c['firstName'] ?? "-",
        "Last Name": c['lastName'] ?? "-",
        "Email": c['emailAddress'] ?? "-",

        "Phone 1": c['phoneNo1'] ?? "-",
        "Phone 2": c['phoneNo2'] ?? "-",
        "Cellphone": c['cellphone'] ?? "-",
        "Fax": c['faxNo'] ?? "-",

        "Contact Person": c['contact_person'] ?? "-",
        "Customer Code": c['customerCode'] ?? "-",

        "EIN/TIN": c['einTin'] ?? "-",
        "VAT Identifier": c['vatIdentifier'] ?? "-",
        "SSN": c['socialSecurityNumber'] ?? "-",

        "Street": c['street'] ?? "-",
        "City": c['city'] ?? "-",
        "State": c['state'] ?? "-",
        "Postcode": c['postcode'] ?? "-",
        "Country": c['country'] ?? "-",

        "Created At": c['createdAt'] != null
            ? DateTime.tryParse(c['createdAt']) != null
            ? DateTime.parse(c['createdAt'])
            .toLocal()
            .toString()
            .split(' ')[0]
            : "-"
            : "-",
      },
    );
  }

  Widget buildProductPreview(Map<String, dynamic> p) {
    final pricing = p['pricing'] ?? {};
    final tax = p['tax'] ?? {};
    final colour = p['colour'] ?? {};
    final payment = p['paymentTerm'] ?? {};

    return buildPreviewCard(
      title: p['title'] ?? "-",
      rows: {
        "Product ID": p['productId'] ?? "-",
        "Item No": p['itemNo'] ?? "-",
        "Size": p['size'] ?? "-",
        "Stock": p['stock']?.toString() ?? "-",
        "Active": p['active'] == true ? "Yes" : "No",

        "Base Price": pricing['basePrice'] != null
            ? "₹ ${pricing['basePrice']}"
            : "-",

        "Total Price": pricing['totalPrice'] != null
            ? "₹ ${pricing['totalPrice']}"
            : "-",

        "CGST": tax['cgst']?.toString() ?? "0",
        "SGST": tax['sgst']?.toString() ?? "0",

        "Colour": colour['colourName'] ?? "-",

        "Advance %": payment['advancePaymentPercent']?.toString() ?? "-",
        "Interim %": payment['interimPaymentPercent']?.toString() ?? "-",
        "Final %": payment['finalPaymentPercent']?.toString() ?? "-",
      },
    );
  }


  Widget buildPreviewCard({
    required String title,
    required Map<String, String> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          ...rows.entries.map(
                (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text("${e.key}:",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(child: Text(e.value)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.darkBlue),
              const SizedBox(width: 8),
              Text(title,
                  style:
                  const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType:
      isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters:
      isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }


  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    qtyCtrl.dispose();
    super.dispose();
  }
}



