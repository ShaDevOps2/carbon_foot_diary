import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../../domain/models.dart';

/// Goals management list and detail cards (FR-10).
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final goals = s.goals;

    return Scaffold(
      appBar: AppBar(title: const Text('Emission Goals')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Goal'),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateGoalScreen())),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: goals.isEmpty
              ? EmptyState(
                  icon: Icons.flag_outlined,
                  title: 'No goals set yet',
                  message: 'Set reduction targets to stay motivated and track improvements.',
                  action: 'Set your first goal',
                  onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateGoalScreen())),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: goals.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => GoalCard(goal: goals[i], showActions: true),
                ),
        ),
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, this.showActions = false});
  final Goal goal;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final actual = s.goalActual(goal);
    final status = s.goalStatus(goal);
    final progress = goal.target > 0 ? (actual / goal.target).clamp(0.0, 1.0) : 0.0;
    final t = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name, style: t.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${goal.period.name.toUpperCase()} · ${goal.category?.label ?? "All categories"}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              StatusPill(label: status.label, color: status.color, icon: status.icon),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Current: ${Fmt.kgShort(actual)} kg', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('Target: ${Fmt.kgShort(goal.target)} kg',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          SoftProgressBar(
            value: progress,
            color: status.color,
            height: 10,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.date_range_rounded, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                '${Fmt.dateShort(goal.start)} – ${Fmt.dateShort(goal.end)}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
              ),
              const Spacer(),
              if (showActions)
                IconButton(
                  tooltip: 'Delete goal',
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.coral),
                  onPressed: () async {
                    final ok = await confirmDialog(
                      context,
                      title: 'Delete this goal?',
                      message: 'Are you sure you want to remove "${goal.name}"?',
                      confirm: 'Delete',
                      destructive: true,
                    );
                    if (ok) s.deleteGoal(goal);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _target = TextEditingController();
  GoalPeriod _period = GoalPeriod.weekly;
  CategoryType? _category;

  void _save() {
    if (!_form.currentState!.validate()) return;
    final s = AppScope.read(context);
    final now = DateTime.now();
    final today = AppState.dayOf(now);
    final DateTime end;
    switch (_period) {
      case GoalPeriod.daily:
        end = today;
        break;
      case GoalPeriod.weekly:
        end = today.add(const Duration(days: 6));
        break;
      case GoalPeriod.monthly:
        end = DateTime(today.year, today.month + 1, 0);
        break;
    }
    final targetVal = double.parse(_target.text);
    s.saveGoal(Goal(
      id: 'g${DateTime.now().microsecondsSinceEpoch}',
      name: _name.text.trim(),
      period: _period,
      baseline: targetVal * 1.25,
      target: targetVal,
      start: today,
      end: end,
      category: _category,
    ));
    Navigator.pop(context);
    showSnack(context, 'Goal created!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set reduction goal')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Goal name',
                    hintText: 'e.g. Keep commute under 20 kg',
                    prefixIcon: Icon(Icons.flag_rounded),
                  ),
                  validator: (v) => Validators.required(v, 'Goal name'),
                ),
                const SizedBox(height: 16),
                Text('Period', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<GoalPeriod>(
                  segments: const [
                    ButtonSegment(value: GoalPeriod.daily, label: Text('Daily')),
                    ButtonSegment(value: GoalPeriod.weekly, label: Text('Weekly')),
                    ButtonSegment(value: GoalPeriod.monthly, label: Text('Monthly')),
                  ],
                  selected: {_period},
                  onSelectionChanged: (s) => setState(() => _period = s.first),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _target,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Target maximum (kg CO₂e)',
                    hintText: 'e.g. 50',
                    prefixIcon: Icon(Icons.track_changes_rounded),
                  ),
                  validator: Validators.positiveNumber,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CategoryType?>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category filter (optional)',
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All categories (Overall footprint)')),
                    for (final c in CategoryType.values)
                      DropdownMenuItem(value: c, child: Text(c.label)),
                  ],
                  onChanged: (v) => setState(() => _category = v),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Save Goal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
