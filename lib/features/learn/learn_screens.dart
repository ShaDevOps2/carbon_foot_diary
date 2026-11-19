import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../../data/seed_data.dart';
import '../../domain/models.dart';
import '../auth/auth_screens.dart';

/// Public learning hub for guests (2.1).
class GuestLearnScreen extends StatelessWidget {
  const GuestLearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn about carbon')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              AppCard(
                gradient: AppColors.heroGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.public_rounded, color: AppColors.mint, size: 36),
                    const SizedBox(height: 12),
                    Text('Small steps, real impact',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('Explore free guides below. Create an account to start your own carbon diary.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
                    const SizedBox(height: 16),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.forestDeep, minimumSize: const Size(160, 48)),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text('Join CFootNote'),
                    ),
                  ],
                ),
              ),
              const SectionHeader('Guides & tips'),
              ..._tipTiles(context),
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget> _tipTiles(BuildContext context) => [
      for (final (i, tip) in SeedData.tips.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FadeSlideIn(
            index: i,
            child: AppCard(
              padding: const EdgeInsets.all(16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TipDetailScreen(tip: tip))),
              child: Row(
                children: [
                  CategoryAvatar(tip.category, icon: tip.icon, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tip.title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('${tip.category == CategoryType.custom ? 'Basics' : tip.category.label} · ${tip.minutes} min read',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ),
    ];

/// Signed-in learning hub with quiz (FR-12).
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn & quiz')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              AppCard(
                gradient: AppColors.violetGradient,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen())),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Carbon quiz', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text('5 quick questions · +10 pts', style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100)),
                            child: const Text('Start quiz', style: TextStyle(color: Color(0xFF7B61E8), fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.psychology_alt_rounded, size: 72, color: Colors.white),
                  ],
                ),
              ),
              const SectionHeader('Guides & tips'),
              ..._tipTiles(context),
            ],
          ),
        ),
      ),
    );
  }
}

class TipDetailScreen extends StatelessWidget {
  const TipDetailScreen({super.key, required this.tip});
  final Tip tip;

  @override
  Widget build(BuildContext context) {
    final c = tip.category.color;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: c,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [c, c.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    ),
                    child: Center(child: Icon(tip.icon, size: 96, color: Colors.white.withValues(alpha: 0.9))),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList.list(
                  children: [
                    StatusPill(label: '${tip.minutes} min read', color: c, icon: Icons.schedule_rounded),
                    const SizedBox(height: 14),
                    Text(tip.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    Text(tip.body, style: const TextStyle(fontSize: 16, height: 1.65)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _q = 0;
  int? _picked;
  int _score = 0;
  bool _done = false;

  void _next() {
    if (_q == SeedData.quiz.length - 1) {
      AppScope.read(context)
        ..quizzesCompleted += 1
        ..refresh();
      setState(() => _done = true);
    } else {
      setState(() {
        _q++;
        _picked = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_done) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.emoji_events_rounded,
          title: 'You scored $_score / ${SeedData.quiz.length}',
          message: '+10 points added to your profile. Keep learning!',
          action: 'Done',
          onAction: () => Navigator.pop(context),
        ),
      );
    }
    final q = SeedData.quiz[_q];
    return Scaffold(
      appBar: AppBar(title: Text('Question ${_q + 1} of ${SeedData.quiz.length}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (_q + 1) / SeedData.quiz.length,
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 8,
                ),
                const SizedBox(height: 32),
                Text(q.question, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                for (var i = 0; i < q.options.length; i++) ...[
                  _OptionTile(
                    label: q.options[i],
                    state: _picked == null
                        ? 0
                        : i == q.answer
                            ? 1
                            : i == _picked
                                ? -1
                                : 0,
                    onTap: _picked != null
                        ? null
                        : () => setState(() {
                              _picked = i;
                              if (i == q.answer) _score++;
                            }),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_picked != null)
                  AppCard(
                    color: scheme.primaryContainer,
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Icon(Icons.lightbulb_rounded, color: scheme.primary),
                      const SizedBox(width: 12),
                      Expanded(child: Text(q.explain)),
                    ]),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _picked == null ? null : _next,
                  child: Text(_q == SeedData.quiz.length - 1 ? 'Finish' : 'Next question'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.state, this.onTap});
  final String label;
  final int state; // 1 correct, -1 wrong, 0 neutral
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = state == 1 ? AppColors.success : state == -1 ? AppColors.coral : null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.12) ?? Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color ?? Theme.of(context).colorScheme.outlineVariant, width: 1.6),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: state == 0
            ? null
            : Icon(state == 1 ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color,
                semanticLabel: state == 1 ? 'Correct' : 'Incorrect'),
      ),
    );
  }
}
