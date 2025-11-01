import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_provider.dart';
import 'dashboard_page.dart';
import 'students_page.dart';
import 'classes_page.dart';
import 'attendance_page.dart';
import 'settings_page.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _idxFromLocation(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/students')) return 1;
    if (location.startsWith('/classes')) return 2;
    if (location.startsWith('/attendance')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selected = _idxFromLocation(location);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Admin'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await AuthProvider.instance.logout();
              if (mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selected,
            onDestinationSelected: (i) {
              switch (i) {
                case 0: context.go('/dashboard'); break;
                case 1: context.go('/students'); break;
                case 2: context.go('/classes'); break;
                case 3: context.go('/attendance'); break;
                case 4: context.go('/settings'); break;
              }
            },
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: Text('Students')),
              NavigationRailDestination(icon: Icon(Icons.class_outlined), selectedIcon: Icon(Icons.class_), label: Text('Classes')),
              NavigationRailDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check), label: Text('Attendance')),
              NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('Settings')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _routeChildFor(location)),
        ],
      ),
    );
  }

  Widget _routeChildFor(String location) {
    if (location.startsWith('/students')) return const StudentsPage();
    if (location.startsWith('/classes')) return const ClassesPage();
    if (location.startsWith('/attendance')) return const AttendancePage();
    if (location.startsWith('/settings')) return const SettingsPage();
    return const DashboardPage();
  }
}