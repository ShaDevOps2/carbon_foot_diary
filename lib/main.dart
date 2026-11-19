import 'package:material_ui/material_ui.dart';

import 'core/theme/app_theme.dart';
import 'data/app_state.dart';
import 'features/admin/admin_shell.dart';
import 'features/onboarding/onboarding_screens.dart';
import 'features/shell/user_shell.dart';

void main() {
  runApp(CFootNoteApp(state: AppState()));
}

class CFootNoteApp extends StatelessWidget {
  const CFootNoteApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: Builder(
        builder: (context) {
          final s = AppScope.of(context);
          return MaterialApp(
            title: 'CFootNote',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: s.themeMode,
            home: const RootGate(),
          );
        },
      ),
    );
  }
}

/// Chooses between the guest flow, user shell and admin shell.
class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final Widget child;
    if (!_splashDone) {
      child = SplashScreen(onDone: () => setState(() => _splashDone = true));
    } else if (s.currentUser == null) {
      child = const OnboardingScreen();
    } else if (s.isAdmin) {
      child = const AdminShell();
    } else {
      child = const UserShell();
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: KeyedSubtree(key: ValueKey(child.runtimeType), child: child),
    );
  }
}
