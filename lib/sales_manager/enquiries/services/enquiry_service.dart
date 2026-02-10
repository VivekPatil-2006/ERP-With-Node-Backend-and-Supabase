import '../../../../services/api_service.dart';

class EnquiryService {
  /* =======================================================
     GET ENQUIRY + PRODUCT
     GET /api/enquiries/:id/with-product
     ======================================================= */
  Future<Map<String, dynamic>> getEnquiryWithProduct(
      String enquiryId) async {
    final response =
    await ApiService.get('/enquiries/$enquiryId/with-product');

    final e = response['enquiry'];
    final p = response['product'];

    return {
      // Enquiry
      'enquiryId': e['enquiryId'],
      'clientId': e['clientId'],
      'productId': e['productId'],
      'title': e['title'],
      'description': e['description'],
      'quantity': e['quantity'],
      'source': e['source'],
      'status': e['status'],
      'createdAt': e['created_at'],
      'expectedDate': e['expected_date'],

      // Product
      'product': p,
    };
  }
}
