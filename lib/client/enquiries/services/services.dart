import '../../../services/api_service.dart';

class Service {
  /* =======================================================
     🔹 GET ENQUIRIES
     ======================================================= */
  Future<List<Map<String, dynamic>>> getEnquiries() async {
    final response = await ApiService.get('/enquiries');
    final List list = response['enquiries'] ?? [];

    return list.map<Map<String, dynamic>>((e) {
      return {
        'id': e['enquiryId'],
        'title': e['title'],
        'description': e['description'],
        'status': e['status'] ?? 'raised',
        'quantity': e['quantity'],
        'source': e['source'],
        'productId': e['productId'], // ✅ confirmed
        'createdAt': DateTime.parse(e['created_at']),
      };
    }).toList();
  }

  /* =======================================================
     🔹 CREATE ENQUIRY
     ======================================================= */
  Future<void> createEnquiry({
    required String clientId,
    required String productId,
    required String title,
    required String description,
    DateTime? expectedDate,
    int? quantity,
    String? source,
  }) async {
    await ApiService.post('/enquiries', {
      'clientId': clientId,
      'productId': productId,
      'title': title,
      'description': description,
      'expectedDate': expectedDate?.toIso8601String(),
      'quantity': quantity,
      'source': source,
    });
  }

  /* =======================================================
     🔹 GET PRODUCTS (FOR DROPDOWN)
     ======================================================= */
  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await ApiService.get('/products');
    final List list = response['products'] ?? [];

    return list.map<Map<String, dynamic>>((p) {
      return {
        'id': p['productId'],
        'title': p['title'],
        'description': p['description'],
        'itemNo': p['item_no'],
        'size': p['size'],
        'stock': p['stock'],
        'discountPercent': p['discount_percent'],
        'cgst': p['cgst'],
        'sgst': p['sgst'],
        'deliveryTimeRange': p['delivery_time_range'],
        'active': p['active'],
      };
    }).toList();
  }

  /* =======================================================
   🔹 GET PRODUCT BY ID (FOR CREATE ENQUIRY PREVIEW)
   ======================================================= */
  Future<Map<String, dynamic>> getProductById(String productId) async {
    final response = await ApiService.get('/products/$productId');

    final p = response['product']; // ✅ IMPORTANT FIX

    return {
      'id': p['productId'],
      'title': p['title'],
      'description': p['description'],
      'itemNo': p['item_no'],
      'size': p['size'],
      'stock': p['stock'],
      'discountPercent': p['discount_percent'],
      'cgst': p['cgst'],
      'sgst': p['sgst'],
      'deliveryTerms': p['delivery_terms'],
      'price': p['price'], // comes from getCompleteProduct
    };
  }



  /* =======================================================
   🔹 GET ENQUIRY WITH PRODUCT (DETAIL VIEW)
   ======================================================= */
  Future<Map<String, dynamic>> getEnquiryWithProduct(String enquiryId) async {
    final response =
    await ApiService.get('/enquiries/$enquiryId/with-product');

    final enquiry = response['enquiry'];
    final product = response['product'];

    return {
      'enquiry': {
        'enquiryId': enquiry['enquiryId'],
        'title': enquiry['title'],
        'description': enquiry['description'],
        'status': enquiry['status'],
        'quantity': enquiry['quantity'],
        'source': enquiry['source'],
        'productId': enquiry['productId'],
        'createdAt': DateTime.parse(enquiry['created_at']),
      },
      'product': product, // already structured by backend
    };
  }



}
