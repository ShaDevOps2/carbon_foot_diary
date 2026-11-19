import 'package:material_ui/material_ui.dart';

import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../../domain/models.dart';
import 'add_entry_screens.dart';
import 'entry_detail_screen.dart';

enum _Sort { newest, highest }

/// Diary history with search, filters, sorting and incremental loading (FR-04, FR-09).
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _search = TextEditingController();
  final Set<CategoryType> _cats = {};
  DateTimeRange? _range;
  RangeValues _emission = const RangeValues(0, 100);
  _Sort _sort = _Sort.newest;
  int _limit = 30;

  List<DiaryEntry> _filtered(AppState s) {
    final q = _search.text.trim().toLowerCase();
    final list = s.myEntries.where((e) {
      if (_cats.isNotEmpty && !_cats.contains(e.category)) return false;
      if (q.isNotEmpty && !e.description.toLowerCase().contains(q) && !e.notes.toLowerCase().contains(q)) return false;
      if (_range != null && (e.date.isBefore(_range!.start) || e.date.isAfter(_range!.end.add(const Duration(days: 1))))) return false;
      if (e.emission < _emission.start || (_emission.end < 100 && e.emission > _emission.end)) return false;
      return true;
    }).toList();
    if (_sort == _Sort.highest) list.sort((a, b) => b.emission.compareTo(a.emission));
    return list;
  }

  int get _activeFilters =>
      (_range != null ? 1 : 0) + (_emission != const RangeValues(0, 100) ? 1 : 0) + (_sort != _Sort.newest ? 1 : 0);

  Future<void> _openFilters() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setSheet) {
          void update(VoidCallback fn) {
            setSheet(fn);
            setState(() {});
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filter & sort', style: Theme.of(c).textTheme.titleLarge),
                const SizedBox(height: 20),
                Text('Sort by', style: Theme.of(c).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<_Sort>(
                  segments: const [
                    ButtonSegment(value: _Sort.newest, label: Text('Newest'), icon: Icon(Icons.schedule_rounded)),
                    ButtonSegment(value: _Sort.highest, label: Text('Highest CO₂e'), icon: Icon(Icons.trending_down_rounded)),
                  ],
                  selected: {_sort},
                  onSelectionChanged: (v) => update(() => _sort = v.first),
                ),
                const SizedBox(height: 20),
                Text('Date range', style: Theme.of(c).textTheme.titleSmall),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range_rounded),
                  label: Text(_range == null ? 'Any date' : '${Fmt.dateShort(_range!.start)} – ${Fmt.dateShort(_range!.end)}'),
                  onPressed: () async {
                    final r = await showDateRangePicker(
                      context: c,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                      initialDateRange: _range,
                    );
                    if (r != null) update(() => _range = r);
                  },
                ),
                const SizedBox(height: 20),
                Text('Emission per entry: ${Fmt.num(_emission.start)} – ${_emission.end >= 100 ? '100+' : Fmt.num(_emission.end)} kg',
                    style: Theme.of(c).textTheme.titleSmall),
                RangeSlider(
                  values: _emission,
                  max: 100,
                  divisions: 20,
                  labels: RangeLabels(Fmt.num(_emission.start), Fmt.num(_emission.end)),
                  onChanged: (v) => update(() => _emission = v),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => update(() {
                        _range = null;
                        _emission = const RangeValues(0, 100);
                        _sort = _Sort.newest;
                        _cats.clear();
                      }),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: () => Navigator.pop(c), child: const Text('Apply'))),
                ]),
              ],
            ),
          ),
        ),
      );
    },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final all = _filtered(s);
    final shown = all.take(_limit).toList();
    final scheme = Theme.of(context).colorScheme;

    // Group by day when sorted by date.
    final children = <Widget>[];
    DateTime? lastDay;
    for (final e in shown) {
      final day = AppState.dayOf(e.date);
      if (_sort == _Sort.newest && day != lastDay) {
        final dayTotal = all.where((x) => AppState.dayOf(x.date) == day).fold(0.0, (a, b) => a + b.emission);
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
          child: Row(children: [
            Text(Fmt.relativeDay(day), style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            Text('${Fmt.kg(dayTotal)} kg', style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
          ]),
        ));
        lastDay = day;
      }
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: EntryTile(
          entry: e,
          showDate: _sort != _Sort.newest,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EntryDetailScreen(entry: e))),
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My diary'),
        actions: [
          IconButton(
            tooltip: 'Filter and sort',
            onPressed: _openFilters,
            icon: Badge(isLabelVisible: _activeFilters > 0, label: Text('$_activeFilters'), child: const Icon(Icons.tune_rounded)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.extentAfter < 300 && _limit < all.length) setState(() => _limit += 30);
              return false;
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() => _limit = 30),
                      decoration: InputDecoration(
                        hintText: 'Search activities or notes',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () => setState(() => _search.clear()),
                              ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                      children: [
                        for (final c in CategoryType.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              avatar: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(c.imagePath),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              label: Text(c.label),
                              selected: _cats.contains(c),
                              showCheckmark: false,
                              onSelected: (v) => setState(() => v ? _cats.add(c) : _cats.remove(c)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('${all.length} entries · ${Fmt.kg(all.fold(0.0, (a, b) => a + b.emission))} kg CO₂e',
                          style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                if (all.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No matching entries',
                      message: 'Try a different search or clear your filters.',
                      action: 'Add an entry',
                      onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryPickerScreen())),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverList.list(children: [
                      ...children,
                      if (_limit < all.length)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    ]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
