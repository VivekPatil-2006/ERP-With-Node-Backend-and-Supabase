import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/empty_state.dart';
import '../shared/widgets/admin_drawer.dart';
import 'services/services.dart';
import 'planning_manager_details_screen.dart';

class PlanningManagerListScreen extends StatefulWidget {
  const PlanningManagerListScreen({super.key});

  @override
  State<PlanningManagerListScreen> createState() =>
      _PlanningManagerListScreenState();
}

class _PlanningManagerListScreenState
    extends State<PlanningManagerListScreen> {
  String query = '';
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = PlanningManagerService().getPlanningManagers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminDrawer(currentRoute: '/listPlanningManager'),
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text(
          'Planning Managers',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        onPressed: () async {
          await Navigator.pushNamed(context, '/createPlanningManager');
          _load();
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search planning manager',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => query = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LoadingIndicator(
                    message: 'Loading planning managers...',
                  );
                }

                final managers = (snapshot.data as List)
                    .where((m) =>
                (m["name"] ?? '')
                    .toLowerCase()
                    .contains(query) ||
                    (m["email"] ?? '')
                        .toLowerCase()
                        .contains(query))
                    .toList();

                if (managers.isEmpty) {
                  return const EmptyState(
                    title: 'No Planning Managers',
                    message: 'Tap + to create one',
                    icon: Icons.manage_accounts_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: managers.length,
                  itemBuilder: (context, index) {
                    final m = managers[index];
                    final isActive = m["status"] == "active";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                            AppColors.neonBlue.withOpacity(0.08),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor:
                            AppColors.primaryBlue.withOpacity(0.15),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m["name"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.navy),
                                ),
                                Text(
                                  m["email"],
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isActive,
                            onChanged: (v) async {
                              await PlanningManagerService()
                                  .toggleStatus(
                                  planningManagerId:
                                  m["planningManagerId"],
                                  activate: v);
                              _load();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ).inkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PlanningManagerDetailScreen(
                                  planningManagerId:
                                  m["planningManagerId"],
                                ),
                          ),
                        );
                        _load();
                        setState(() {});
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension _InkExt on Widget {
  Widget inkWell({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: this,
      ),
    );
  }
}
