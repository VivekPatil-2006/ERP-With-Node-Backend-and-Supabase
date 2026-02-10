import '../../../services/api_service.dart';

class QuotationService {

  static Future<List<Map<String, dynamic>>> getMyQuotations() async {
    final response = await ApiService.get("/quotations");

    final List list = response['quotations'] ?? [];

    return list.map<Map<String, dynamic>>((q) {
      final pricing = q['pricing'] ?? {};

      return {
        'id': q['quotationId'],
        'quotationId': q['quotationId'],
        'enquiryId': q['enquiryId'],
        'clientId': q['clientId'],
        'productId': q['productId'],
        'companyId': q['companyId'],
        'salesManagerId': q['salesManagerId'],

        'expectedDate': q['expectedDate'],
        'possibleDeliveryDate': q['possibleDeliveryDate'],

        // ✅ PRICING (FIXED)
        'pricing': pricing,
        'quotationAmount': pricing['totalAmount'] ?? 0,

        'status': q['status'] ?? '',
        'enquiryTitle': q['enquiryTitle'],

        'loiId': q['loiId'],
        'loiStatus': q['loiStatus'],

        'createdAt': q['createdAt'],
        'updatedAt': q['updatedAt'],
      };
    }).toList();
  }

  static Future<Map<String, dynamic>> getQuotationById(
      String quotationId,
      ) async {
    final response = await ApiService.get("/quotations/$quotationId");

    final quotation = response['quotation'];
    final pricing = quotation['pricing'] ?? {};

    return {
      'quotationId': quotation['quotationId'],
      'status': quotation['status'],
      'pricing': pricing,
      'quotationAmount': pricing['totalAmount'] ?? 0,
      'expectedDate': quotation['expectedDate'],
      'possibleDeliveryDate': quotation['possibleDeliveryDate'],

      'enquiry': response['enquiry'],
      'product': response['product'],
      'client': response['client'],
      'loi': response['loi'],
    };
  }

}
