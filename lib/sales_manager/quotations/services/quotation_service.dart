import '../../../../services/api_service.dart';

class QuotationService {

  /* =======================================================
     CREATE QUOTATION
     POST /api/quotations
     ======================================================= */
  Future<void> createQuotation({
    required String enquiryId,
    required double baseAmount,
    required double discountPercent,
    required double cgstPercent,
    required double sgstPercent,
    required int quantity,
    double? extraDiscount,
    DateTime? possibleDeliveryDate,
  }) async {

    final body = {
      'enquiryId': enquiryId,
      'baseAmount': baseAmount,
      'discountPercent': discountPercent,
      'cgstPercent': cgstPercent,
      'sgstPercent': sgstPercent,
      'quantity': quantity,
      'extraDiscount': extraDiscount ?? 0,
      if (possibleDeliveryDate != null)
        'possibleDeliveryDate': possibleDeliveryDate.toIso8601String(),
    };

    await ApiService.post('/quotations', body);
  }

  /* =======================================================
     LIST QUOTATIONS
     GET /api/quotations
     ======================================================= */
  Future<List<Map<String, dynamic>>> getQuotations() async {
    final response = await ApiService.get('/quotations');

    return List<Map<String, dynamic>>.from(
      response['quotations'] ?? [],
    );
  }

  /* =======================================================
     GET SINGLE QUOTATION
     GET /api/quotations/:id
     ======================================================= */
  Future<Map<String, dynamic>> getQuotationById(
      String quotationId) async {

    final response =
    await ApiService.get('/quotations/$quotationId');

    return Map<String, dynamic>.from(response['quotation'] ?? {});
  }
}
