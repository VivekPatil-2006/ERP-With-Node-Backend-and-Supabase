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

enum SalesPage {
  dashboard,
  clients,
  enquiries,
  quotations,
  loi,
  invoices,
  profile,
}

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

  SalesPage currentPage = SalesPage.dashboard;

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

  // =====================================================
  // BODY SWITCHER (🔥 KEY FIX)
  // =====================================================

  Widget _buildBody() {
    if (widget.role == 'client') {
      return const ClientEnquiryListScreen();
    }

    switch (currentPage) {
      case SalesPage.dashboard:
        return const SalesDashboard();
      case SalesPage.clients:
        return const ClientListScreen();
      case SalesPage.enquiries:
        return const SalesEnquiryListScreen();
      case SalesPage.quotations:
        return const QuotationListSales();
      case SalesPage.loi:
        return const LoiAckScreen();
      case SalesPage.invoices:
        return const InvoiceHomeScreen();
      case SalesPage.profile:
        return const SalesProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
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

      body: _buildBody(),
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
            _menuTile(
              'Dashboard',
              Icons.dashboard,
                  () => _selectPage(SalesPage.dashboard),
            ),
            _menuTile(
              'Clients',
              Icons.people,
                  () => _selectPage(SalesPage.clients),
            ),
            _menuTile(
              'Enquiries',
              Icons.assignment,
                  () => _selectPage(SalesPage.enquiries),
            ),
            _menuTile(
              'Quotations',
              Icons.description,
                  () => _selectPage(SalesPage.quotations),
            ),
            _menuTile(
              'LOI Approvals',
              Icons.verified,
                  () => _selectPage(SalesPage.loi),
            ),
            _menuTile(
              'Invoices',
              Icons.receipt_long,
                  () => _selectPage(SalesPage.invoices),
            ),
            _menuTile(
              'Profile',
              Icons.person,
                  () => _selectPage(SalesPage.profile),
            ),
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
            onTap: () => _selectPage(SalesPage.profile),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.transparent,
              backgroundImage: avatar,
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

  void _selectPage(SalesPage page) {
    Navigator.pop(context); // close drawer
    setState(() => currentPage = page);
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
