import '../../../services/api_service.dart';

class PlanningManagerService {
  /* ================= GET PLANNING MANAGER ID ================= */
  Future<String> getPlanningManagerId() async {
    final res = await ApiService.get("/planning-managers/profile");
    return res["planningManager"]["planningManagerId"];
  }

  /* ================= GET FULL PROFILE ================= */
  Future<Map<String, dynamic>> getPlanningManagerProfile(
      String planningManagerId) async {
    final res =
    await ApiService.get("/planning-managers/$planningManagerId");
    return Map<String, dynamic>.from(res["planningManager"]);
  }

  /* ================= UPDATE PROFILE (JSON) ================= */
  Future<Map<String, dynamic>> updatePlanningManager({
    required String planningManagerId,
    String? name,
    String? phone,
    String? department,
    String? status,
    String? employeeId,
    String? designation,
    String? reportingTo,
    String? joinDate,
    String? qualifications,
    String? notes,
  }) async {
    final body = <String, dynamic>{};

    if (name != null) body["name"] = name;
    if (phone != null) body["phone"] = phone;
    if (department != null) body["department"] = department;
    if (status != null) body["status"] = status;

    if (employeeId != null) body["employee_id"] = employeeId;
    if (designation != null) body["designation"] = designation;
    if (reportingTo != null) body["reporting_to"] = reportingTo;
    if (joinDate != null) body["join_date"] = joinDate;
    if (qualifications != null) body["qualifications"] = qualifications;
    if (notes != null) body["notes"] = notes;

    final res = await ApiService.put(
      "/planning-managers/$planningManagerId",
      body,
    );

    return Map<String, dynamic>.from(res["planningManager"]);
  }
}
