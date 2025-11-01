import 'package:attendance_admin_web/pages/attendance_page.dart';
import 'package:attendance_admin_web/pages/classes_page.dart';
import 'package:attendance_admin_web/pages/dashboard_page.dart';
import 'package:attendance_admin_web/pages/settings_page.dart';
import 'package:attendance_admin_web/pages/students_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'pages/login_page.dart';
import 'pages/shell.dart';
import 'services/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: '/students',
              builder: (context, state) => const StudentsPage(),
            ),
            GoRoute(
              path: '/classes',
              builder: (context, state) => const ClassesPage(),
            ),
            GoRoute(
              path: '/attendance',
              builder: (context, state) => const AttendancePage(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
      redirect: (context, state) async {
        final auth = AuthProvider.instance;
        final loggedIn = await auth.isLoggedIn();
        final loggingIn = state.fullPath == '/login';

        if (!loggedIn && !loggingIn) return '/login';
        if (loggedIn && loggingIn) return '/dashboard';
        return null;
      },
      refreshListenable: AuthProvider.instance,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider.instance),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Attendance Admin',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routerConfig: router,
      ),
    );
  }
}
