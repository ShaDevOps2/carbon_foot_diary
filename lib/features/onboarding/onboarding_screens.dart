import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../auth/auth_screens.dart';
import '../learn/learn_screens.dart';

/// Brand logo mark: a leaf inside a soft rounded square.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72, this.onDark = true});
  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: onDark ? null : AppColors.heroGradient,
        color: onDark ? Colors.white.withValues(alpha: 0.16) : null,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: onDark ? Border.all(color: Colors.white.withValues(alpha: 0.25)) : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.eco_rounded, color: onDark ? AppColors.mint : Colors.white, size: size * 0.55),
          Positioned(
            right: size * 0.18,
            bottom: size * 0.18,
            child: Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: onDark ? Colors.white : AppColors.mint,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit_rounded, size: size * 0.12, color: AppColors.forest),
            ),
          ),
        ],
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            const _Blobs(),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutBack,
                builder: (_, v, c) => Opacity(opacity: ((v - 0.6) / 0.4).clamp(0, 1), child: Transform.scale(scale: v, child: c)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandMark(size: 96),
                    const SizedBox(height: 24),
                    Text('CFootNote',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('Every step leaves a note.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Decorative soft circles for gradient backgrounds.
class _Blobs extends StatelessWidget {
  const _Blobs();

  @override
  Widget build(BuildContext context) {
    Widget blob(double size, Color c) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: c),
        );
    return Stack(
      children: [
        Positioned(top: -80, right: -60, child: blob(260, Colors.white.withValues(alpha: 0.06))),
        Positioned(top: 140, left: -90, child: blob(200, AppColors.mint.withValues(alpha: 0.12))),
        Positioned(bottom: -120, right: -40, child: blob(320, Colors.white.withValues(alpha: 0.05))),
      ],
    );
  }
}

class _Page {
  const _Page(this.icon, this.title, this.body, this.gradient);
  final IconData icon;
  final String title;
  final String body;
  final Gradient gradient;
}

const _pages = [
  _Page(Icons.edit_note_rounded, 'Log your day\nin seconds',
      'Record trips, meals, energy and more. CFootNote turns them into an estimated carbon footprint.', AppColors.heroGradient),
  _Page(Icons.insights_rounded, 'See what\nmatters most',
      'Beautiful charts reveal your highest-impact activities across days, weeks and months.', AppColors.oceanGradient),
  _Page(Icons.emoji_events_rounded, 'Grow greener\nhabits',
      'Set goals, get gentle suggestions, take on challenges and earn badges along the way.', AppColors.sunsetGradient),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: Stack(
        children: [
          // Realistic lush forest/nature background photography
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding_forest.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.asset(
                'assets/images/leaf_hero_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Deep organic gradient overlay for contrast and atmosphere
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF071B12).withValues(alpha: 0.85),
                    const Color(0xFF0F3D2C).withValues(alpha: 0.72),
                    const Color(0xFF071B12).withValues(alpha: 0.94),
                  ],
                ),
              ),
            ),
          ),
          const _Blobs(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
                  child: Row(
                    children: [
                      const BrandMark(size: 40),
                      const SizedBox(width: 10),
                      const Text('CFootNote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuestLearnScreen())),
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        child: const Text('Explore as guest'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => _OnboardPage(page: _pages[i]),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _pages.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _index ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: i == _index ? 1 : 0.4),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                  child: Column(
                    children: [
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.forestDeep),
                        onPressed: () {
                          if (last) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                          } else {
                            _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
                          }
                        },
                        child: Text(last ? 'Create free account' : 'Next'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.4),
                        ),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: const Text('I already have an account'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
);
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.page});
  final _Page page;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
              ),
              child: Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.18)),
                  child: Icon(page.icon, size: 54, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(page.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, height: 1.15)),
          const SizedBox(height: 12),
          Text(page.body,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15, height: 1.45)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
