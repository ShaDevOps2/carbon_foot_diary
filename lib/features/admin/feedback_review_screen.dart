import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../../domain/models.dart';

/// Review and respond to user feedback tickets (FR-19).
class FeedbackReviewScreen extends StatefulWidget {
  const FeedbackReviewScreen({super.key});

  @override
  State<FeedbackReviewScreen> createState() => _FeedbackReviewScreenState();
}

class _FeedbackReviewScreenState extends State<FeedbackReviewScreen> {
  void _respond(FeedbackItem f) {
    final respController = TextEditingController(text: f.response);
    String status = f.status;

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setDialog) => AlertDialog(
          title: Text('Respond to Feedback: ${f.subject}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.description, style: const TextStyle(fontSize: 13, height: 1.4)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  for (final s in ['Open', 'In review', 'Resolved'])
                    DropdownMenuItem(value: s, child: Text(s)),
                ],
                onChanged: (v) => setDialog(() => status = v ?? status),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: respController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Response to user'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                AppScope.read(context).respondFeedback(f, respController.text.trim(), status);
                Navigator.pop(c);
                showSnack(context, 'Response saved');
              },
              child: const Text('Send response'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final feedback = s.feedback;

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Review')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: feedback.isEmpty
              ? const EmptyState(
                  icon: Icons.mark_email_read_rounded,
                  title: 'No pending feedback',
                  message: 'All user submissions have been addressed.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
              itemCount: feedback.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final f = feedback[i];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusPill(label: f.type, color: Theme.of(context).colorScheme.primary),
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
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Response: ${f.response}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Submitted ${Fmt.date(f.createdAt)}',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                          const Spacer(),
                          TextButton.icon(
                            icon: const Icon(Icons.reply_rounded, size: 16),
                            label: const Text('Respond'),
                            onPressed: () => _respond(f),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ),
      ),
    );
  }
}
