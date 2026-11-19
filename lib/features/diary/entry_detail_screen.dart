import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../../domain/models.dart';

/// Detailed view of a diary entry showing the calculation trail (FR-04, FR-05).
class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key, required this.entry});
  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final c = entry.category;
    final latestFactor = s.factorFor(entry.activityId);
    final isOutdated = latestFactor != null &&
        (latestFactor.version != entry.factorVersion || latestFactor.value != entry.factorValue);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity details'),
        actions: [
          IconButton(
            tooltip: 'Edit entry',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditEntryScreen(entry: entry)),
            ),
          ),
          IconButton(
            tooltip: 'Delete entry',
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coral),
            onPressed: () async {
              final ok = await confirmDialog(
                context,
                title: 'Delete this entry?',
                message: 'This activity (${entry.description}) will be permanently removed from your diary.',
                confirm: 'Delete',
                destructive: true,
              );
              if (ok && context.mounted) {
                s.deleteEntry(entry);
                Navigator.pop(context);
                showSnack(context, 'Entry deleted');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
          Hero(
            tag: 'entry-${entry.id}',
            child: AppCard(
              gradient: LinearGradient(
                colors: [c.color.withValues(alpha: 0.85), c.color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(c.icon, color: Colors.white, size: 28),
                      ),
                      const Spacer(),
                      if (entry.isUserFactor)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text('Custom factor',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(entry.description,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('${Fmt.num(entry.quantity)} ${entry.unit} · ${Fmt.date(entry.date)}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15)),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(Fmt.kg(entry.emission),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 6),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('kg CO₂e', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (entry.avoided > 0) ...[
            const SizedBox(height: 14),
            AppCard(
              color: AppColors.mintSoft,
              child: Row(
                children: [
                  const Icon(Icons.eco_rounded, color: AppColors.forest, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Avoided emissions',
                            style: TextStyle(color: AppColors.forestDeep, fontWeight: FontWeight.w700)),
                        Text('${Fmt.kg(entry.avoided)} kg CO₂e diverted from landfill (tracked separately)',
                            style: const TextStyle(color: AppColors.forestDeep, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isOutdated) ...[
            const SizedBox(height: 14),
            AppCard(
              color: AppColors.amber.withValues(alpha: 0.14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.update_rounded, color: AppColors.amber),
                      const SizedBox(width: 8),
                      Text('New emission factor available',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('This entry used factor v${entry.factorVersion} (${entry.factorValue}). The latest factor is v${latestFactor.version} (${latestFactor.value}).',
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () {
                      s.recalculateWithLatest(entry);
                      showSnack(context, 'Recalculated with latest factor');
                    },
                    child: const Text('Recalculate now'),
                  ),
                ],
              ),
            ),
          ],
          const SectionHeader('Calculation trail'),
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _Row('Entry ID', entry.id),
                const Divider(),
                _Row('Category', entry.category.label),
                const Divider(),
                _Row('Activity quantity', '${Fmt.num(entry.quantity)} ${entry.unit}'),
                const Divider(),
                _Row('Factor ID', entry.factorId),
                const Divider(),
                _Row('Factor value', '${entry.factorValue} kg CO₂e / ${entry.unit}'),
                const Divider(),
                _Row('Factor version', 'v${entry.factorVersion}'),
                const Divider(),
                _Row('Calculation formula', '${Fmt.num(entry.quantity)} × ${entry.factorValue} = ${Fmt.kg(entry.emission)} kg'),
                const Divider(),
                _Row('Created at', Fmt.date(entry.createdAt)),
                const Divider(),
                _Row('Last updated', Fmt.date(entry.updatedAt)),
              ],
            ),
          ),
          if (entry.notes.isNotEmpty) ...[
            const SectionHeader('Notes'),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entry.notes, style: const TextStyle(fontSize: 15, height: 1.5))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const EstimateNote(),
        ],
      ),
    ),
  ),
);
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13))),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

class EditEntryScreen extends StatefulWidget {
  const EditEntryScreen({super.key, required this.entry});
  final DiaryEntry entry;

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _qty;
  late final TextEditingController _notes;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _qty = TextEditingController(text: widget.entry.quantity.toString());
    _notes = TextEditingController(text: widget.entry.notes);
    _date = widget.entry.date;
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    AppScope.read(context).updateEntry(
      widget.entry,
      quantity: double.parse(_qty.text),
      date: _date,
      notes: _notes.text.trim(),
    );
    Navigator.pop(context);
    showSnack(context, 'Entry updated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit entry')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _qty,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    suffixText: widget.entry.unit,
                    prefixIcon: const Icon(Icons.numbers_rounded),
                  ),
                  validator: Validators.positiveNumber,
                ),
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
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes', prefixIcon: Icon(Icons.notes_rounded)),
                ),
                const SizedBox(height: 32),
                FilledButton(onPressed: _save, child: const Text('Save changes')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
