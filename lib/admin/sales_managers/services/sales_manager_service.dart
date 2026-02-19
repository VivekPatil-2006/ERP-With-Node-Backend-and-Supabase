import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_service.dart';

class SalesManagerService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /* =======================================================
     🔹 GET SALES MANAGERS
     ======================================================= */
  Future<List<Map<String, dynamic>>> getSalesManagers() async {
    final response = await ApiService.get("/sales-managers");

    final List managers = response["salesManagers"] ?? [];

    return managers.map<Map<String, dynamic>>((m) {
      return {
        "managerId": m["id"],
        "name": m["name"],
        "email": m["email"],
        "phone": m["phone"],
        "profileImage": m["profileImage"], // ✅ added
        "status": m["status"],
      };
    }).toList();
  }

  /* =======================================================
     🔹 CREATE SALES MANAGER
     ======================================================= */
  Future<void> createSalesManager({
    required String name,
    required String email,
    required String phone,
    String? dob,
    String? gender,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postcode,
  }) async {
    await ApiService.post(
      "/sales-managers",
      {
        "name": name,
        "email": email,
        "phone": phone,
        if (dob != null) "dob": dob,
        if (gender != null) "gender": gender,
        if (addressLine1 != null) "addressLine1": addressLine1,
        if (addressLine2 != null) "addressLine2": addressLine2,
        if (city != null) "city": city,
        if (state != null) "state": state,
        if (postcode != null) "postcode": postcode,
      },
    );

    await _auth.sendPasswordResetEmail(email: email);
  }

  /* =======================================================
     🔹 GET SINGLE SALES MANAGER
     ======================================================= */
  Future<Map<String, dynamic>> getSalesManagerById(String managerId) async {
    final response =
    await ApiService.get("/sales-managers/$managerId");

    final m = response["salesManager"];

    return {
      "managerId": m["id"],
      "name": m["name"],
      "email": m["email"],
      "phone": m["phone"],
      "dob": m["dob"],
      "gender": m["gender"],
      "profileImage": m["profileImage"], // ✅ added
      "addressLine1": m["addressLine1"],
      "addressLine2": m["addressLine2"],
      "city": m["city"],
      "state": m["state"],
      "postcode": m["postcode"],
      "status": m["status"],
      "salesTarget": m["sales_target"] ?? 0,
    };
  }

  /* =======================================================
     🔹 UPDATE SALES TARGET
     ======================================================= */
  Future<void> updateSalesTarget({
    required String managerId,
    required int target,
  }) async {
    await ApiService.patch(
      "/sales-managers/$managerId",
      {
        "sales_target": target,
      },
    );
  }

  /* =======================================================
     🔹 ACTIVATE / DEACTIVATE
     ======================================================= */
  Future<void> toggleStatus({
    required String managerId,
    required bool activate,
  }) async {
    await ApiService.patch(
      "/sales-managers/$managerId/status",
      {
        "status": activate ? "active" : "inactive",
      },
    );
  }
}
