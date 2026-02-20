import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_service.dart';

class PlanningManagerService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /* =========================================================
     🔹 GET PRODUCTS (Assumes /products endpoint exists)
  ========================================================== */
  Future<List<dynamic>> getProducts() async {
    final res = await ApiService.get("/products");

    // BACKEND RETURNS { products: [], nextCursor }
    return res["products"] ?? [];
  }


  /* =========================================================
     🔹 GET COMPONENTS BY PRODUCT
  ========================================================== */
  Future<List<dynamic>> getComponentsByProduct(String productId) async {
    final res =
    await ApiService.get("/components/product/$productId");
    return res["data"] ?? [];
  }

  /* =========================================================
     🔹 GET SINGLE COMPONENT
  ========================================================== */
  Future<Map<String, dynamic>> getComponent(
      String componentId) async {
    final res =
    await ApiService.get("/components/$componentId");
    return res["data"];
  }

  /* =========================================================
     🔹 CREATE COMPONENT FOR PRODUCT
  ========================================================== */
  Future<void> createComponentForProduct({
    required Map<String, dynamic> body,
  }) async {
    await ApiService.post(
      "/components/create-for-product",
      body,
    );
  }

  /* =========================================================
     🔹 UPDATE COMPONENT
  ========================================================== */
  Future<void> updateComponent({
    required String componentId,
    required Map<String, dynamic> body,
  }) async {
    await ApiService.post(
      "/components/$componentId",
      body,
    );
  }

  /* =========================================================
   🔹 DELETE COMPONENT (Soft delete)
========================================================== */
  Future<void> deleteComponent(String componentId) async {
    await ApiService.delete(
      "/components/$componentId",
    );
  }


}
