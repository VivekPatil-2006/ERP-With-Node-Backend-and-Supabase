import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import 'services/services.dart';
import '../shared/widgets/planning_manager_drawer.dart';
import 'create_work_order.dart';

class WorkOrdersScreen extends StatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  State<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends State<WorkOrdersScreen> {
  bool loading = false;
  String error = '';
  List products = [];
  Map<String, dynamic>? summary;

  @override
  void initState() {
    super.initState();
    loadWorkOrders();
  }

  Future<void> loadWorkOrders() async {
    try {
      setState(() {
        loading = true;
        error = '';
      });

      final res = await WorkOrderService.getWorkOrderProducts();

      setState(() {
        products = res['data'] ?? [];
        summary = res['summary'];
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => loading = false);
    }
  }

  // ================= HELPERS =================

  String formatCurrency(num value) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(value);
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.darkBlue.withOpacity(0.15),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PlanningManagerDrawer(
        currentRoute: '/planning_manager/workOrders',
      ),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Work Order Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadWorkOrders,
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(
        child: Text(error, style: const TextStyle(color: Colors.red)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header(),
        const SizedBox(height: 12),
        if (summary != null) _summaryCards(),
        const SizedBox(height: 12),
        products.isEmpty ? _emptyState() : _productsList(),
      ],
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Work Order Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Products from completed payments requiring production planning',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ================= SUMMARY =================

  Widget _summaryCards() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _summaryCard('Total Products', summary!['totalProducts'], Icons.inventory_2),
        _summaryCard('Total Quotations', summary!['totalQuotations'], Icons.check_circle),
        _summaryCard('Payments Done', summary!['totalPayments'], Icons.payments),
      ],
    );
  }

  Widget _summaryCard(String label, dynamic value, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.darkBlue),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= PRODUCTS =================

  Widget _productsList() {
    return Column(
      children: products.map(_productCard).toList(),
    );
  }

  Widget _productCard(dynamic product) {
    final requiredQty = product['requiredQuantity'] ?? 0;
    final availableQty = product['availableQuantity'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PRODUCT HEADER
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product['productImage'] != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product['productImage'],
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(Icons.inventory, color: AppColors.darkBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['productTitle'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Item No: ${product['itemNo']}'),
                    Text('Quotation: ${product['quotationId']}'),
                    if (product['size'] != 'N/A')
                      Text('Size: ${product['size']}'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // STOCK STATUS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.darkBlue.withOpacity(0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stock Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Required: $requiredQty'),
                    Text('Available: $availableQty'),
                    Text(
                      'Shortage: ${product['stockShortage']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  backgroundColor: AppColors.lightGrey,
                  valueColor:
                  const AlwaysStoppedAnimation(AppColors.primaryBlue),
                  value: requiredQty == 0
                      ? 0
                      : (availableQty / requiredQty).clamp(0.0, 1.0),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // PAYMENT INFO
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${product['payments'].length} Payments'),
                Text(
                  formatCurrency(product['totalPaymentAmount'] ?? 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ACTIONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateWorkOrderScreen(
                          product: Map<String, dynamic>.from(product),
                        ),
                      ),
                    );
                  },
                  child: const Text('Create Work Order'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkBlue,
                  side: BorderSide(
                    color: AppColors.darkBlue.withOpacity(0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= EMPTY =================

  Widget _emptyState() {
    return Column(
      children: const [
        SizedBox(height: 40),
        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
        SizedBox(height: 12),
        Text(
          'No Work Orders Found',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'No products with completed payments found',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
