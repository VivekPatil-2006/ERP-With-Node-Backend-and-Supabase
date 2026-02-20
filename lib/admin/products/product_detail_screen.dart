import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool loading = true;
  bool saving = false;

  Map<String, dynamic>? productData;

  File? selectedImage;
  String? productImageUrl;

  final ImagePicker _picker = ImagePicker();

  // Controllers
  final _titleCtrl = TextEditingController();
  final _itemNoCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _basePriceCtrl = TextEditingController();
  final _totalPriceCtrl = TextEditingController();

  bool editProductInfo = false;
  bool editPricing = false;

  @override
  void initState() {
    super.initState();
    loadProduct();
  }

  Future<void> loadProduct() async {
    setState(() => loading = true);

    final data =
    await ProductService().getProductById(widget.productId);

    productData = data;

    productImageUrl = data['productImage'];

    _titleCtrl.text = data['title'] ?? '';
    _itemNoCtrl.text = data['itemNo'] ?? '';
    _descCtrl.text = data['description'] ?? '';

    final pricing = data['pricing'] ?? {};
    _basePriceCtrl.text = pricing['basePrice']?.toString() ?? '';
    _totalPriceCtrl.text = pricing['totalPrice']?.toString() ?? '';

    setState(() => loading = false);
  }

  Future<void> saveProductInfo() async {
    setState(() => saving = true);

    await ProductService().updateProduct(
      widget.productId,
      {
        'title': _titleCtrl.text,
        'itemNo': _itemNoCtrl.text,
        'description': _descCtrl.text,
      },
      selectedImage,
    );

    selectedImage = null;
    editProductInfo = false;

    await loadProduct();

    setState(() => saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product updated successfully")),
      );
    }
  }

  Future<void> savePricing() async {
    setState(() => saving = true);

    await ProductService().updateProduct(
      widget.productId,
      {
        'pricing': {
          'basePrice': double.tryParse(_basePriceCtrl.text) ?? 0,
          'totalPrice': double.tryParse(_totalPriceCtrl.text) ?? 0,
        }
      },
      null,
    );

    editPricing = false;

    await loadProduct();

    setState(() => saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pricing updated successfully")),
    );
  }

  Future<void> _pickImage() async {
    final XFile? picked =
    await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text("Product Details",
            style: TextStyle(color: Colors.white)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : saving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (selectedImage != null ||
                productImageUrl != null)
              GestureDetector(
                onTap: editProductInfo ? _pickImage : null,
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(16),
                  child: selectedImage != null
                      ? Image.file(selectedImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover)
                      : Image.network(
                    productImageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            _card(
              "Product Information",
              editProductInfo,
                  () => setState(() =>
              editProductInfo = !editProductInfo),
              saveProductInfo,
              [
                _editableRow(
                    "Title", _titleCtrl, editProductInfo),
                _editableRow(
                    "Item No", _itemNoCtrl, editProductInfo),
                _editableRow(
                    "Description",
                    _descCtrl,
                    editProductInfo,
                    multiline: true),
              ],
            ),

            const SizedBox(height: 16),

            _card(
              "Pricing",
              editPricing,
                  () => setState(
                      () => editPricing = !editPricing),
              savePricing,
              [
                _editableRow("Base Price",
                    _basePriceCtrl, editPricing),
                _editableRow("Total Price",
                    _totalPriceCtrl, editPricing),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
      String title,
      bool editing,
      VoidCallback toggle,
      VoidCallback save,
      List<Widget> children,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                        editing ? Icons.close : Icons.edit),
                    onPressed: toggle,
                  ),
                  if (editing)
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: save,
                    )
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _editableRow(
      String label,
      TextEditingController controller,
      bool editing, {
        bool multiline = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label)),
          Expanded(
            child: editing
                ? TextFormField(
              controller: controller,
              maxLines: multiline ? 3 : 1,
              decoration:
              const InputDecoration(border: OutlineInputBorder()),
            )
                : Text(controller.text.isEmpty
                ? "-"
                : controller.text),
          ),
        ],
      ),
    );
  }
}

