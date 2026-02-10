// services/services.dart
import '../../../services/api_service.dart';

class LoiService {

  /* =======================================================
     📄 GET QUOTATION BY ID
     ======================================================= */
  static Future<Map<String, dynamic>> getQuotationById(
      String quotationId,
      ) async {
    return await ApiService.get(
      "/quotations/$quotationId",
    );
  }

  /* =======================================================
     📤 CREATE / UPDATE LOI
     POST /lois
     ======================================================= */
  static Future<Map<String, dynamic>> createOrUpdateLoi({
    required String quotationId,
    required String attachmentUrl,
    required String fileType,
    String status = "pending",
    String? title,
    String? message,
  }) async {
    return await ApiService.post(
      "/lois",
      {
        "quotationId": quotationId,
        "attachmentUrl": attachmentUrl,
        "fileType": fileType,
        "status": status,
        if (title != null) "title": title,
        if (message != null) "message": message,
      },
    );
  }

  /* =======================================================
     ✏️ UPDATE QUOTATION STATUS
     ======================================================= */
  static Future<Map<String, dynamic>> updateQuotationStatus({
    required String quotationId,
    required String status,
  }) async {
    return await ApiService.patch(
      "/quotations/$quotationId",
      {
        "status": status,
      },
    );
  }

  /* =======================================================
     📃 GET ALL LOIs
     ======================================================= */
  static Future<List<dynamic>> getAllLois() async {
    final response = await ApiService.get("/lois");
    return response["data"] ?? response;
  }


}
