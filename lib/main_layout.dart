import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/theme/app_colors.dart';
import 'core/services/auth_service.dart';
import '../../../../services/api_service.dart';

// ================= SALES MANAGER =================
import 'sales_manager/dashboard/sales_dashboard.dart';
import 'sales_manager/enquiries/sales_enquiry_list_screen.dart';
import 'sales_manager/clients/client_list_screen.dart';
import 'sales_manager/quotations/quotation_list_sales.dart';
import 'sales_manager/loi/loi_ack_screen.dart';
import 'sales_manager/invoices/invoice_home_screen.dart';
import 'sales_manager/profile/sales_profile_screen.dart';

// ================= CLIENT =================
import 'client/enquiries/client_enquiry_list_screen.dart';

// ================= AUTH =================
import 'auth/login/admin_login_screen.dart';

class MainLayout extends StatefulWidget {
  final String role; // sales_manager | client

  const MainLayout({
    super.key,
    required this.role,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  String profileImageUrl = "";
  bool loadingProfile = true;

  String get uid => auth.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadProfileImage();
  }

  // =====================================================
  // LOAD PROFILE IMAGE (API)
  // =====================================================

  Future<void> loadProfileImage() async {
    if (widget.role != "sales_manager") return;

    try {
      final res = await ApiService.get('/sales-managers/$uid');
      profileImageUrl = res['salesManager']?['profileImage'] ?? "";
    } catch (e) {
      debugPrint("LOAD PROFILE IMAGE ERROR => $e");
    } finally {
      if (mounted) setState(() => loadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget homeScreen = widget.role == 'sales_manager'
        ? const SalesDashboard()
        : const ClientEnquiryListScreen();

    return Scaffold(
      drawer: _buildDrawer(),

      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          widget.role == 'sales_manager'
              ? 'Sales Manager'
              : 'Client',
        ),
      ),

      body: homeScreen,
    );
  }

  // =====================================================
  // DRAWER
  // =====================================================

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.darkBlue,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildProfileHeader(),

          if (widget.role == 'sales_manager') ...[
            _menuTile('Dashboard', Icons.dashboard,
                    () => _push(const SalesDashboard())),
            _menuTile('Clients', Icons.people,
                    () => _push(const ClientListScreen())),
            _menuTile('Enquiries', Icons.assignment,
                    () => _push(const SalesEnquiryListScreen())),
            _menuTile('Quotations', Icons.description,
                    () => _push(const QuotationListSales())),
            _menuTile('LOI Approvals', Icons.verified,
                    () => _push(const LoiAckScreen())),
            _menuTile('Invoices', Icons.receipt_long,
                    () => _push(const InvoiceHomeScreen())),
            _menuTile('Profile', Icons.person,
                    () => _push(const SalesProfileScreen())),
          ],

          const Divider(color: Colors.white24),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PROFILE HEADER
  // =====================================================

  Widget _buildProfileHeader() {
    ImageProvider? avatar;

    if (profileImageUrl.isNotEmpty) {
      avatar = NetworkImage(profileImageUrl);
    }

    return DrawerHeader(
      decoration: const BoxDecoration(color: AppColors.navy),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SalesProfileScreen(),
                ),
              );
            },
            child: CircleAvatar(
              radius: 40,
              backgroundImage: avatar,
              backgroundColor: Colors.transparent,
              child: avatar == null
                  ? const Icon(
                Icons.person,
                size: 36,
                color: Colors.white,
              )
                  : null,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Sales Manager",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================

  void _push(Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> _logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
          (_) => false,
    );
  }

  Widget _menuTile(
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.neonBlue),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
}
