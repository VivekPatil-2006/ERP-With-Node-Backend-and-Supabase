import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../auth/login/admin_login_screen.dart';

class SalesDrawer extends StatefulWidget {
  final String currentRoute;

  const SalesDrawer({
    super.key,
    required this.currentRoute,
  });

  static String? cachedProfileImage;   // 🔥 Cache variable
  static bool profileLoaded = false;   // 🔥 Load flag

  static String getTitle(String route) {
    switch (route) {
      case '/salesDashboard':
        return 'Dashboard';
      case '/salesClients':
        return 'Clients';
      case '/salesEnquiries':
        return 'Enquiries';
      case '/salesQuotations':
        return 'Quotations';
      case '/salesLoi':
        return 'LOI Approvals';
      case '/salesInvoices':
        return 'Invoices';
      case '/salesProfile':
        return 'Profile';
      default:
        return 'Sales Manager';
    }
  }

  @override
  State<SalesDrawer> createState() => _SalesDrawerState();
}

class _SalesDrawerState extends State<SalesDrawer> {
  bool loading = false;

  String get salesManagerId =>
      FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    // 🔥 Only call API if not already loaded
    if (!SalesDrawer.profileLoaded) {
      loadProfileImage();
    }
  }

  Future<void> loadProfileImage() async {
    try {
      setState(() => loading = true);

      final res =
      await ApiService.get('/sales-managers/$salesManagerId');

      final data = res['salesManager'];

      SalesDrawer.cachedProfileImage =
          data['profileImage'] ?? "";

      SalesDrawer.profileLoaded = true;   // 🔥 mark loaded
    } catch (_) {
      SalesDrawer.cachedProfileImage = "";
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: AppColors.navy,
      child: Column(
        children: [
          _header(context, user?.email ?? ''),
          const SizedBox(height: 10),

          _item(context, Icons.dashboard, 'Dashboard', '/salesDashboard'),
          _item(context, Icons.people, 'Clients', '/salesClients'),
          _item(context, Icons.assignment, 'Enquiries', '/salesEnquiries'),
          _item(context, Icons.description, 'Quotations', '/salesQuotations'),
          _item(context, Icons.verified, 'LOI Approvals', '/salesLoi'),
          _item(context, Icons.receipt_long, 'Invoices', '/salesInvoices'),

          const Spacer(),
          const Divider(color: Colors.white24),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () async {
              await AuthService().logout();

              // 🔥 Reset cache on logout
              SalesDrawer.profileLoaded = false;
              SalesDrawer.cachedProfileImage = null;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminLoginScreen(),
                ),
                    (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _header(BuildContext context, String email) {
    final profileImage = SalesDrawer.cachedProfileImage ?? "";

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/salesProfile');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navy, AppColors.darkBlue],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white24,
              backgroundImage: profileImage.isNotEmpty
                  ? NetworkImage(profileImage)
                  : null,
              child: profileImage.isEmpty
                  ? const Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              )
                  : null,
            ),
            const SizedBox(height: 14),
            const Text(
              'Sales Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              email,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "View Profile",
              style: TextStyle(
                color: AppColors.neonBlue,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
      BuildContext context,
      IconData icon,
      String title,
      String route,
      ) {
    final bool selected = widget.currentRoute == route;

    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AppColors.neonBlue : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? AppColors.neonBlue : Colors.white70,
        ),
      ),
      selected: selected,
      onTap: () {
        if (!selected) {
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}

