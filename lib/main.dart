import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'client/dashboard/client_dashboard.dart';
import 'client/invoices/client_invoice_list_screen.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';

// ================= AUTH =================
import 'auth/login/admin_login_screen.dart';
import 'auth/register/admin_register_screen.dart';

// ================= ADMIN =================
import 'admin/dashboard/admin_dashboard_screen.dart';
import 'admin/planning_manager/planning_manager_list_screen.dart';
import 'admin/planning_manager/planning_manager_create_screen.dart';
import 'admin/sales_managers/sales_manager_list_screen.dart';
import 'admin/sales_managers/sales_manager_create_screen.dart';
import 'admin/clients/client_list_screen.dart'; // contains AdminClientListScreen
import 'admin/clients/client_create_screen.dart';
import 'admin/company/company_profile_screen.dart';
import 'admin/products/product_list_screen.dart';
import 'admin/products/product_create_screen.dart';

// ================= SALES MANAGER =================
import 'sales_manager/dashboard/sales_dashboard.dart';
import 'sales_manager/enquiries/sales_enquiry_list_screen.dart';
import 'sales_manager/clients/client_list_screen.dart'; // contains SalesClientListScreen
import 'sales_manager/quotations/quotation_list_sales.dart';
import 'sales_manager/loi/loi_ack_screen.dart';
import 'sales_manager/invoices/invoice_home_screen.dart';
import 'sales_manager/profile/sales_profile_screen.dart';

// ================= CLIENT =================
import 'client/enquiries/client_enquiry_list_screen.dart';
import 'client/quotations/client_quotation_list_screen.dart';
import 'client/payments/client_payment_screen.dart';
import 'client/payments/list_client_payments_screen.dart';
import 'client/profile/client_profile_screen.dart';

// ================= CORE =================
import 'core/guards/admin_auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DealTrackApp());
}

class DealTrackApp extends StatelessWidget {
  const DealTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deal Track',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // ✅ Fixed deprecated textScaleFactor
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.22),
          ),
          child: child!,
        );
      },

      initialRoute: '/login',

      routes: {
        // ================= AUTH =================
        '/login': (_) => const AdminLoginScreen(),
        '/register': (_) => const AdminRegisterScreen(),

        // ================= ADMIN =================
        // '/adminDashboard': (_) => const AdminAuthGuard(
        //   child: AdminDashboardScreen(),
        // ),

        '/listPlanningManager': (_) => const AdminAuthGuard(
          child: PlanningManagerListScreen(),
        ),

        '/createPlanningManager': (_) => const AdminAuthGuard(
          child: PlanningManagerCreateScreen(),
        ),

        '/salesManagers': (_) => const AdminAuthGuard(
          child: SalesManagerListScreen(),
        ),

        '/createSalesManager': (_) => const AdminAuthGuard(
          child: SalesManagerCreateScreen(),
        ),

        '/clients': (_) => const AdminAuthGuard(
          child: AdminClientListScreen(),
        ),

        '/createClient': (_) => const AdminAuthGuard(
          child: ClientCreateScreen(),
        ),

        '/companyProfile': (_) => const AdminAuthGuard(
          child: CompanyProfileScreen(),
        ),

        '/products': (_) => const AdminAuthGuard(
          child: ProductListScreen(),
        ),

        '/createProduct': (_) => const AdminAuthGuard(
          child: ProductCreateScreen(),
        ),

        // ================= SALES MANAGER =================
        '/salesDashboard': (_) => const SalesDashboard(),
        '/salesEnquiries': (_) => const SalesEnquiryListScreen(),
        '/salesClients': (_) => const SalesClientListScreen(),
        '/salesQuotations': (_) => const QuotationListSales(),
        '/salesLoi': (_) => const LoiAckScreen(),
        '/salesInvoices': (_) => const InvoiceHomeScreen(),
        '/salesProfile': (_) => const SalesProfileScreen(),

        // ================= CLIENT =================
        '/clientEnquiries': (_) => const ClientEnquiryListScreen(),
        '/clientQuotations': (_) => const ClientQuotationListScreen(),
        '/clientPayments': (_) => const ClientPaymentScreen(),
        '/clientInvoices': (_) => const ClientInvoiceListScreen(),
        '/clientDashboard': (_) => const ClientDashboard(),


        // ❗ Cannot be const because UID is runtime
        '/clientProfile': (_) => ClientProfileScreen(
          clientId: FirebaseAuth.instance.currentUser!.uid,
        ),
      },
    );
  }
}
