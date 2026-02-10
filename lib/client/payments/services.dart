import '../../../services/api_service.dart';

class PaymentService {

  /* ================= INVOICES ================= */

  static Future<List<Map<String, dynamic>>> getInvoices() async {
    final response = await ApiService.get("/invoices");
    final List list = response['invoices'] ?? [];

    return list.map<Map<String, dynamic>>((inv) {
      return {
        'id': inv['invoiceId'],
        'invoiceNumber': inv['invoiceNumber'],
        'clientId': inv['clientId'],
        'companyId': inv['companyId'],
        'quotationId': inv['quotationId'],
        'totalAmount': inv['totalAmount'],
        'status': inv['status'], // paid | unpaid
        'createdAt': inv['createdAt'],
      };
    }).toList();
  }

  /* ================= PAYMENTS ================= */

  static Future<List<Map<String, dynamic>>> getPayments() async {
    final response = await ApiService.get("/payments");
    final List list = response['payments'] ?? [];

    return list.map<Map<String, dynamic>>((p) {
      return {
        'paymentId': p['paymentId'],
        'invoiceId': p['invoiceId'],
        'quotationId': p['quotationId'],
        'amount': p['amount'],
        'mode': p['payment_mode'],
        'type': p['payment_type'],
        'phase': p['phase'],
        'status': p['status'],
        'invoiceNumber': p['invoiceNumber'],
        'createdAt': p['created_at'],
      };
    }).toList();
  }

  /* ================= CREATE PAYMENT ================= */

  static Future<void> createPayment({
    required double amount,
    required String clientId,
    required String companyId,
    required String invoiceId,
    required String quotationId,
    required String paymentMode,
    required String paymentType,
    required String phase,
    required String invoicePdfUrl,
  }) async {
    await ApiService.post("/payments", {
      "amount": amount,
      "clientId": clientId,
      "companyId": companyId,
      "invoiceId": invoiceId,
      "quotationId": quotationId,
      "paymentMode": paymentMode,
      "paymentType": paymentType,
      "phase": phase,
      "status": "completed",
      "invoicePdfUrl": invoicePdfUrl,
    });
  }
}
