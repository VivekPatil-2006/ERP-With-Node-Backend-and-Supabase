import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import 'services/services.dart';

class CreateClientEnquiryScreen extends StatefulWidget {
  const CreateClientEnquiryScreen({super.key});

  @override
  State<CreateClientEnquiryScreen> createState() =>
      _CreateClientEnquiryScreenState();
}

class _CreateClientEnquiryScreenState
    extends State<CreateClientEnquiryScreen> {
  final Service service = Service();
  final FirebaseAuth auth = FirebaseAuth.instance;

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');

  String? selectedProductId;
  Map<String, dynamic>? selectedProduct;

  String? selectedSource;
  DateTime? expectedDate;

  bool loading = false;
  bool loadingProducts = true;
  bool loadingProductDetails = false;

  List<Map<String, dynamic>> products = [];

  final List<Map<String, String>> enquirySources = [
    {'label': 'By Walkin', 'value': 'by walkin'},
    {'label': 'By Email', 'value': 'by email'},
    {'label': 'By Phone', 'value': 'by phone'},
    {'label': 'By Reference', 'value': 'by reference'},
    {'label': 'Other', 'value': 'other'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /* ================= LOAD PRODUCTS ================= */

  Future<void> _loadProducts() async {
    try {
      products = await service.getProducts();
    } catch (_) {
      products = [];
    }
    if (mounted) setState(() => loadingProducts = false);
  }

  /* ================= LOAD PRODUCT DETAILS ================= */

  Future<void> _loadProductDetails(String productId) async {
    try {
      setState(() {
        loadingProductDetails = true;
        selectedProduct = null;
      });

      selectedProduct = await service.getProductById(productId);
    } catch (e) {
      debugPrint('ERROR LOADING PRODUCT => $e');
    } finally {
      if (mounted) setState(() => loadingProductDetails = false);
    }
  }

  /* ================= DATE PICKER ================= */

  Future<void> pickExpectedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => expectedDate = picked);
    }
  }

  /* ================= SUBMIT ENQUIRY ================= */

  Future<void> submitEnquiry() async {
    if (selectedProductId == null) {
      showMsg('Please select a product');
      return;
    }

    if (titleCtrl.text.trim().isEmpty) {
      showMsg('Enter enquiry title');
      return;
    }

    if (descCtrl.text.trim().isEmpty) {
      showMsg('Enter enquiry description');
      return;
    }

    final qty = int.tryParse(qtyCtrl.text) ?? 0;
    if (qty <= 0) {
      showMsg('Enter valid quantity');
      return;
    }

    try {
      setState(() => loading = true);

      await service.createEnquiry(
        clientId: auth.currentUser!.uid,
        productId: selectedProductId!,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        quantity: qty,
        expectedDate: expectedDate,
        source: selectedSource,
      );

      if (!mounted) return;

      showMsg('Enquiry submitted successfully');
      Navigator.pop(context);
    } catch (_) {
      showMsg('Failed to submit enquiry');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Enquiry'),
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
          onPressed: loading ? null : submitEnquiry,
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
            'SUBMIT ENQUIRY',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      body: loadingProducts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /* ================= PRODUCT DROPDOWN ================= */

            DropdownButtonFormField<String>(
              value: selectedProductId,
              decoration: const InputDecoration(
                labelText: 'Select Product',
                prefixIcon: Icon(Icons.inventory_2),
                border: OutlineInputBorder(),
              ),
              items: products
                  .map(
                    (p) => DropdownMenuItem<String>(
                  value: p['id'],
                  child: Text(p['title']),
                ),
              )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => selectedProductId = v);
                _loadProductDetails(v);
              },
            ),

            const SizedBox(height: 12),

            if (loadingProductDetails)
              const CircularProgressIndicator()
            else if (selectedProduct != null)
              _buildProductCard(selectedProduct!),

            const SizedBox(height: 16),

            /* ================= SOURCE ================= */

            DropdownButtonFormField<String>(
              value: selectedSource,
              decoration: const InputDecoration(
                labelText: 'Source of Enquiry',
                border: OutlineInputBorder(),
              ),
              items: enquirySources
                  .map(
                    (e) => DropdownMenuItem(
                  value: e['value'],
                  child: Text(e['label']!),
                ),
              )
                  .toList(),
              onChanged: (v) => setState(() => selectedSource = v),
            ),

            const SizedBox(height: 12),

            /* ================= EXPECTED DATE ================= */

            InkWell(
              onTap: pickExpectedDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Expected Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  expectedDate == null
                      ? 'Select Date'
                      : DateFormat.yMMMd().format(expectedDate!),
                ),
              ),
            ),

            const SizedBox(height: 12),

            _input(titleCtrl, 'Enquiry Title', Icons.title),
            const SizedBox(height: 12),
            _input(descCtrl, 'Description', Icons.description,
                maxLines: 4),
            const SizedBox(height: 12),
            _input(
              qtyCtrl,
              'Quantity',
              Icons.production_quantity_limits,
              isNumber: true,
            ),
          ],
        ),
      ),
    );
  }

  /* ================= PRODUCT CARD ================= */

  Widget _buildProductCard(Map<String, dynamic> p) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            p['title'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            p['description'] ?? '',
            style: TextStyle(color: Colors.grey.shade700),
          ),

          const Divider(),

          _infoRow('Item No', p['itemNo']),
          _infoRow('Size', p['size']),
          _infoRow('Stock', '${p['stock']}'),
          _infoRow('Discount', '${p['discountPercent']}%'),

          const Divider(),

          _infoRow(
            'Base Price',
            '₹ ${p['price']?['base_price'] ?? '-'}',
          ),
          _infoRow(
            'Total Price',
            '₹ ${p['price']?['total_price'] ?? '-'}',
          ),

          const Divider(),

          _infoRow('CGST', '${p['cgst']}%'),
          _infoRow('SGST', '${p['sgst']}%'),
          _infoRow('Delivery Terms', p['deliveryTerms']),
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value ?? '-',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _input(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
        bool isNumber = false,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    qtyCtrl.dispose();
    super.dispose();
  }
}
