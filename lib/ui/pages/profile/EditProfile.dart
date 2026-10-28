import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/errors/exceptions.dart';
import 'package:Thinkpay/core/repository/userRepo.dart';
import 'package:Thinkpay/providers/user_profile_store.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _store = UserProfileStore();
  final _nameCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = _store.name;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _store.birthday ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (date != null) setState(() => _store.birthday = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final user = await UserRepository().updateProfile(
        name: _nameCtrl.text.trim(),
        birthday: _store.birthday == null
            ? null
            : DateTime.utc(_store.birthday!.year, _store.birthday!.month, _store.birthday!.day),
      );
      _store.setUser(user);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Profile updated successfully'), backgroundColor: ThemeColors.of(context).lime),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: ThemeColors.of(context).red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.background,
      appBar: AppBar(
        backgroundColor: tc.surface,
        title: Text('Edit Profile', style: TextStyle(color: tc.text100, fontWeight: FontWeight.w700)),
        iconTheme: IconThemeData(color: tc.text100),
        actions: [TextButton(onPressed: _saving ? null : _save, child: Text('Save', style: TextStyle(color: tc.lime)))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          _label('Full name', tc),
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: _decoration('Enter your name', tc),
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.length < 2) return 'Name must be at least 2 characters';
              if (name.length > 255) return 'Name must be 255 characters or fewer';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _label('Birthday', tc),
          OutlinedButton.icon(
            onPressed: _selectBirthday,
            icon: Icon(Icons.calendar_month_outlined, color: tc.lime),
            label: Text(_store.birthday == null ? 'Add birthday (optional)' : _formatDate(_store.birthday!), style: TextStyle(color: tc.text100)),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52), alignment: Alignment.centerLeft, side: BorderSide(color: tc.border)),
          ),
          if (_store.birthday != null)
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => setState(() => _store.birthday = null), child: Text('Clear birthday', style: TextStyle(color: tc.text40)))),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: tc.lime, foregroundColor: tc.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: _saving ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text, ThemeColors tc) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: TextStyle(color: tc.text100, fontWeight: FontWeight.w600)),
  );

  InputDecoration _decoration(String hint, ThemeColors tc) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: tc.surface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: tc.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: tc.border)),
  );

  String _formatDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
