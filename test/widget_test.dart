import 'package:carbon_foot_diary/data/app_state.dart';
import 'package:carbon_foot_diary/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CFootNote app smoke test', (WidgetTester tester) async {
    final state = AppState();
    await tester.pumpWidget(CFootNoteApp(state: state));

    // Wait for splash screen delay
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify brand title is shown on onboarding
    expect(find.text('CFootNote'), findsWidgets);
  });

  testWidgets('EditProfileScreen renders cleanly without dropdown assertion crashes', (WidgetTester tester) async {
    final state = AppState();
    // u1 has the default values
    state.currentUser = state.users.first;

    await tester.pumpWidget(CFootNoteApp(state: state));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Navigate to profile tab (4th tab icon or Profile text)
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Tap edit pencil icon
    final editIcon = find.byTooltip('Edit profile');
    expect(editIcon, findsOneWidget);
    await tester.tap(editIcon);
    await tester.pumpAndSettle();

    // Verify Edit profile screen loaded successfully
    expect(find.text('Edit profile'), findsWidgets);
    expect(find.text('Lifestyle Details (for recommendations)'), findsOneWidget);
  });
}
