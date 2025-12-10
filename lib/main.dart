import 'package:flutter/material.dart'; // REQUIRED
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'core/services/gemini_service.dart';
import 'core/constants/api_constants.dart';
import 'core/ui/responsive_center_wrapper.dart';
import 'features/crm/services/brand_deal_service.dart';
import 'features/visual_audit/services/visual_audit_service.dart';
import 'ui/landing/landing_page.dart';
import 'ui/dashboard/dashboard_v2.dart';
import 'features/auth/login_screen.dart';
import 'features/gamification/services/gamification_service.dart';
import 'features/notifications/services/notification_service.dart';

import 'core/services/localization_service.dart';

import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => GeminiService(ApiConstants.geminiApiKey)),
        Provider(create: (_) => BrandDealService()),
        Provider(create: (_) => VisualAuditService()),
        ChangeNotifierProvider(create: (_) => LocalizationService()),
        ChangeNotifierProvider(create: (_) => GamificationService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: MaterialApp(
        title: 'MyManager.ai',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        scrollBehavior: const AppScrollBehavior(),
        builder: (context, child) => child!,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return RawScrollbar(
      controller: details.controller,
      thumbColor: const Color(0xFFFFC107).withOpacity(0.3),
      radius: const Radius.circular(8),
      thickness: 6,
      child: child,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthService>().isLoggedIn;
    return isLoggedIn ? const DashboardScreenV2() : const LandingPage();
  }
}
