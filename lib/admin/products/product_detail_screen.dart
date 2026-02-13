import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _initialized = false;

  bool editProductInfo = false;
  bool editPricing = false;
  bool editColour = false;
  bool editTax = false;
  bool editPayment = false;
  bool editDelivery = false;
  bool editStock = false;
  bool editSpecs = false;

  // ===== IMAGE =====
  File? selectedImage;
  String? productImageUrl;
  final ImagePicker _picker = ImagePicker();

  // ===== CONTROLLERS =====
  final _titleCtrl = TextEditingController();
  final _itemNoCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _basePriceCtrl = TextEditingController();
  final _totalPriceCtrl = TextEditingController();

  final _colourNameCtrl = TextEditingController();

  final _sgstCtrl = TextEditingController();
  final _cgstCtrl = TextEditingController();

  final _advanceCtrl = TextEditingController();
  final _interimCtrl = TextEditingController();
  final _finalCtrl = TextEditingController();

  final _deliveryCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  List<TextEditingController> specNameCtrls = [];
  List<TextEditingController> specValueCtrls = [];

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
  void dispose() {
    _titleCtrl.dispose();
    _itemNoCtrl.dispose();
    _sizeCtrl.dispose();
    _descCtrl.dispose();
    _basePriceCtrl.dispose();
    _totalPriceCtrl.dispose();
    _colourNameCtrl.dispose();
    _sgstCtrl.dispose();
    _cgstCtrl.dispose();
    _advanceCtrl.dispose();
    _interimCtrl.dispose();
    _finalCtrl.dispose();
    _deliveryCtrl.dispose();
    _stockCtrl.dispose();
    _discountCtrl.dispose();
    for (final c in specNameCtrls) c.dispose();
    for (final c in specValueCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.navy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ProductService().getProductById(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading product...');
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Product not found'));
          }

          if (!_initialized) {
            productImageUrl = data['productImage'];

            _titleCtrl.text = data['title'] ?? '';
            _itemNoCtrl.text = data['itemNo'] ?? '';
            _sizeCtrl.text = data['size'] ?? '';
            _descCtrl.text = data['description'] ?? '';

            final pricingList = data['prices'] as List? ?? [];
            final pricing = pricingList.isNotEmpty ? pricingList.first : {};

            _basePriceCtrl.text =
                pricing['basePrice']?.toString() ?? '';

            _totalPriceCtrl.text =
                pricing['totalPrice']?.toString() ?? '';


            final colourList = data['colours'] as List? ?? [];
            final colour = colourList.isNotEmpty ? colourList.first : {};

            _colourNameCtrl.text =
                colour['colourName'] ?? '';


            _sgstCtrl.text =
                data['tax']?['sgst']?.toString() ?? '';
            _cgstCtrl.text =
                data['tax']?['cgst']?.toString() ?? '';

            final paymentList = data['paymentTerms'] as List? ?? [];
            final payment = paymentList.isNotEmpty ? paymentList.first : {};

            _advanceCtrl.text =
                payment['advancePaymentPercent']?.toString() ?? '';

            _interimCtrl.text =
                payment['interimPaymentPercent']?.toString() ?? '';

            _finalCtrl.text =
                payment['finalPaymentPercent']?.toString() ?? '';

            _deliveryCtrl.text =
                data['deliveryTerms']?.toString() ?? '';
            _stockCtrl.text =
                data['stock']?.toString() ?? '';
            _discountCtrl.text =
                data['discountPercent']?.toString() ?? '';

            specNameCtrls.clear();
            specValueCtrls.clear();
            for (final spec in (data['specifications'] ?? [])) {
              specNameCtrls.add(
                  TextEditingController(text: spec['name'] ?? ''));
              specValueCtrls.add(
                  TextEditingController(text: spec['value'] ?? ''));
            }

            _initialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (selectedImage != null || productImageUrl != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: AppColors.navy.withOpacity(0.25)),
                    ),
                    child: GestureDetector(
                      onTap: editProductInfo ? _pickImage : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: selectedImage != null
                            ? Image.file(
                          selectedImage!,
                          height: 180,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                            : Image.network(
                          productImageUrl!,
                          height: 180,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),

                _productInfoCard(),
                const SizedBox(height: 16),
                _pricingCard(),
                const SizedBox(height: 16),
                _taxCard(),
                const SizedBox(height: 16),
                _paymentCard(),
                const SizedBox(height: 16),
                _deliveryCard(),
                const SizedBox(height: 16),
                _specificationsCard(),
                const SizedBox(height: 16),
                _stockCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= PRODUCT INFO =================

  Widget _specificationsCard() {
    return _card(
      'Specifications',
      actions: _editActions(
        editSpecs,
            () => setState(() => editSpecs = !editSpecs),
            () async {
          final specs = List.generate(
            specNameCtrls.length,
                (i) => {
              'name': specNameCtrls[i].text,
              'value': specValueCtrls[i].text,
            },
          );

          await ProductService().updateProduct(
            widget.productId,
            {
              'specifications': specs,
            },
            null,
          );

          setState(() => editSpecs = false);
        },
      ),
      children: [
        if (specNameCtrls.isEmpty)
          const Text(
            'No specifications added',
            style: TextStyle(color: Colors.grey),
          ),

        ...List.generate(specNameCtrls.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: editSpecs
                      ? TextFormField(
                    controller: specNameCtrls[i],
                    decoration:
                    const InputDecoration(labelText: 'Name'),
                  )
                      : Text(specNameCtrls[i].text),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: editSpecs
                      ? TextFormField(
                    controller: specValueCtrls[i],
                    decoration:
                    const InputDecoration(labelText: 'Value'),
                  )
                      : Text(specValueCtrls[i].text),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _productInfoCard() {
    return _card(
      'Product Information',
      actions: _editActions(
        editProductInfo,
            () => setState(() => editProductInfo = !editProductInfo),
            () async {
          await ProductService().updateProduct(
            widget.productId,
            {
              'title': _titleCtrl.text,
              'itemNo': _itemNoCtrl.text,
              'size': _sizeCtrl.text,
              'description': _descCtrl.text,
            },
            selectedImage,
          );

          selectedImage = null;

          setState(() => editProductInfo = false);
        },
      ),
      children: [
        _editableRow('Title', _titleCtrl, editProductInfo),
        _editableRow('Item No', _itemNoCtrl, editProductInfo),
        _editableRow('Size', _sizeCtrl, editProductInfo),
        _editableRow('Description', _descCtrl, editProductInfo, multiline: true),
      ],
    );
  }

  // ================= REMAINING CARDS (UNCHANGED UI) =================

  Widget _pricingCard() => _simpleUpdateCard(
    'Pricing',
    editPricing,
        () => setState(() => editPricing = !editPricing),
        () async {
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
      setState(() => editPricing = false);
    },
    [
      _editableRow('Base Price', _basePriceCtrl, editPricing),
      _editableRow('Total Price', _totalPriceCtrl, editPricing),
    ],
  );

  Widget _taxCard() => _simpleUpdateCard(
    'Tax',
    editTax,
        () => setState(() => editTax = !editTax),
        () async {
      await ProductService().updateProduct(
        widget.productId,
        {
          'tax': {
            'sgst': double.tryParse(_sgstCtrl.text) ?? 0,
            'cgst': double.tryParse(_cgstCtrl.text) ?? 0,
          }
        },
        null,
      );
      setState(() => editTax = false);
    },
    [
      _editableRow('SGST', _sgstCtrl, editTax),
      _editableRow('CGST', _cgstCtrl, editTax),
    ],
  );

  Widget _paymentCard() => _simpleUpdateCard(
    'Payment Terms',
    editPayment,
        () => setState(() => editPayment = !editPayment),
        () async {
      await ProductService().updateProduct(
        widget.productId,
        {
          'paymentTerms': {
            'advancePaymentPercent':
            double.tryParse(_advanceCtrl.text) ?? 0,
            'interimPaymentPercent':
            double.tryParse(_interimCtrl.text) ?? 0,
            'finalPaymentPercent':
            double.tryParse(_finalCtrl.text) ?? 0,
          }
        },
        null,
      );
      setState(() => editPayment = false);
    },
    [
      _editableRow('Advance %', _advanceCtrl, editPayment),
      _editableRow('Interim %', _interimCtrl, editPayment),
      _editableRow('Final %', _finalCtrl, editPayment),
    ],
  );

  Widget _deliveryCard() => _simpleUpdateCard(
    'Delivery',
    editDelivery,
        () => setState(() => editDelivery = !editDelivery),
        () async {
      await ProductService().updateProduct(
        widget.productId,
        {
          'deliveryTerms': int.tryParse(_deliveryCtrl.text) ?? 0,
        },
        null,
      );
      setState(() => editDelivery = false);
    },
    [
      _editableRow('Delivery (days)', _deliveryCtrl, editDelivery),
    ],
  );

  Widget _stockCard() => _simpleUpdateCard(
    'Stock & Discount',
    editStock,
        () => setState(() => editStock = !editStock),
        () async {
      await ProductService().updateProduct(
        widget.productId,
        {
          'stock': int.tryParse(_stockCtrl.text) ?? 0,
          'discountPercent':
          double.tryParse(_discountCtrl.text) ?? 0,
        },
        null,
      );
      setState(() => editStock = false);
    },
    [
      _editableRow('Stock', _stockCtrl, editStock),
      _editableRow('Discount %', _discountCtrl, editStock),
    ],
  );

  // ================= SHARED =================

  Widget _simpleUpdateCard(
      String title,
      bool editing,
      VoidCallback toggle,
      VoidCallback save,
      List<Widget> children) {
    return _card(
      title,
      actions: _editActions(editing, toggle, save),
      children: children,
    );
  }

  List<Widget> _editActions(
      bool editing, VoidCallback toggle, VoidCallback save) {
    return [
      IconButton(
        icon: Icon(editing ? Icons.close : Icons.edit),
        onPressed: toggle,
      ),
      if (editing)
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: save,
        ),
    ];
  }

  Widget _card(String title,
      {required List<Widget> children, List<Widget>? actions}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navy.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy)),
              if (actions != null) Row(children: actions),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _editableRow(
      String label,
      TextEditingController ctrl,
      bool edit, {
        bool multiline = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child:
            Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: edit
                ? TextFormField(
              controller: ctrl,
              maxLines: multiline ? 3 : 1,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
            )
                : Text(
              ctrl.text.isEmpty ? '-' : ctrl.text,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
