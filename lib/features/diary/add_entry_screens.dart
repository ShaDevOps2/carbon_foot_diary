import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../../domain/carbon_calculator.dart';
import '../../domain/models.dart';

/// Step 1: choose a category.
class CategoryPickerScreen extends StatelessWidget {
  const CategoryPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final cats = CategoryType.values.where((c) => !s.inactiveCategories.contains(c)).toList();
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(title: const Text('New entry')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text('What did you do?', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Choose a category to log an activity.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cats.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: width > 600 ? 240 : 200,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  mainAxisExtent: 160,
                ),
                itemBuilder: (_, i) {
                  final c = cats[i];
                  return FadeSlideIn(
                    index: i,
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityFormScreen(category: c))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CategoryAvatar(c, size: 52),
                          const Spacer(),
                          Text(c.label, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(c.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step 2: activity details with a live CO₂e preview.
class ActivityFormScreen extends StatefulWidget {
  const ActivityFormScreen({super.key, required this.category});
  final CategoryType category;

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _form = GlobalKey<FormState>();
  final _qty = TextEditingController();
  final _notes = TextEditingController();
  final _customName = TextEditingController();
  final _customUnit = TextEditingController(text: 'unit');
  final _customFactor = TextEditingController();
  Activity? _activity;
  DateTime _date = DateTime.now();
  int _passengers = 1;
  bool _roundTrip = false;
  double _renewable = 0;
  late String _unit;

  bool get _isCustom => widget.category == CategoryType.custom;

  @override
  void initState() {
    super.initState();
    final s = AppScope.read(context);
    final acts = s.activitiesFor(widget.category);
    _activity = acts.isEmpty ? null : acts.first;
    _unit = _defaultUnit(s.isMetric);
  }

  String _defaultUnit(bool metric) {
    final u = _activity?.unit ?? 'unit';
    if (!metric && u == 'km') return 'mi';
    if (!metric && u == 'kg') return 'lb';
    return u;
  }

  List<String> get _unitOptions {
    final u = _activity?.unit;
    if (u == 'km') return ['km', 'mi'];
    if (u == 'kg') return ['kg', 'lb', 'g'];
    if (u == 'L') return ['L', 'gal'];
    return [u ?? 'unit'];
  }

  double get _preview {
    final q = double.tryParse(_qty.text) ?? 0;
    final f = _isCustom
        ? (double.tryParse(_customFactor.text) ?? 0)
        : (AppScope.read(context).factorFor(_activity?.id ?? '')?.value ?? 0);
    return CarbonCalculator.calculate(
      quantity: q,
      unit: _unit,
      factor: f,
      passengers: _passengers,
      roundTrip: _roundTrip,
      renewablePercent: _renewable,
    );
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final s = AppScope.read(context);
    s.addEntry(
      activity: _isCustom ? null : _activity,
      category: widget.category,
      description: _isCustom ? _customName.text.trim() : _activity!.name,
      quantity: double.parse(_qty.text),
      unit: _isCustom ? _customUnit.text.trim() : _unit,
      date: _date,
      notes: _notes.text.trim(),
      customFactor: _isCustom ? double.parse(_customFactor.text) : null,
      passengers: _passengers,
      roundTrip: _roundTrip,
      renewable: _renewable,
    );
    Navigator.of(context).popUntil((r) => r.isFirst);
    showSnack(context, 'Entry saved · ${Fmt.kg(_preview)} kg CO₂e');
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = widget.category;
    final acts = s.activitiesFor(c);
    final factor = s.factorFor(_activity?.id ?? '');
    final isCar = ['car_petrol', 'car_ev', 'taxi'].contains(_activity?.id);
    final isFlight = _activity?.id.startsWith('flight') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CategoryAvatar(c, size: 36),
          const SizedBox(width: 12),
          Text(c.label),
        ]),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Form(
            key: _form,
            onChanged: () => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
              children: [
            if (!_isCustom) ...[
              Text('Activity', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final a in acts)
                    ChoiceChip(
                      avatar: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(c.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      label: Text(a.name),
                      selected: _activity == a,
                      showCheckmark: false,
                      selectedColor: c.color.withValues(alpha: 0.18),
                      side: BorderSide(color: _activity == a ? c.color : Theme.of(context).colorScheme.outlineVariant),
                      onSelected: (_) => setState(() {
                        _activity = a;
                        _unit = _defaultUnit(s.isMetric);
                        _roundTrip = false;
                        _passengers = 1;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ] else ...[
              TextFormField(
                controller: _customName,
                decoration: const InputDecoration(labelText: 'Activity name', prefixIcon: Icon(Icons.label_outline_rounded)),
                validator: (v) => Validators.required(v, 'Activity name'),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _qty,
                    autofocus: !_isCustom,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      helperText: _activity?.hint,
                      prefixIcon: Icon(_activity?.icon ?? Icons.numbers_rounded),
                    ),
                    validator: Validators.positiveNumber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _isCustom
                      ? TextFormField(
                          controller: _customUnit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          validator: (v) => Validators.required(v, 'Unit'),
                        )
                      : DropdownButtonFormField<String>(
                          key: ValueKey(_activity?.id),
                          initialValue: _unit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          borderRadius: BorderRadius.circular(16),
                          items: [for (final u in _unitOptions) DropdownMenuItem(value: u, child: Text(u))],
                          onChanged: (v) => setState(() => _unit = v ?? _unit),
                        ),
                ),
              ],
            ),
            if (_isCustom) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _customFactor,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Emission factor (kg CO₂e per unit)',
                  prefixIcon: Icon(Icons.science_outlined),
                  helperText: 'User-provided — will be clearly marked',
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null) return 'Enter a number';
                  if (n < 0) return 'Cannot be negative';
                  return null;
                },
              ),
            ],
            if (isCar) ...[
              const SizedBox(height: 20),
              _StepperRow(
                label: 'Passengers sharing',
                icon: Icons.groups_rounded,
                value: _passengers,
                onChanged: (v) => setState(() => _passengers = v),
              ),
            ],
            if (isFlight) ...[
              const SizedBox(height: 12),
              SwitchListTile(
                value: _roundTrip,
                onChanged: (v) => setState(() => _roundTrip = v),
                title: const Text('Round trip'),
                subtitle: const Text('Doubles the distance'),
                secondary: const Icon(Icons.sync_alt_rounded),
                contentPadding: EdgeInsets.zero,
              ),
            ],
            if (c == CategoryType.electricity) ...[
              const SizedBox(height: 20),
              Text('Renewable share: ${_renewable.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.titleSmall),
              Slider(
                value: _renewable,
                max: 100,
                divisions: 20,
                label: '${_renewable.toStringAsFixed(0)}%',
                onChanged: (v) => setState(() => _renewable = v),
              ),
            ],
            const SizedBox(height: 16),
            AppCard(
              padding: EdgeInsets.zero,
              radius: 16,
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _date = d);
              },
              child: ListTile(
                leading: const Icon(Icons.event_rounded),
                title: const Text('Date'),
                trailing: Text(Fmt.relativeDay(_date), style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes (optional)', prefixIcon: Icon(Icons.notes_rounded)),
            ),
            if (!_isCustom && factor != null) ...[
              const SizedBox(height: 16),
              Row(children: [
                Icon(Icons.verified_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Factor ${factor.value} ${factor.unit} · ${factor.source} · v${factor.version}',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ]),
            ],
          ],
        ),
      ),
    ),
  ),
  bottomSheet: Center(
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: _PreviewBar(value: _preview, color: c.color, onSave: _save),
    ),
  ),
);
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({required this.label, required this.icon, required this.value, required this.onChanged});
  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: Theme.of(context).textTheme.titleSmall)),
      IconButton.filledTonal(
        tooltip: 'Fewer',
        onPressed: value > 1 ? () => onChanged(value - 1) : null,
        icon: const Icon(Icons.remove_rounded),
      ),
      SizedBox(width: 36, child: Text('$value', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge)),
      IconButton.filledTonal(
        tooltip: 'More',
        onPressed: value < 8 ? () => onChanged(value + 1) : null,
        icon: const Icon(Icons.add_rounded),
      ),
    ]);
  }
}

class _PreviewBar extends StatelessWidget {
  const _PreviewBar({required this.value, required this.color, required this.onSave});
  final double value;
  final Color color;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estimated emission', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('≈ ${Fmt.kg(value)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    const Padding(padding: EdgeInsets.only(bottom: 4), child: Text('kg CO₂e')),
                  ],
                ),
              ],
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(140, 56), backgroundColor: AppColors.forest),
            onPressed: onSave,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
