// services/services.dart
import '../../../services/api_service.dart';

class InvoiceService {

  /* =======================================================
     📄 GET INVOICES
     GET /invoices
     ======================================================= */
  static Future<List<dynamic>> getInvoices() async {
    final response = await ApiService.get("/invoices");
    return response["data"] ?? response;
  }

  /* =======================================================
     📊 GET INVOICE STATS
     GET /invoices/stats
     ======================================================= */
  static Future<Map<String, dynamic>> getInvoiceStats() async {
    return await ApiService.get("/invoices/stats");
  }
}
