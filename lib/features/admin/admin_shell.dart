import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../data/app_state.dart';
import 'admin_dashboard.dart';
import 'categories_factors_screen.dart';
import 'feedback_review_screen.dart';
import 'user_management_screen.dart';

/// Navigation shell for administrators (FR-16, 2.3).
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final isWide = MediaQuery.sizeOf(context).width > 700;

    final pages = const [
      AdminDashboardScreen(),
      UserManagementScreen(),
      CategoriesAndFactorsScreen(),
      FeedbackReviewScreen(),
    ];

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Icon(Icons.shield_rounded, color: AppColors.forest, size: 36),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IconButton(
                      tooltip: 'Log out',
                      icon: const Icon(Icons.logout_rounded, color: AppColors.coral),
                      onPressed: () => s.logout(),
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: Text('Overview')),
                NavigationRailDestination(icon: Icon(Icons.people_outline_rounded), selectedIcon: Icon(Icons.people_rounded), label: Text('Users')),
                NavigationRailDestination(icon: Icon(Icons.science_outlined), selectedIcon: Icon(Icons.science_rounded), label: Text('Factors')),
                NavigationRailDestination(icon: Icon(Icons.rate_review_outlined), selectedIcon: Icon(Icons.rate_review_rounded), label: Text('Feedback')),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: pages[_tab]),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.people_outline_rounded), selectedIcon: Icon(Icons.people_rounded), label: 'Users'),
          NavigationDestination(icon: Icon(Icons.science_outlined), selectedIcon: Icon(Icons.science_rounded), label: 'Factors'),
          NavigationDestination(icon: Icon(Icons.rate_review_outlined), selectedIcon: Icon(Icons.rate_review_rounded), label: 'Feedback'),
        ],
      ),
    );
  }
}
