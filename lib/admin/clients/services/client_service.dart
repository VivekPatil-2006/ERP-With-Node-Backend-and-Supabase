import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_service.dart';

class ClientService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /* =======================================================
     🔹 GET CLIENTS (LIST)
     ======================================================= */
  Future<List<Map<String, dynamic>>> getClients() async {
    final response = await ApiService.get("/clients");

    final List clients = response["clients"] ?? [];

    return clients.map<Map<String, dynamic>>((c) {
      return {
        "clientId": c["id"],

        "clientName":
        "${c["firstName"] ?? ""} ${c["lastName"] ?? ""}".trim(),

        "companyName": c["companyName"],
        "contactPerson": c["contact_person"],

        "email": c["email"],
        "profileImage": c["profileImage"],   // ✅ ADDED

        "status": c["status"] ?? "inactive",
      };
    }).toList();
  }

  /* =======================================================
     🔹 CREATE CLIENT
     ======================================================= */
  Future<void> createClient({
    required String companyName,
    required String customerCode,
    required String socialSecurityNumber,
    required String einTin,
    required String vatIdentifier,
    required String firstName,
    required String lastName,
    required String contactPerson,
    required String emailAddress,
    required String phoneNo1,
    required String phoneNo2,
    required String cellphone,
    required String faxNo,
    required String country,
    required String street,
    required String city,
    required String state,
    required String postcode,
  }) async {
    await ApiService.post(
      "/clients",
      {
        "companyName": companyName,
        "customerCode": customerCode,
        "socialSecurityNumber": socialSecurityNumber,
        "einTin": einTin,
        "vatIdentifier": vatIdentifier,
        "firstName": firstName,
        "lastName": lastName,
        "contactPerson": contactPerson,
        "emailAddress": emailAddress,
        "phoneNo1": phoneNo1,
        "phoneNo2": phoneNo2,
        "cellphone": cellphone,
        "faxNo": faxNo,
        "country": country,
        "street": street,
        "city": city,
        "state": state,
        "postcode": postcode,
      },
    );

    await _auth.sendPasswordResetEmail(
      email: emailAddress,
    );
  }

  /* =======================================================
     🔹 GET SINGLE CLIENT
     ======================================================= */
  Future<Map<String, dynamic>> getClientById(String clientId) async {
    final response = await ApiService.get("/clients/$clientId");

    final c = response["client"];

    return {
      "clientId": c["id"],
      "clientName":
      "${c["firstName"] ?? ""} ${c["lastName"] ?? ""}".trim(),

      "companyName": c["companyName"],
      "contactPerson": c["contact_person"],
      "emailAddress": c["email"],
      "phoneNo1": c["phoneNo1"],
      "phoneNo2": c["phoneNo2"],

      "profileImage": c["profileImage"], // ✅ ADDED

      "customerCode": c["customerCode"],
      "socialSecurityNumber": c["socialSecurityNumber"],
      "einTin": c["einTin"],
      "vatIdentifier": c["vatIdentifier"],

      "city": c["city"],
      "state": c["state"],
      "postcode": c["postcode"],
      "street": c["street"],
      "country": c["country"],
      "status": c["status"],
    };
  }

  /* =======================================================
     🔹 TOGGLE STATUS
     ======================================================= */
  Future<void> toggleStatus({
    required String clientId,
    required bool activate,
  }) async {
    await ApiService.patch(
      "/clients/$clientId/status",
      {
        "status": activate ? "active" : "inactive",
      },
    );
  }
}
