import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../dashboard/dashboard_screen.dart';
import '../diary/add_entry_screens.dart';
import '../diary/diary_screen.dart';
import '../profile/profile_screen.dart';
import '../reports/insights_screen.dart';

/// Bottom-navigation shell for registered users.
class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _tab = 0;

  void _go(int i) => setState(() => _tab = i);

  void _openAdd() => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryPickerScreen()));

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(onSeeDiary: () => _go(1), onSeeInsights: () => _go(2)),
      const DiaryScreen(),
      const InsightsScreen(),
      const ProfileScreen(),
    ];
    // Nav index 2 is the centre "Add" action.
    final navIndex = _tab >= 2 ? _tab + 1 : _tab;
    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navIndex,
        onDestinationSelected: (i) {
          if (i == 2) return _openAdd();
          _go(i > 2 ? i - 1 : i);
        },
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          const NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Diary'),
          NavigationDestination(
            icon: Container(
              width: 52,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.mintGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.mint.withValues(alpha: 0.45), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
            label: 'Add',
          ),
          const NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights_rounded), label: 'Insights'),
          const NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
