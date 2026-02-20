import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'services/services.dart';

class ComponentCreateScreen extends StatefulWidget {
  final String productId;

  const ComponentCreateScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ComponentCreateScreen> createState() =>
      _ComponentCreateScreenState();
}

class _ComponentCreateScreenState
    extends State<ComponentCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers (Mapped to backend)
  final componentCodeCtrl = TextEditingController();
  final componentNameCtrl = TextEditingController();
  final itemNoCtrl = TextEditingController();
  final sizeCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final hsnCodeCtrl = TextEditingController();
  final currentStockCtrl = TextEditingController(text: "0");
  final minStockCtrl = TextEditingController(text: "10");
  final purchaseQtyCtrl = TextEditingController(text: "50");

  String unitOfMeasurement = "Pieces";
  bool isLoading = false;

  Future<void> _createComponent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await PlanningManagerService().createComponentForProduct(
        body: {
          "productId": widget.productId,
          "componentCode": componentCodeCtrl.text.trim(),
          "componentName": componentNameCtrl.text.trim(),
          "itemNo": itemNoCtrl.text.trim(),
          "size": sizeCtrl.text.trim(),
          "description": descriptionCtrl.text.trim(),
          "unitOfMeasurement": unitOfMeasurement,
          "hsnCode": hsnCodeCtrl.text.trim(),
          "currentStock": int.tryParse(currentStockCtrl.text) ?? 0,
          "minStockLevel": int.tryParse(minStockCtrl.text) ?? 10,
          "purchaseOrderQuantity":
          int.tryParse(purchaseQtyCtrl.text) ?? 50,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Component created successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text(
          "Add Component",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _card(
                title: "Component Details",
                children: [
                  _field(componentCodeCtrl, "Component Code", required: true),
                  _field(componentNameCtrl, "Component Name", required: true),
                  _field(itemNoCtrl, "Item Number"),
                  _field(sizeCtrl, "Size"),
                ],
              ),

              const SizedBox(height: 20),

              _card(
                title: "Stock & Tax",
                children: [
                  DropdownButtonFormField<String>(
                    value: unitOfMeasurement,
                    decoration: _decoration("Unit of Measurement"),
                    items: const [
                      DropdownMenuItem(
                          value: "Pieces", child: Text("Pieces")),
                      DropdownMenuItem(
                          value: "Kg", child: Text("Kg")),
                      DropdownMenuItem(
                          value: "Meter", child: Text("Meter")),
                      DropdownMenuItem(
                          value: "Liters", child: Text("Liters")),
                      DropdownMenuItem(
                          value: "Box", child: Text("Box")),
                      DropdownMenuItem(
                          value: "Set", child: Text("Set")),
                      DropdownMenuItem(
                          value: "Grams", child: Text("Grams")),
                      DropdownMenuItem(
                          value: "Tons", child: Text("Tons")),
                      DropdownMenuItem(
                          value: "Feet", child: Text("Feet")),
                      DropdownMenuItem(
                          value: "Inches", child: Text("Inches")),
                      DropdownMenuItem(
                          value: "Centimeters", child: Text("Centimeters")),
                      DropdownMenuItem(
                          value: "Millimeters", child: Text("Millimeters")),
                      DropdownMenuItem(
                          value: "Square Meters", child: Text("Square Meters")),
                      DropdownMenuItem(
                          value: "Cubic Meters", child: Text("Cubic Meters")),

                    ],
                    onChanged: (v) => unitOfMeasurement = v!,
                  ),
                  _field(hsnCodeCtrl, "HSN Code"),
                  _field(currentStockCtrl, "Current Stock",
                      keyboard: TextInputType.number),
                  _field(minStockCtrl, "Min Stock Level",
                      keyboard: TextInputType.number),
                  _field(purchaseQtyCtrl, "Purchase Order Quantity",
                      keyboard: TextInputType.number),
                ],
              ),

              const SizedBox(height: 20),

              _card(
                title: "Description",
                children: [
                  _field(descriptionCtrl, "Description", maxLines: 3),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _createComponent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Create Component",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────── UI HELPERS ─────────

  Widget _card({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navy.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy)),
          const SizedBox(height: 14),
          ...children.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: e,
          )),
        ],
      ),
    );
  }

  Widget _field(
      TextEditingController ctrl,
      String label, {
        bool required = false,
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      validator: required
          ? (v) => v == null || v.isEmpty ? "Required" : null
          : null,
      decoration: _decoration(label),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
