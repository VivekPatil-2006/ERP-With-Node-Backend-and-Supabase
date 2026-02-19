import 'package:flutter/material.dart';

import 'client_profile_screen.dart';
import '../../core/theme/app_colors.dart';
import '../shared_widgets/sales_drawer.dart';
import 'services/client_services.dart';
import 'create_client_screen.dart';

class SalesClientListScreen extends StatefulWidget {
  const SalesClientListScreen ({super.key});

  @override
  State<SalesClientListScreen > createState() => _SalesClientListScreenState();
}

class _SalesClientListScreenState extends State<SalesClientListScreen > {
  String searchText = '';
  late Future<List<Map<String, dynamic>>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _clientsFuture = ClientService().getClients();
  }

  // =============================
  // FILTER CLIENTS
  // =============================

  bool _filterClient(Map<String, dynamic> data) {
    final name =
    (data['clientName'] ?? '').toString().toLowerCase();
    final company =
    (data['companyName'] ?? '').toString().toLowerCase();
    final email =
    (data['email'] ?? '').toString().toLowerCase();
    final phone =
    (data['phoneNo1'] ?? '').toString().toLowerCase();

    final query = searchText.toLowerCase();

    return name.contains(query) ||
        company.contains(query) ||
        email.contains(query) ||
        phone.contains(query);
  }

  // =============================
  // UI
  // =============================

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SalesDrawer(currentRoute: '/salesClients'),

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          SalesDrawer.getTitle('/salesClients'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateClientScreen(),
            ),
          );
        },
      ),

      body: Column(
        children: [
          // ================= SEARCH =================
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search client...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() => searchText = val);
              },
            ),
          ),

          // ================= CLIENT LIST =================
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _clientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }

                final clients = snapshot.data ?? [];
                final filtered =
                clients.where(_filterClient).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No Clients Found'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _clientsFuture =
                          ClientService().getClients();
                    });
                  },
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final data = filtered[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                            AppColors.primaryBlue.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          title: Text(
                            data['clientName'] ??
                                'Unnamed Client',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              if ((data['companyName'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Text(
                                  data['companyName'],
                                  style: const TextStyle(
                                      fontSize: 13),
                                ),
                              if ((data['email'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Text(
                                  data['email'],
                                  style: const TextStyle(
                                      fontSize: 12),
                                ),
                              if ((data['phoneNo1'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Text(
                                  data['phoneNo1'],
                                  style: const TextStyle(
                                      fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ClientProfileScreen(
                                      clientId:
                                      data['clientId'],
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
