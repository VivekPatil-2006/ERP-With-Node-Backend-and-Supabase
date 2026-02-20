import '../../../services/api_service.dart';

class WorkOrderService {
  /* =======================================================
     📦 GET WORK ORDER PRODUCTS
     Backend: GET /products
     ======================================================= */
  static Future<Map<String, dynamic>> getWorkOrderProducts() async {
    return await ApiService.get('/work-orders/products');
  }

  /* =======================================================
     🧩 GET COMPONENTS BY PRODUCT
     Backend: GET /product/:productId
     ======================================================= */
  static Future<List<dynamic>> getComponentsByProduct(String productId) async {
    final res = await ApiService.get('/components/product/$productId');

    // backend returns: { message, data: [] }
    return res['data'] ?? [];
  }

  static Future<void> createComponentWorkOrder({
    required String componentId,
    required String productId,
    String? quotationId,
    required int requiredQuantity,
  }) async {
    await ApiService.post(
      '/work-orders/create-component',
      {
        'componentId': componentId,
        'productId': productId,
        'quotationId': quotationId,
        'requiredQuantity': requiredQuantity,
      },
    );
  }

  // static Future<List<dynamic>> getWorkOrders() async {
  //   final res = await ApiService.get('/work-orders/');
  //   return res['data'] ?? [];
  // }


  /* =======================================================
     📋 GET ALL WORK ORDERS (with optional status filter)
     Backend: GET /work-orders?status=pending
     ======================================================= */
  static Future<List<dynamic>> getWorkOrders({String? status}) async {
    final endpoint =
    status != null ? '/work-orders?status=$status' : '/work-orders';

    final res = await ApiService.get(endpoint);
    return res['data'] ?? [];
  }

}
