import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'services/services.dart';
import 'component_details_screen.dart';
import 'component_create_screen.dart';

class ComponentListScreen extends StatefulWidget {
  final String productId;
  final String productName;

  const ComponentListScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ComponentListScreen> createState() =>
      _ComponentListScreenState();
}

class _ComponentListScreenState
    extends State<ComponentListScreen> {
  late Future<List<dynamic>> _components;

  @override
  void initState() {
    super.initState();
    _components = PlanningManagerService()
        .getComponentsByProduct(widget.productId);
  }

  void _refresh() {
    setState(() {
      _components = PlanningManagerService()
          .getComponentsByProduct(widget.productId);
    });
  }

  Future<void> _confirmDelete(
      String componentId,
      String componentName,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Component"),
        content: Text(
          "Are you sure you want to delete \"$componentName\"?\n",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await PlanningManagerService()
          .deleteComponent(componentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Component deleted")),
      );

      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text(
          widget.productName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ComponentCreateScreen(productId: widget.productId),
            ),
          );
          _refresh();
        },
        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: _components,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final components = snapshot.data ?? [];

          if (components.isEmpty) {
            return const Center(
              child: Text("No components found"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: components.length,
            itemBuilder: (context, index) {
              final c = components[index];
              final bool isActive = c["active"] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  title: Text(
                    c["component_name"] ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: Padding(
                    padding:
                    const EdgeInsets.only(top: 4),
                    child: Text(
                      "Code: ${c["component_code"]}",
                      style: const TextStyle(
                          color: Colors.grey),
                    ),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔹 STATUS CHIP
                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Text(
                          isActive ? "Active" : "Inactive",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w600,
                            color: isActive
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // 🗑 DELETE ICON
                      if (isActive)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _confirmDelete(
                            c["componentId"],
                            c["component_name"],
                          ),
                        ),
                    ],
                  ),

                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ComponentDetailsScreen(
                              componentId:
                              c["componentId"],
                            ),
                      ),
                    );
                    _refresh();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
