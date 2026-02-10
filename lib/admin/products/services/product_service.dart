import '../../../services/api_service.dart';

class ProductService {
  // ================= LIST PRODUCTS =================
  Future<List<Map<String, dynamic>>> getProducts() async {
    final res = await ApiService.get('/products');
    final List products = res['products'] ?? [];

    return products.map<Map<String, dynamic>>((p) {
      final prices = p['prices'] as List? ?? [];
      final colours = p['colours'] as List? ?? [];
      final paymentTerms = p['paymentTerms'] as List? ?? [];

      return {
        ...p,

        // 👇 normalize nested lists for UI
        'pricing': prices.isNotEmpty ? prices.first : {},
        'colour': colours.isNotEmpty ? colours.first : {},
        'paymentTerms': paymentTerms.isNotEmpty ? paymentTerms.first : {},
      };
    }).toList();
  }

  // ================= PRODUCT BY ID =================
  Future<Map<String, dynamic>> getProductById(String productId) async {
    final res = await ApiService.get('/products/$productId');
    final product = res['product'];

    final prices = product['prices'] as List? ?? [];
    final colours = product['colours'] as List? ?? [];
    final paymentTerms = product['paymentTerms'] as List? ?? [];

    return {
      ...product,

      // 👇 normalize nested lists for UI
      'pricing': prices.isNotEmpty ? prices.first : {},
      'colour': colours.isNotEmpty ? colours.first : {},
      'paymentTerms': paymentTerms.isNotEmpty ? paymentTerms.first : {},
    };
  }

  // ================= CREATE PRODUCT =================
  Future<void> createProduct(Map<String, dynamic> data) async {
    await ApiService.post('/products', data);
  }

  // ================= UPDATE PRODUCT =================
  Future<void> updateProduct(
      String productId,
      Map<String, dynamic> updates,
      ) async {
    await ApiService.patch('/products/$productId', updates);
  }

  // ================= DELETE PRODUCT =================
  Future<void> deleteProduct(String productId) async {
    await ApiService.delete('/products/$productId');
  }
}
