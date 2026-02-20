import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../shared/widgets/planning_manager_drawer.dart';
import 'services/services.dart';

class ListWorkOrdersScreen extends StatefulWidget {
  const ListWorkOrdersScreen({super.key});

  @override
  State<ListWorkOrdersScreen> createState() => _ListWorkOrdersScreenState();
}

class _ListWorkOrdersScreenState extends State<ListWorkOrdersScreen> {
  bool loading = true;
  String error = '';
  List workOrders = [];

  @override
  void initState() {
    super.initState();
    _loadWorkOrders();
  }

  Future<void> _loadWorkOrders() async {
    try {
      setState(() {
        loading = true;
        error = '';
      });

      final data = await WorkOrderService.getWorkOrders();
      setState(() => workOrders = data);
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => loading = false);
    }
  }

  // ================= HELPERS =================

  String formatDate(String? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
  }

  Icon statusIcon(String status) {
    switch (status) {
      case 'pending':
        return const Icon(Icons.schedule, size: 18, color: AppColors.primaryBlue);
      case 'approved':
      case 'completed':
        return const Icon(Icons.check_circle,
            size: 18, color: AppColors.primaryBlue);
      case 'rejected':
        return const Icon(Icons.cancel,
            size: 18, color: AppColors.primaryBlue);
      default:
        return const Icon(Icons.help_outline, size: 18);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PlanningManagerDrawer(
        currentRoute: '/planning_manager/listWorkOrders',
      ),
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Work Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWorkOrders,
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

    if (workOrders.isEmpty) {
      return _emptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _summaryCards(),
        const SizedBox(height: 16),
        ...workOrders.map(_workOrderCard).toList(),
      ],
    );
  }

  // ================= STATES =================

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.assignment_outlined,
              size: 64, color: AppColors.darkBlue),
          SizedBox(height: 12),
          Text(
            'No Work Orders Found',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Work orders will appear here once created',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

// ================= SUMMARY =================

  Widget _summaryCards() {
    final pending =
        workOrders.where((w) => w['status'] == 'pending').length;
    final approved =
        workOrders.where((w) => w['status'] == 'approved').length;
    final completed =
        workOrders.where((w) => w['status'] == 'completed').length;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _summaryCard(
          label: 'Total',
          value: workOrders.length,
          bgColor: const Color(0xFF0EA5E9),
        ),
        _summaryCard(
          label: 'Pending',
          value: pending,
          bgColor: const Color(0xFFF59E0B),
        ),
        _summaryCard(
          label: 'Approved',
          value: approved,
          bgColor: const Color(0xFF10B981),
        ),
        _summaryCard(
          label: 'Completed',
          value: completed,
          bgColor: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required int value,
    required Color bgColor,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 24,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WORK ORDER CARD =================

  Widget _workOrderCard(dynamic wo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBlue.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WO #${wo['workOrderId'].toString().substring(0, 8)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    statusIcon(wo['status']),
                    const SizedBox(width: 6),
                    Text(
                      wo['status'].toString().toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _infoRow(
            'Product',
            wo['Products']?['title'] ?? 'Unknown Product',
          ),
          _infoRow(
            'Component',
            wo['componentId'] != null
                ? wo['componentId'].toString().substring(0, 8)
                : 'N/A',
          ),
          _infoRow(
            'Quantity',
            wo['quantity_to_produce'].toString(),
          ),
          _infoRow(
            'Created',
            formatDate(wo['created_at']),
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/planning_manager/workOrders/${wo['workOrderId']}',
                );
              },
              child: const Text(
                'View',
                style: TextStyle(color: AppColors.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UTIL =================

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              )),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }
}
