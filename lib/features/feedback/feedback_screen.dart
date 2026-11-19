import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';

/// User feedback submission and status tracker (FR-19).
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _desc = TextEditingController();
  String _type = 'Feature suggestion';

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final s = AppScope.read(context);
    s.submitFeedback(_type, _subject.text.trim(), _desc.text.trim());
    _subject.clear();
    _desc.clear();
    showSnack(context, 'Feedback submitted! Thank you.');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final myFeedback = s.feedback.where((f) => f.userId == s.currentUser?.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback & Support')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
          Text('How can we improve?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Report bugs, request features, or share thoughts on calculations.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          Form(
            key: _form,
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Feedback Type', prefixIcon: Icon(Icons.category_outlined)),
                    borderRadius: BorderRadius.circular(16),
                    items: [
                      for (final t in ['Feature suggestion', 'Bug report', 'Calculation concern', 'General feedback'])
                        DropdownMenuItem(value: t, child: Text(t)),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? _type),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _subject,
                    decoration: const InputDecoration(labelText: 'Subject', prefixIcon: Icon(Icons.title_rounded)),
                    validator: (v) => Validators.required(v, 'Subject'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _desc,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Provide details to help us investigate or understand your idea...',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => Validators.required(v, 'Description'),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Submit Feedback'),
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
          if (myFeedback.isNotEmpty) ...[
            const SectionHeader('Your previous submissions'),
            for (final f in myFeedback) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusPill(
                            label: f.type,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const Spacer(),
                          StatusPill(
                            label: f.status,
                            color: f.status == 'Resolved' ? AppColors.forest : AppColors.amber,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(f.subject, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(f.description, style: const TextStyle(fontSize: 14)),
                      if (f.response.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Admin Response:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.primary)),
                              const SizedBox(height: 2),
                              Text(f.response, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(Fmt.date(f.createdAt),
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    ),
  ),
);
  }
}
