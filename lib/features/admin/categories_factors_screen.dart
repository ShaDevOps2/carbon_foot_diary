import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../../domain/models.dart';

/// Manage Emission Factors, Version History, and Categories (FR-06, FR-18).
class CategoriesAndFactorsScreen extends StatefulWidget {
  const CategoriesAndFactorsScreen({super.key});

  @override
  State<CategoriesAndFactorsScreen> createState() => _CategoriesAndFactorsScreenState();
}

class _CategoriesAndFactorsScreenState extends State<CategoriesAndFactorsScreen> {
  final _search = TextEditingController();

  void _editFactor(EmissionFactor f) {
    final valController = TextEditingController(text: f.value.toString());
    final srcController = TextEditingController(text: f.source);

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Edit Factor: ${f.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Factor Value (${f.unit})'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: srcController,
              decoration: const InputDecoration(labelText: 'Data Source'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final newVal = double.tryParse(valController.text);
              if (newVal != null && newVal >= 0) {
                AppScope.read(context).updateFactor(f, newVal, srcController.text.trim());
                Navigator.pop(c);
                showSnack(context, 'Factor updated to v${f.version}');
              }
            },
            child: const Text('Save & Bump Version'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final q = _search.text.trim().toLowerCase();
    final factors = s.factors.where((f) {
      if (q.isEmpty) return true;
      return f.id.toLowerCase().contains(q) || f.source.toLowerCase().contains(q) || f.region.toLowerCase().contains(q);
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Content & Factors'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Emission Factors'),
              Tab(text: 'Categories'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Factors
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search emission factors or sources',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    itemCount: factors.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final f = factors[i];
                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(f.id, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.forest.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                  child: Text('v${f.version}', style: const TextStyle(color: AppColors.forest, fontSize: 10, fontWeight: FontWeight.w800)),
                                ),
                                const Spacer(),
                                Switch(
                                  value: f.active,
                                  onChanged: (_) => s.toggleFactor(f),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${f.value} ${f.unit}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('Source: ${f.source} (${f.year}) · ${f.region}',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.edit_rounded, size: 16),
                                  label: const Text('Edit factor'),
                                  onPressed: () => _editFactor(f),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Tab 2: Categories
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: CategoryType.values.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final c = CategoryType.values[i];
                final active = !s.inactiveCategories.contains(c);
                return AppCard(
                  child: Row(
                    children: [
                      CategoryAvatar(c, size: 44),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            Text(c.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                      ),
                      Switch(
                        value: active,
                        onChanged: (_) => s.toggleCategory(c),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  ),
);
  }
}
