import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'services/services.dart';

class CreateWorkOrderScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const CreateWorkOrderScreen({
    super.key,
    required this.product,
  });

  @override
  State<CreateWorkOrderScreen> createState() => _CreateWorkOrderScreenState();
}

class _CreateWorkOrderScreenState extends State<CreateWorkOrderScreen> {
  bool loading = true;
  String error = '';

  bool expandedProduct = false;
  Map<String, bool> expandedComponents = {};

  List components = [];
  List workOrders = [];

  // Dialog state
  bool showConfirmDialog = false;
  bool creatingWorkOrder = false;
  Map<String, dynamic>? selectedComponent;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ================= LOAD DATA =================

  Future<void> _loadData() async {
    try {
      final componentsData =
      await WorkOrderService.getComponentsByProduct(
        widget.product['productId'],
      );

      final workOrdersData = await WorkOrderService.getWorkOrders();

      final productWorkOrders = workOrdersData.where((wo) {
        return wo['productId'] == widget.product['productId'];
      }).toList();

      setState(() {
        components = componentsData;
        workOrders = productWorkOrders;
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

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.darkBlue.withOpacity(0.15),
      ),
    );
  }

  bool hasPendingWorkOrder(String componentId) {
    return workOrders.any(
          (wo) =>
      wo['componentId'] == componentId &&
          wo['status'] == 'pending',
    );
  }

  Map<String, String> getComponentStockStatus(
      int currentStock,
      int minStock,
      int required,
      ) {
    if (currentStock >= required) {
      return {'status': 'sufficient', 'color': 'green'};
    }
    if (currentStock >= minStock) {
      return {'status': 'warning', 'color': 'yellow'};
    }
    return {'status': 'shortage', 'color': 'red'};
  }

  Icon statusIcon(String status) {
    switch (status) {
      case 'sufficient':
        return const Icon(Icons.check_circle,
            color: AppColors.primaryBlue);
      case 'warning':
        return Icon(Icons.warning,
            color: Colors.orange.shade700);
      default:
        return Icon(Icons.error,
            color: Colors.red.shade700);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        appBar: _appBar(),
        body: Center(
          child: Text(error,
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      appBar: _appBar(),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _header(),
              const SizedBox(height: 14),
              _productCard(),
              const SizedBox(height: 14),
              _componentsSection(),
            ],
          ),
          if (showConfirmDialog && selectedComponent != null)
            _confirmDialog(),
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      title: const Text('Create Work Order'),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Work Order',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Allocate required components for production',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ================= PRODUCT CARD =================

  Widget _productCard() {
    return Container(
      decoration: cardDecoration(),
      child: Column(
        children: [
          ListTile(
            onTap: () =>
                setState(() => expandedProduct = !expandedProduct),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.product['productImage'] != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.product['productImage'],
                  fit: BoxFit.cover,
                ),
              )
                  : const Icon(Icons.inventory,
                  color: AppColors.darkBlue),
            ),
            title: Text(
              widget.product['productTitle'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            subtitle: Text('Item No: ${widget.product['itemNo']}'),
            trailing: Icon(
              expandedProduct
                  ? Icons.expand_less
                  : Icons.expand_more,
              color: AppColors.darkBlue,
            ),
          ),
          if (expandedProduct)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _infoRow(
                'Required Quantity',
                widget.product['requiredQuantity'].toString(),
              ),
            ),
        ],
      ),
    );
  }

  // ================= COMPONENTS =================

  Widget _componentsSection() {
    return Container(
      decoration: cardDecoration(),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Components (${components.length})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            subtitle:
            const Text('Components linked to this product'),
          ),
          ...components.map(_componentCard).toList(),
        ],
      ),
    );
  }

  Widget _componentCard(dynamic component) {
    final productQty = widget.product['requiredQuantity'] ?? 1;
    final minStock = component['min_stock_level'] ?? 0;
    final totalRequired = productQty + minStock;

    final isExpanded =
        expandedComponents[component['componentId']] ?? false;

    final alreadyCreated =
    hasPendingWorkOrder(component['componentId']);

    return Column(
      children: [
        ListTile(
          onTap: () => setState(() {
            expandedComponents[component['componentId']] =
            !isExpanded;
          }),
          leading: statusIcon(
            getComponentStockStatus(
              component['current_stock'] ?? 0,
              minStock,
              totalRequired,
            )['status']!,
          ),
          title: Text(component['component_name']),
          subtitle:
          Text('Code: ${component['component_code']}'),
          trailing: Icon(
            isExpanded
                ? Icons.expand_less
                : Icons.expand_more,
            color: AppColors.darkBlue,
          ),
        ),
        if (isExpanded)
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.lightGrey,
            child: Column(
              children: [
                _infoRow(
                    'Unit', component['unit_of_measurement']),
                _infoRow('Min Stock', minStock.toString()),
                _infoRow(
                    'Total Required', totalRequired.toString()),
                _infoRow(
                  'Current Stock',
                  component['current_stock'].toString(),
                ),
                _infoRow(
                  'Available After',
                  (component['current_stock'] - totalRequired)
                      .clamp(0, double.infinity)
                      .toString(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: alreadyCreated
                        ? null
                        : () {
                      setState(() {
                        selectedComponent = component;
                        showConfirmDialog = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: alreadyCreated
                          ? Colors.grey.shade400
                          : AppColors.primaryBlue,
                      elevation: 0,
                    ),
                    child: Text(
                      alreadyCreated ? 'Work Order Created' : 'Create Work Order',
                      style: TextStyle(
                        color: alreadyCreated ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  ),
                ),
              ],
            ),
          ),
        Divider(
          height: 1,
          color: AppColors.darkBlue.withOpacity(0.1),
        ),
      ],
    );
  }

  // ================= CONFIRM DIALOG =================

  Widget _confirmDialog() {
    final productQty = widget.product['requiredQuantity'] ?? 1;
    final minStock = selectedComponent!['min_stock_level'] ?? 0;
    final totalRequired = productQty + minStock;

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: cardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Confirm Work Order',
                style: TextStyle(
                  fontSize: 18,

                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              _infoRow(
                  'Component', selectedComponent!['component_name']),
              _infoRow(
                  'Product', widget.product['productTitle']),
              _infoRow(
                  'Total Required', totalRequired.toString()),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        showConfirmDialog = false;
                        selectedComponent = null;
                      }),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: creatingWorkOrder
                          ? null
                          : () =>
                          _confirmCreateWorkOrder(totalRequired),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                      child: creatingWorkOrder
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Confirm',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),

                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= API CALL =================

  Future<void> _confirmCreateWorkOrder(int totalRequired) async {
    try {
      setState(() => creatingWorkOrder = true);

      await WorkOrderService.createComponentWorkOrder(
        componentId: selectedComponent!['componentId'],
        productId: widget.product['productId'],
        requiredQuantity: totalRequired,
      );

      await _loadData();

      setState(() {
        showConfirmDialog = false;
        selectedComponent = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Work order created successfully'),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => creatingWorkOrder = false);
    }
  }

  // ================= UTIL =================

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
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
