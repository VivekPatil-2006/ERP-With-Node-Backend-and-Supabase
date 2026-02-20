import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'services/services.dart';

class ComponentDetailsScreen extends StatefulWidget {
  final String componentId;

  const ComponentDetailsScreen({
    super.key,
    required this.componentId,
  });

  @override
  State<ComponentDetailsScreen> createState() =>
      _ComponentDetailsScreenState();
}

class _ComponentDetailsScreenState
    extends State<ComponentDetailsScreen> {
  bool isEditing = false;
  bool isLoading = false;

  final componentNameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final hsnCtrl = TextEditingController();
  final minStockCtrl = TextEditingController();
  final poQtyCtrl = TextEditingController();
  final itemNoCtrl = TextEditingController();
  final sizeCtrl = TextEditingController();

  bool isActive = true;

  late Map<String, dynamic> component;

  Future<void> _updateComponent() async {
    setState(() => isLoading = true);

    await PlanningManagerService().updateComponent(
      componentId: widget.componentId,
      body: {
        "component_name": componentNameCtrl.text.trim(),
        "description": descriptionCtrl.text.trim(),
        "unit_of_measurement": unitCtrl.text.trim(),
        "hsn_code": hsnCtrl.text.trim(),
        "min_stock_level": int.tryParse(minStockCtrl.text),
        "purchase_order_quantity":
        int.tryParse(poQtyCtrl.text),
        "item_no": int.tryParse(itemNoCtrl.text),
        "size": sizeCtrl.text.trim(),
        "active": isActive,
      },
    );

    if (!mounted) return;

    setState(() {
      isEditing = false;
      isLoading = false;
    });
  }

  void _prefill(Map<String, dynamic> c) {
    componentNameCtrl.text = c["component_name"] ?? "";
    descriptionCtrl.text = c["description"] ?? "";
    unitCtrl.text = c["unit_of_measurement"] ?? "";
    hsnCtrl.text = c["hsn_code"] ?? "";
    minStockCtrl.text =
        c["min_stock_level"]?.toString() ?? "";
    poQtyCtrl.text =
        c["purchase_order_quantity"]?.toString() ?? "";
    itemNoCtrl.text = c["item_no"]?.toString() ?? "";
    sizeCtrl.text = c["size"]?.toString() ?? "";
    isActive = c["active"] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text("Component Details"),
        actions: [
          IconButton(
            icon: Icon(
              isEditing ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => isEditing = !isEditing);
            },
          ),
        ],
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future:
        PlanningManagerService().getComponent(widget.componentId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          component = snapshot.data!;
          _prefill(component);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                // 🔹 HEADER CARD
                _headerSection(),

                const SizedBox(height: 16),

                // 🔹 BASIC INFO
                _infoCard(
                  title: "Basic Information",
                  children: [
                    _twoColRow("Item No", itemNoCtrl),
                    _twoColRow("Unit", unitCtrl),
                    _twoColRow("Size", sizeCtrl),
                    _twoColRow("HSN Code", hsnCtrl),
                  ],
                ),

                // 🔹 STOCK INFO
                _infoCard(
                  title: "Stock & Purchase",
                  children: [
                    _readonlyRow(
                      "Current Stock",
                      component["current_stock"]?.toString(),
                    ),
                    _twoColRow(
                      "Min Stock",
                      minStockCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    _twoColRow(
                      "PO Quantity",
                      poQtyCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),

                // 🔹 META
                _infoCard(
                  title: "Meta Information",
                  children: [
                    _readonlyRow(
                      "Created",
                      component["created_at"]?.toString(),
                    ),
                  ],
                ),

                // 🔹 DESCRIPTION
                _infoCard(
                  title: "Description",
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: isEditing
                          ? TextField(
                        controller: descriptionCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      )
                          : Text(
                        component["description"] ?? "N/A",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),


                // 🔹 UPDATE BUTTON
                if (isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _updateComponent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Update Component",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          );

        },
      ),
    );
  }

  /// 🔹 Editable row (keeps same UI)
  Widget _row(
      String label,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: isEditing
                ? _editField(
              controller,
              keyboardType: keyboardType,
            )
                : Text(controller.text.isEmpty
                ? "-"
                : controller.text),
          ),
        ],
      ),
    );
  }

  /// 🔹 Read-only row
  Widget _readonlyRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value ?? "-")),
        ],
      ),
    );
  }

  Widget _editField(
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _headerSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isEditing
                    ? TextField(
                  controller: componentNameCtrl,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                )
                    : Text(
                  component["component_name"] ?? "",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Code: ${component["component_code"]}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: isEditing
                ? () => setState(() => isActive = !isActive)
                : null,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isActive ? "Active" : "Inactive",
                style: TextStyle(
                  color: isActive
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _twoColRow(
      String label,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: isEditing
                ? TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
            )
                : Text(
              controller.text.isEmpty ? "-" : controller.text,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
