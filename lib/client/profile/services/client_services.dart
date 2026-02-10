import '../../../services/api_service.dart';

class ClientService {
  /* =======================================================
     🔹 GET CLIENT BY ID
     GET /clients/:id
     ======================================================= */
  Future<Map<String, dynamic>> getClientById(String clientId) async {
    final response = await ApiService.get('/clients/$clientId');

    final client = response['client']; // ✅ IMPORTANT FIX

    return {
      'clientId': client['clientId'],
      'companyId': client['companyId'],
      'salesManagerId': client['salesManagerId'],

      'companyName': client['companyName'],
      'contactPerson': client['contactPerson'],

      'firstName': client['firstName'],
      'lastName': client['lastName'],

      'emailAddress': client['emailAddress'] ?? client['email'],
      'phoneNo1': client['phoneNo1'],
      'phoneNo2': client['phoneNo2'],
      'cellphone': client['cellphone'],
      'faxNo': client['faxNo'],

      'street': client['street'],
      'city': client['city'],
      'state': client['state'],
      'postcode': client['postcode'],
      'country': client['country'],

      'profileImage': client['profileImage'],
      'status': client['status'],
      'createdAt': client['createdAt'],
    };
  }

  /* =======================================================
     🔹 UPDATE CLIENT
     PATCH /clients/:id
     ======================================================= */
  Future<void> updateClient({
    required String clientId,
    required Map<String, dynamic> data,
  }) async {
    // Remove empty fields
    data.removeWhere(
          (key, value) => value == null || value.toString().trim().isEmpty,
    );

    if (data.isEmpty) return;

    await ApiService.patch(
      '/clients/$clientId',
      data,
    );
  }
}
