import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/services.dart';

class ClientEnquiryDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> enquiry;

  const ClientEnquiryDetailsScreen({
    super.key,
    required this.enquiry,
  });

  @override
  State<ClientEnquiryDetailsScreen> createState() =>
      _ClientEnquiryDetailsScreenState();
}

class _ClientEnquiryDetailsScreenState
    extends State<ClientEnquiryDetailsScreen> {
  final Service _service = Service();

  bool loading = true;
  Map<String, dynamic>? enquiry;
  Map<String, dynamic>? product;

  @override
  void initState() {
    super.initState();
    _loadEnquiry();
  }

  Future<void> _loadEnquiry() async {
    try {
      final result = await _service.getEnquiryWithProduct(
        widget.enquiry['id'],
      );

      enquiry = result['enquiry'];
      product = result['product'];
    } catch (e) {
      debugPrint('ERROR LOADING ENQUIRY => $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'raised':
        return Colors.orange;
      case 'quoted':
        return Colors.blue;
      case 'closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? '-'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Loading enquiry...'),
      );
    }

    if (enquiry == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load enquiry')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enquiry Details'),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color:
                getStatusColor(enquiry!['status']).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                enquiry!['status'].toUpperCase(),
                style: TextStyle(
                  color: getStatusColor(enquiry!['status']),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 18),

            section('Enquiry Information', [
              row('Title', enquiry!['title']),
              row('Description', enquiry!['description']),
              row('Quantity', enquiry!['quantity']),
              row(
                'Created On',
                DateFormat.yMMMd().format(enquiry!['createdAt']),
              ),
              row('Source', enquiry!['source']),
            ]),

            section(
              'Product Details',
              product == null
                  ? [
                const Text(
                  'Product not available',
                  style: TextStyle(color: Colors.grey),
                )
              ]
                  : [
                row('Product Name', product!['title']),
                row('Item No', product!['item_no']),
                row('Size', product!['size']),
                row('Stock', product!['stock']),
                row('Discount %', product!['discount_percent']),
                row('CGST', product!['cgst']),
                row('SGST', product!['sgst']),
                row('Delivery Terms', product!['delivery_terms']),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
