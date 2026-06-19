import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';
import 'package:Thinkpay/providers/user_profile_store.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _store = UserProfileStore();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: _store.name);
    _emailCtrl = TextEditingController(text: _store.email);
    _phoneCtrl = TextEditingController(text: _store.phone);
    _bioCtrl   = TextEditingController(text: _store.bio);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty || email.isEmpty) {
      final tc = ThemeColors.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Name and email are required.'),
        backgroundColor: tc.red,
      ));
      return;
    }

    _store.updateProfile(
      name:  name,
      email: email,
      phone: _phoneCtrl.text.trim(),
      bio:   _bioCtrl.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Profile updated successfully!'),
        backgroundColor: ThemeColors.of(context).lime,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.background,
      appBar: AppBar(
        backgroundColor: tc.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: tc.text100, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Profile',
            style: TextStyle(
                color: tc.text100, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Save',
                style: TextStyle(
                    color: tc.lime,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          Center(
            child: Stack(
              children: [
                Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [tc.cardGradientStart, tc.cardGradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: tc.limeBorder, width: 2),
                  ),
                  child: Icon(Icons.person_rounded, color: tc.lime, size: 48),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: tc.lime,
                      shape: BoxShape.circle,
                      border: Border.all(color: tc.background, width: 2),
                    ),
                    child: Icon(Icons.camera_alt_rounded,
                        color: tc.background, size: 15),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('Change photo',
                style: TextStyle(color: tc.lime, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 28),

          // ── Fields ───────────────────────────────────────────────────────
          _SectionLabel('Personal Info', tc),
          const SizedBox(height: 10),
          _EditField(
            controller: _nameCtrl,
            label: 'Full Name',
            hint: 'Enter your name',
            icon: Icons.person_outline_rounded,
            tc: tc,
          ),
          const SizedBox(height: 12),
          _EditField(
            controller: _emailCtrl,
            label: 'Email',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            tc: tc,
          ),
          const SizedBox(height: 12),
          _EditField(
            controller: _phoneCtrl,
            label: 'Phone',
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            tc: tc,
          ),
          const SizedBox(height: 20),

          _SectionLabel('About', tc),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: tc.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: tc.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: TextField(
              controller: _bioCtrl,
              maxLines: 4,
              style: TextStyle(color: tc.text100, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tell us a bit about yourself…',
                hintStyle: TextStyle(color: tc.text40, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Save button ──────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: tc.lime,
                foregroundColor: tc.background,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Save Changes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared field ──────────────────────────────────────────────────────────────
class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.tc,
    this.keyboardType = TextInputType.text,
  });
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final ThemeColors tc;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  color: tc.text40,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: tc.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tc.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              Icon(icon, color: tc.text40, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: TextStyle(color: tc.text100, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: tc.text40, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ]),
          ),
        ],
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.tc);
  final String text;
  final ThemeColors tc;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
            color: tc.text100,
            fontSize: 16,
            fontWeight: FontWeight.w700),
      );
}
