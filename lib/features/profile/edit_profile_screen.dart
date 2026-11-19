import 'package:material_ui/material_ui.dart';

import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../auth/auth_screens.dart';

const residenceOptions = [
  'Apartment / Condominium',
  'Terrace house',
  'Semi-D / Bungalow',
  'Student hostel',
];

const vehicleOptions = [
  'Petrol car',
  'Hybrid car',
  'Electric vehicle',
  'Motorcycle',
  'Public transport only',
];

const dietOptions = [
  'Mixed diet',
  'Low-meat diet',
  'Pescatarian',
  'Vegetarian',
  'Vegan',
];

const workModeOptions = [
  'On-site full time',
  'Hybrid (part remote)',
  'Fully remote / home',
];

/// Edit profile information and optional context data (FR-03).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late String _country;
  late int _household;
  late String _residence;
  late String _vehicle;
  late String _diet;
  late String _workMode;

  @override
  void initState() {
    super.initState();
    final u = AppScope.read(context).currentUser!;
    _name = TextEditingController(text: u.name);
    _country = countries.contains(u.country) ? u.country : (countries.contains('Malaysia') ? 'Malaysia' : countries.first);
    _household = u.householdSize;

    // Normalize residence
    var r = u.residence;
    if (r == 'Apartment') r = 'Apartment / Condominium';
    _residence = residenceOptions.contains(r) ? r : residenceOptions.first;

    // Normalize vehicle
    var v = u.vehicle;
    _vehicle = vehicleOptions.contains(v) ? v : vehicleOptions.first;

    // Normalize diet
    var d = u.diet;
    _diet = dietOptions.contains(d) ? d : dietOptions.first;

    // Normalize work mode
    var w = u.workMode;
    if (w == 'Hybrid') w = 'Hybrid (part remote)';
    _workMode = workModeOptions.contains(w) ? w : workModeOptions.first;
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final s = AppScope.read(context);
    final u = s.currentUser!;
    u
      ..name = _name.text.trim()
      ..country = _country
      ..householdSize = _household
      ..residence = _residence
      ..vehicle = _vehicle
      ..diet = _diet
      ..workMode = _workMode;
    s.refresh();
    Navigator.pop(context);
    showSnack(context, 'Profile updated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
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
              decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline_rounded)),
              validator: (v) => Validators.required(v, 'Full name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _country,
              decoration: const InputDecoration(labelText: 'Country / region', prefixIcon: Icon(Icons.public_rounded)),
              borderRadius: BorderRadius.circular(16),
              items: [for (final c in countries) DropdownMenuItem(value: c, child: Text(c))],
              onChanged: (v) => setState(() => _country = v ?? _country),
            ),
            const SectionHeader('Lifestyle Details (for recommendations)'),
            DropdownButtonFormField<String>(
              initialValue: _residence,
              decoration: const InputDecoration(labelText: 'Type of residence', prefixIcon: Icon(Icons.home_outlined)),
              borderRadius: BorderRadius.circular(16),
              items: [
                for (final r in residenceOptions)
                  DropdownMenuItem(value: r, child: Text(r)),
              ],
              onChanged: (v) => setState(() => _residence = v ?? _residence),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _vehicle,
              decoration: const InputDecoration(labelText: 'Primary vehicle', prefixIcon: Icon(Icons.directions_car_outlined)),
              borderRadius: BorderRadius.circular(16),
              items: [
                for (final v in vehicleOptions)
                  DropdownMenuItem(value: v, child: Text(v)),
              ],
              onChanged: (v) => setState(() => _vehicle = v ?? _vehicle),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _diet,
              decoration: const InputDecoration(labelText: 'Dietary preference', prefixIcon: Icon(Icons.restaurant_outlined)),
              borderRadius: BorderRadius.circular(16),
              items: [
                for (final d in dietOptions)
                  DropdownMenuItem(value: d, child: Text(d)),
              ],
              onChanged: (v) => setState(() => _diet = v ?? _diet),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _workMode,
              decoration: const InputDecoration(labelText: 'Work / study mode', prefixIcon: Icon(Icons.work_outline_rounded)),
              borderRadius: BorderRadius.circular(16),
              items: [
                for (final w in workModeOptions)
                  DropdownMenuItem(value: w, child: Text(w)),
              ],
              onChanged: (v) => setState(() => _workMode = v ?? _workMode),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.people_outline_rounded),
                const SizedBox(width: 12),
                Expanded(child: Text('Household size: $_household people', style: Theme.of(context).textTheme.titleSmall)),
                IconButton.filledTonal(
                  tooltip: 'Decrease',
                  onPressed: _household > 1 ? () => setState(() => _household--) : null,
                  icon: const Icon(Icons.remove_rounded),
                ),
                IconButton.filledTonal(
                  tooltip: 'Increase',
                  onPressed: _household < 12 ? () => setState(() => _household++) : null,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(onPressed: _save, child: const Text('Save Profile')),
          ],
        ),
      ),
    ),
  ),
);
  }
}
