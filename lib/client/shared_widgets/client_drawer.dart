import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../auth/login/admin_login_screen.dart';

class ClientDrawer extends StatelessWidget {
  final String currentRoute;

  const ClientDrawer({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: AppColors.navy,
      child: Column(
        children: [
          _header(user?.email ?? ''),

          const SizedBox(height: 10),

          _item(context, Icons.assignment, 'Enquiries', '/clientEnquiries'),
          _item(context, Icons.description, 'Quotations', '/clientQuotations'),
          _item(context, Icons.payment, 'Payments', '/clientPayments'),
          _item(context, Icons.receipt_long, 'Invoices', '/clientInvoices'),
          _item(context, Icons.person, 'Profile', '/clientProfile'),

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

  Widget _header(String email) {
    return Container(
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
            child: const Icon(
              Icons.business,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Client',
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
        ],
      ),
    );
  }

  Widget _item(
      BuildContext context,
      IconData icon,
      String title,
      String route,
      ) {
    final bool selected = currentRoute == route;

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
