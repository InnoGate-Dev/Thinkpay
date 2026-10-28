import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:Thinkpay/core/errors/exceptions.dart';
import 'package:Thinkpay/core/repository/userRepo.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await UserRepository().changePassword(currentPassword: _current.text, newPassword: _next.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully')));
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
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: ThemeColors.of(context).red));
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.background,
      appBar: AppBar(title: Text('Change Password', style: TextStyle(color: tc.text100)), backgroundColor: tc.surface, iconTheme: IconThemeData(color: tc.text100)),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          _field('Current password', _current, tc, validator: (v) => v == null || v.isEmpty ? 'Enter your current password' : null),
          const SizedBox(height: 16),
          _field('New password', _next, tc, validator: (v) => v == null || v.length < 8 ? 'Use at least 8 characters' : null),
          const SizedBox(height: 16),
          _field('Confirm new password', _confirm, tc, validator: (v) => v != _next.text ? 'Passwords do not match' : null),
          const SizedBox(height: 28),
          SizedBox(height: 52, child: ElevatedButton(
            onPressed: _saving ? null : _submit,
            style: ElevatedButton.styleFrom(backgroundColor: tc.lime, foregroundColor: tc.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: _saving ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Update Password', style: TextStyle(fontWeight: FontWeight.w700)),
          )),
        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, ThemeColors tc, {required String? Function(String?) validator}) => TextFormField(
    controller: controller,
    obscureText: true,
    validator: validator,
    decoration: InputDecoration(labelText: label, filled: true, fillColor: tc.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
  );
}
