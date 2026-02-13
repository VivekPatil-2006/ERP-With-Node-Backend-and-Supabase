import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '../../../services/api_service.dart';

class ProductService {
  final String baseUrl = ApiService.baseUrl;

  // ================= LIST PRODUCTS =================
  Future<List<Map<String, dynamic>>> getProducts() async {
    final res = await ApiService.get('/products');
    final List products = res['products'] ?? [];

    return products.map<Map<String, dynamic>>((p) {
      return {
        ...p,
        'pricing': p['pricing'] ?? {},
        'colour': p['colour'] ?? {},
        'paymentTerm': p['paymentTerm'] ?? {},
        'productImage': p['productImage'],
      };
    }).toList();
  }

  // ================= PRODUCT BY ID =================
  Future<Map<String, dynamic>> getProductById(String productId) async {
    final res = await ApiService.get('/products/$productId');
    final product = res['product'];

    return {
      ...product,
      'pricing': product['pricing'] ?? {},
      'colour': product['colour'] ?? {},
      'paymentTerm': product['paymentTerm'] ?? {},
      'productImage': product['productImage'],
    };
  }

  // ================= CREATE PRODUCT =================
  Future<Map<String, dynamic>> createProduct(
      Map<String, dynamic> data,
      File? imageFile,
      ) async {
    final token =
    await FirebaseAuth.instance.currentUser?.getIdToken();

    final uri = Uri.parse('$baseUrl/products');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    data.forEach((key, value) {
      if (value != null) {
        if (value is Map || value is List) {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      }
    });

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'productImage',
          imageFile.path,
        ),
      );
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      throw Exception(resBody);
    }

    return jsonDecode(resBody) as Map<String, dynamic>;
  }


  // ================= UPDATE PRODUCT =================
  Future<void> updateProduct(
      String productId,
      Map<String, dynamic> updates,
      File? imageFile,
      ) async {
    final token =
    await FirebaseAuth.instance.currentUser?.getIdToken();

    final uri = Uri.parse('$baseUrl/products/$productId');

    final request = http.MultipartRequest('PATCH', uri);

    request.headers['Authorization'] = 'Bearer $token';

    updates.forEach((key, value) {
      if (value != null) {
        if (value is Map || value is List) {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      }
    });

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'productImage',
          imageFile.path,
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      final resBody = await response.stream.bytesToString();
      throw Exception(resBody);
    }
  }

  // ================= DELETE PRODUCT =================
  Future<void> deleteProduct(String productId) async {
    await ApiService.delete('/products/$productId');
  }
}
