// import 'package:flutter/material.dart';
//
// import '../../core/theme/app_colors.dart';
// import '../shared/widgets/admin_drawer.dart';
//
// import 'sections/enquiry_analytics_section.dart';
// import 'sections/quotation_analytics_section.dart';
// import 'sections/loi_analytics_section.dart';
// import 'sections/client_movement_section.dart';
//
// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});
//
//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }
//
// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   final PageController _pageController = PageController();
//   int _currentIndex = 0;
//
//   final List<String> _titles = ['Enquiry', 'Quotation', 'LOI'];
//
//   void _onTabTap(int index) {
//     setState(() => _currentIndex = index);
//     _pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       drawer: const AdminDrawer(currentRoute: '/adminDashboard'),
//       backgroundColor: AppColors.lightGrey,
//
//       appBar: AppBar(
//         backgroundColor: AppColors.navy,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           'Admin Dashboard',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.only(bottom: 20),
//         child: Column(
//           children: [
//             _SwapHeader(
//               titles: _titles,
//               currentIndex: _currentIndex,
//               onTap: _onTabTap,
//             ),
//
//             const SizedBox(height: 16),
//
//             SizedBox(
//               height: MediaQuery.of(context).size.height*0.80,
//               child: PageView(
//                 controller: _pageController,
//                 onPageChanged: (index) {
//                   setState(() => _currentIndex = index);
//                 },
//                 children: const [
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: EnquiryAnalyticsSection(),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: QuotationAnalyticsSection(),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: LoiAnalyticsSection(),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20),
//               child: ClientMovementSection(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _SwapHeader extends StatelessWidget {
//   final List<String> titles;
//   final int currentIndex;
//   final Function(int) onTap;
//
//   const _SwapHeader({
//     required this.titles,
//     required this.currentIndex,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: List.generate(titles.length, (index) {
//           final isActive = index == currentIndex;
//
//           return Expanded(
//             child: GestureDetector(
//               onTap: () => onTap(index),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 250),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   color: isActive
//                       ? AppColors.primaryBlue
//                       : Colors.transparent,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   titles[index],
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: isActive ? Colors.white : Colors.black87,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../shared/widgets/admin_drawer.dart';
import 'services/dashboard_service.dart';
import 'widgets/status_summary_section.dart';
import 'widgets/revenue_chart_section.dart';
import 'widgets/conversion_section.dart';
import 'widgets/top_managers_section.dart';
import 'widgets/recent_activity_section.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {

  final AdminDashboardService _service =
  AdminDashboardService();

  final PageController _kpiController = PageController();
  int _currentKpiPage = 0;

  late Future<void> _dashboardFuture;

  Map<String, dynamic> overview = {};
  Map<String, dynamic> status = {};
  List<Map<String, dynamic>> revenue = [];
  Map<String, dynamic> conversion = {};
  List<Map<String, dynamic>> managers = [];
  Map<String, dynamic> activity = {};

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final results = await Future.wait([
      _service.getOverviewKPIs(),
      _service.getStatusSummary(),
      _service.getMonthlyRevenue(),
      _service.getConversionRate(),
      _service.getTopSalesManagers(),
      _service.getRecentActivity(),
    ]);

    overview = results[0] as Map<String, dynamic>;
    status = results[1] as Map<String, dynamic>;
    revenue = results[2] as List<Map<String, dynamic>>;
    conversion = results[3] as Map<String, dynamic>;
    managers = results[4] as List<Map<String, dynamic>>;
    activity = results[5] as Map<String, dynamic>;
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
    await _dashboardFuture;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: const AdminDrawer(currentRoute: '/adminDashboard'),
      backgroundColor: AppColors.lightGrey,

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        leading: Builder(
          builder: (context) {
            if (Navigator.canPop(context)) {
              return IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.menu,
                    color: Colors.white),
                onPressed: () =>
                    Scaffold.of(context).openDrawer(),
              );
            }
          },
        ),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),

      body: FutureBuilder(
        future: _dashboardFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: SingleChildScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  /// ================= KPI SLIDER =================
                  Column(
                    children: [

                      AspectRatio(
                        aspectRatio:
                        width < 600 ? 1.1 : 1.6,
                        child: PageView(
                          controller: _kpiController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentKpiPage = index;
                            });
                          },
                          children: [

                            _buildKpiPage([
                              ["Companies", overview["totalCompanies"]],
                              ["Sales Managers", overview["totalSalesManagers"]],
                              ["Clients", overview["totalClients"]],
                              ["Products", overview["totalProducts"]],
                            ]),

                            _buildKpiPage([
                              ["Enquiries", overview["totalEnquiries"]],
                              ["Quotations", overview["totalQuotations"]],
                              ["Invoices", overview["totalInvoices"]],
                              ["Payments", overview["totalPayments"]],
                            ]),

                            _buildKpiPage([
                              ["Revenue", "₹ ${overview["totalRevenue"] ?? 0}"],
                            ]),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children:
                        List.generate(3, (index) {
                          return AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 300),
                            margin:
                            const EdgeInsets.symmetric(
                                horizontal: 4),
                            width:
                            _currentKpiPage ==
                                index
                                ? 18
                                : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                              _currentKpiPage ==
                                  index
                                  ? AppColors
                                  .primaryBlue
                                  : Colors.grey
                                  .shade400,
                              borderRadius:
                              BorderRadius
                                  .circular(8),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// ================= STATUS + CONVERSION =================
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      SizedBox(
                        width: width >= 1100
                            ? width * 0.48
                            : width,
                        child: StatusSummarySection(
                            status: status),
                      ),
                      SizedBox(
                        width: width >= 1100
                            ? width * 0.48
                            : width,
                        child: ConversionSection(
                            conversion: conversion),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// ================= REVENUE + MANAGERS =================
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      SizedBox(
                        width: width >= 1100
                            ? width * 0.48
                            : width,
                        child: RevenueChartSection(
                            data: revenue),
                      ),
                      SizedBox(
                        width: width >= 1100
                            ? width * 0.48
                            : width,
                        child: TopManagersSection(
                            managers: managers),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// ================= RECENT ACTIVITY =================
                  RecentActivitySection(
                      activity: activity),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiPage(List<List<dynamic>> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio:
            constraints.maxWidth < 400
                ? 1.2
                : 1.6,
          ),
          itemBuilder: (context, index) {
            return _buildModernKpiCard(
              items[index][0].toString(),
              items[index][1] ?? 0,
            );
          },
        );
      },
    );
  }

  Widget _buildModernKpiCard(
      String title, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius:
        BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color:
                AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



