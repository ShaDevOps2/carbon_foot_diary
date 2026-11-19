import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../onboarding/onboarding_screens.dart';
import '../profile/legal_screen.dart';

/// Shared layout: gradient header + rounded sheet with the form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppColors.forestDeep,
      body: Stack(
        children: [
          // Realistic high-res leaf/nature background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 340,
            child: Image.asset(
              'assets/images/leaf_hero_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Deep organic gradient overlay ensuring high contrast & readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 340,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F3D2C).withValues(alpha: 0.82),
                    const Color(0xFF1E6B4E).withValues(alpha: 0.78),
                    const Color(0xFF0F3D2C).withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 24, 0),
                  child: Row(
                    children: [
                      if (Navigator.canPop(context))
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        ),
                      const Spacer(),
                      const BrandMark(size: 40),
                    ],
                  ),
                ),
                  Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                          const SizedBox(height: 6),
                          Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _remember = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final err = AppScope.read(context).login(_email.text, _password.text, remember: _remember);
    setState(() {
      _loading = false;
      _error = err;
    });
    if (err == null) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void _fillDemo(bool admin) {
    _email.text = admin ? 'admin@cfootnote.app' : 'user@cfootnote.app';
    _password.text = admin ? 'Admin@1234' : 'Demo@1234';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AuthScaffold(
      title: 'Welcome back 👋',
      subtitle: 'Log in to continue your carbon diary.',
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              _ErrorBanner(_error!),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.alternate_email_rounded)),
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) => Validators.required(v, 'Password'),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(value: _remember, onChanged: (v) => setState(() => _remember = v ?? false)),
                const Text('Remember me'),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : const Text('Log in'),
            ),
            const SizedBox(height: 28),
            Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('Demo accounts', style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
              const Expanded(child: Divider()),
            ]),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _DemoChip(icon: Icons.person_rounded, label: 'User', onTap: () => _fillDemo(false))),
                const SizedBox(width: 12),
                Expanded(child: _DemoChip(icon: Icons.admin_panel_settings_rounded, label: 'Admin', onTap: () => _fillDemo(true))),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('New to CFootNote?'),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Create account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoChip extends StatelessWidget {
  const _DemoChip({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      radius: 16,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.coral.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.coral),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.coral, fontWeight: FontWeight.w600))),
        ]),
      ),
    );
  }
}

const countries = ['Malaysia', 'Singapore', 'Indonesia', 'Thailand', 'United Kingdom', 'United States', 'Australia', 'Other'];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _country = 'Malaysia';
  bool _metric = true;
  bool _terms = false;
  bool _obscure = true;
  String? _error;

  void _submit() {
    setState(() => _error = null);
    if (!_form.currentState!.validate()) return;
    if (!_terms) {
      setState(() => _error = 'Please accept the Terms and Privacy Policy.');
      return;
    }
    final err = AppScope.read(context).register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      country: _country,
      metric: _metric,
    );
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final strength = Validators.strength(_password.text);
    final strengthColors = [AppColors.coral, AppColors.coral, AppColors.amber, AppColors.sky, AppColors.success];
    final strengthLabels = ['Too weak', 'Weak', 'Fair', 'Good', 'Strong'];
    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Start your low-carbon journey today.',
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[_ErrorBanner(_error!), const SizedBox(height: 16)],
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline_rounded)),
              validator: (v) => Validators.required(v, 'Full name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.alternate_email_rounded)),
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: Validators.password,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < 4; i++)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: i < strength ? strengthColors[strength] : Theme.of(context).colorScheme.surfaceContainerHigh,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                Text(strengthLabels[strength], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: strengthColors[strength])),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm password', prefixIcon: Icon(Icons.lock_reset_rounded)),
              validator: (v) => v != _password.text ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _country,
              decoration: const InputDecoration(labelText: 'Country / region', prefixIcon: Icon(Icons.public_rounded)),
              borderRadius: BorderRadius.circular(16),
              items: [for (final c in countries) DropdownMenuItem(value: c, child: Text(c))],
              onChanged: (v) => setState(() => _country = v ?? _country),
            ),
            const SizedBox(height: 20),
            Text('Preferred units', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Metric (km, kg)'), icon: Icon(Icons.straighten_rounded)),
                ButtonSegment(value: false, label: Text('Imperial (mi, lb)')),
              ],
              selected: {_metric},
              onSelectionChanged: (s) => setState(() => _metric = s.first),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _terms,
              onChanged: (v) => setState(() => _terms = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text.rich(TextSpan(children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(text: 'Terms & Privacy Policy', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
              ])),
              secondary: IconButton(
                tooltip: 'Read policy',
                icon: const Icon(Icons.open_in_new_rounded),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen())),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _submit, child: const Text('Create account')),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already registered?'),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Log in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset password',
      subtitle: 'We\'ll email you a secure reset link.',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _sent
            ? Column(
                key: const ValueKey('sent'),
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(gradient: AppColors.mintGradient, shape: BoxShape.circle),
                    child: const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text('Check your inbox', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('If an account exists for ${_email.text}, a reset link has been sent. It expires in 30 minutes.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Back to login')),
                ],
              )
            : Form(
                key: _form,
                child: Column(
                  key: const ValueKey('form'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.alternate_email_rounded)),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        if (_form.currentState!.validate()) setState(() => _sent = true);
                      },
                      child: const Text('Send reset link'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
