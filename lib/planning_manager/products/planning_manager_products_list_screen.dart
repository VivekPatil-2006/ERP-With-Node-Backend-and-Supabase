import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'services/services.dart';
import 'component_list_screen.dart';
import '../shared/widgets/planning_manager_drawer.dart';


class PlanningProductListScreen extends StatefulWidget {
  const PlanningProductListScreen({super.key});

  @override
  State<PlanningProductListScreen> createState() =>
      _PlanningProductListScreenState();
}

class _PlanningProductListScreenState
    extends State<PlanningProductListScreen> {
  late Future<List<dynamic>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = PlanningManagerService().getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,

      drawer: const PlanningManagerDrawer(
        currentRoute: '/planning_manager/products',
      ),

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text(
          "Products",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style:
                const TextStyle(color: Colors.red),
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text("No products found"),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 🔹 TWO CARDS PER ROW
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Card height
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];

              final productId = p["productId"];
              final title =
                  p["title"] ?? "Untitled Product";
              final itemNo =
                  p["item_no"]?.toString() ?? "-";

              // 🔹 Adjust this key if needed
              final stock = p["stock"] ?? 0;


              final imageUrl = p["product_image"];

              return InkWell(
                borderRadius:
                BorderRadius.circular(18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ComponentListScreen(
                            productId: productId,
                            productName: title,
                          ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.06),
                        blurRadius: 12,
                        offset:
                        const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // 🖼 IMAGE
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius:
                          const BorderRadius
                              .vertical(
                              top:
                              Radius.circular(
                                  18)),
                          color: AppColors
                              .primaryBlue
                              .withOpacity(0.08),
                        ),
                        child: imageUrl != null
                            ? ClipRRect(
                          borderRadius:
                          const BorderRadius
                              .vertical(
                              top: Radius
                                  .circular(
                                  18)),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        )
                            : const Icon(
                          Icons
                              .inventory_2_outlined,
                          size: 48,
                          color: AppColors
                              .primaryBlue,
                        ),
                      ),

                      // 📄 DETAILS
                      Expanded(
                        child: Padding(
                          padding:
                          const EdgeInsets.all(
                              12),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                  fontSize: 15,
                                  color:
                                  AppColors
                                      .navy,
                                ),
                              ),

                              const SizedBox(
                                  height: 6),

                              Text(
                                "Item No: $itemNo",
                                style:
                                const TextStyle(
                                  fontSize: 12,
                                  color:
                                  Colors.grey,
                                ),
                              ),

                              const Spacer(),

                              // 📦 STOCK
                              Container(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                    horizontal:
                                    10,
                                    vertical:
                                    6),
                                decoration:
                                BoxDecoration(
                                  color: stock > 0
                                      ? Colors.green
                                      .shade100
                                      : Colors.red
                                      .shade100,
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      20),
                                ),
                                child: Text(
                                  "Stock: $stock",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                    color: stock > 0
                                        ? Colors.green
                                        .shade800
                                        : Colors.red
                                        .shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
