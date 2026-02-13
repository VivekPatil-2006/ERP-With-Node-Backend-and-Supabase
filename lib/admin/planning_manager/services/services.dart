import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/api_service.dart';

class PlanningManagerService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /* =====================================================
     🔹 GET ALL
     GET /planning-managers
  ===================================================== */
  Future<List<Map<String, dynamic>>> getPlanningManagers() async {
    final response = await ApiService.get("/planning-managers");

    final List list = response["planningManagers"] ?? [];

    return list.map<Map<String, dynamic>>((m) {
      return {
        "planningManagerId": m["planningManagerId"],
        "name": m["name"],
        "email": m["email"],
        "phone": m["phone"],
        "department": m["department"],
        "status": m["status"],
      };
    }).toList();
  }

  /* =====================================================
     🔹 CREATE
     POST /planning-managers/create
     + SEND PASSWORD RESET EMAIL
  ===================================================== */
  Future<void> createPlanningManager({
    required Map<String, dynamic> body,
  }) async {
    await ApiService.post(
      "/planning-managers/create",
      body,
    );

    // 🔥 Send reset email
    await _auth.sendPasswordResetEmail(email: body["email"]);
  }

  /* =====================================================
     🔹 GET SINGLE
  ===================================================== */
  Future<Map<String, dynamic>> getPlanningManagerById(
      String planningManagerId) async {
    final response =
    await ApiService.get("/planning-managers/$planningManagerId");

    return response["planningManager"];
  }

  /* =====================================================
     🔹 UPDATE
  ===================================================== */
  Future<void> updatePlanningManager({
    required String planningManagerId,
    required Map<String, dynamic> body,
  }) async {
    await ApiService.post(
      "/planning-managers/$planningManagerId",
      body,
    );
  }

  /* =====================================================
     🔹 TOGGLE STATUS
  ===================================================== */
  Future<void> toggleStatus({
    required String planningManagerId,
    required bool activate,
  }) async {
    await ApiService.post(
      "/planning-managers/$planningManagerId",
      {
        "status": activate ? "active" : "inactive",
      },
    );
  }
}
