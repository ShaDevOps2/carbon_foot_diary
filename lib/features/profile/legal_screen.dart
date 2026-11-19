import 'package:material_ui/material_ui.dart';

/// Terms of use and privacy policy (NFR-03).
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  static const _sections = [
    ('What we collect', 'Your name, email, country, unit preference and the diary entries you choose to record. Optional profile details (household size, vehicle, diet) are only used to personalise suggestions.'),
    ('Why we collect it', 'To calculate estimated emissions, show your progress, and provide relevant recommendations. We never sell your personal data.'),
    ('Your rights', 'You can view, correct, export or delete your information at any time from Profile › Settings. Account deletion requests are processed within 30 days.'),
    ('Retention', 'Diary data is retained while your account is active. Anonymised, aggregated statistics may be kept for service improvement.'),
    ('Security', 'Passwords are stored as salted hashes (bcrypt/Argon2id). All traffic uses HTTPS and administrator actions are audit-logged.'),
    ('Estimates disclaimer', 'Emission values are estimates derived from published emission factors and are not exact scientific measurements.'),
    ('Malaysia PDPA', 'Data handling is designed to align with the Personal Data Protection Act 2010 (Malaysia).'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Privacy')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: 20),
        itemBuilder: (_, i) {
          final (title, body) = _sections[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${i + 1}. $title', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.primary)),
              const SizedBox(height: 6),
              Text(body, style: const TextStyle(height: 1.55)),
            ],
          );
        },
      ),
    );
  }
}
