import 'package:flutter/material.dart';
import 'package:Thinkpay/constant/app_colors.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometric   = false;
  bool _twoFactor   = false;
  bool _loginAlerts = true;

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
        title: Text('Privacy & Security',
            style: TextStyle(color: tc.text100, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // header banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [tc.cardGradientStart, tc.cardGradientEnd],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tc.limeBorder),
            ),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: tc.limeDim, borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.shield_rounded, color: tc.lime, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Account Security', style: TextStyle(color: tc.text100, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Keep your account safe.', style: TextStyle(color: tc.text40, fontSize: 12)),
              ])),
            ]),
          ),
          const SizedBox(height: 24),

          _SectionTitle('Authentication', tc),
          const SizedBox(height: 10),
          _SettingsCard(tc: tc, children: [
            _SwitchRow(icon: Icons.fingerprint_rounded, label: 'Biometric Login', subtitle: 'Fingerprint or Face ID', value: _biometric, tc: tc, onChanged: (v) => setState(() => _biometric = v)),
            Divider(height: 1, color: tc.border, indent: 52),
            _SwitchRow(icon: Icons.verified_user_rounded, label: 'Two-Factor Auth', subtitle: 'Extra layer of security', value: _twoFactor, tc: tc, onChanged: (v) => setState(() => _twoFactor = v)),
            Divider(height: 1, color: tc.border, indent: 52),
            _SwitchRow(icon: Icons.notifications_active_rounded, label: 'Login Alerts', subtitle: 'Notify on new sign-ins', value: _loginAlerts, tc: tc, onChanged: (v) => setState(() => _loginAlerts = v)),
          ]),
          const SizedBox(height: 20),

          _SectionTitle('Password', tc),
          const SizedBox(height: 10),
          _SettingsCard(tc: tc, children: [
            _NavRow(icon: Icons.lock_reset_rounded, label: 'Change Password', tc: tc, onTap: () {}),
            Divider(height: 1, color: tc.border, indent: 52),
            _NavRow(icon: Icons.history_rounded, label: 'Login History', tc: tc, onTap: () {}),
          ]),
          const SizedBox(height: 20),

          _SectionTitle('Privacy', tc),
          const SizedBox(height: 10),
          _SettingsCard(tc: tc, children: [
            _NavRow(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', tc: tc, onTap: () {}),
            Divider(height: 1, color: tc.border, indent: 52),
            _NavRow(icon: Icons.description_outlined, label: 'Terms of Service', tc: tc, onTap: () {}),
            Divider(height: 1, color: tc.border, indent: 52),
            _NavRow(icon: Icons.delete_forever_rounded, label: 'Delete Account', labelColor: tc.red, tc: tc, onTap: () {}),
          ]),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, this.tc);
  final String text; final ThemeColors tc;
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(color: tc.text100, fontSize: 14, fontWeight: FontWeight.w700));
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.tc, required this.children});
  final ThemeColors tc; final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: tc.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: tc.border)),
        child: Column(children: children));
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.icon, required this.label, required this.subtitle, required this.value, required this.tc, required this.onChanged});
  final IconData icon; final String label, subtitle; final bool value; final ThemeColors tc; final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(icon, color: tc.text70, size: 20),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: tc.text100, fontSize: 14)),
            Text(subtitle, style: TextStyle(color: tc.text40, fontSize: 11)),
          ])),
          Switch(value: value, onChanged: onChanged, activeColor: tc.lime, activeTrackColor: tc.lime.withValues(alpha: 0.3)),
        ]));
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.icon, required this.label, required this.tc, required this.onTap, this.labelColor});
  final IconData icon; final String label; final ThemeColors tc; final VoidCallback onTap; final Color? labelColor;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Icon(icon, color: labelColor ?? tc.text70, size: 20),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(color: labelColor ?? tc.text100, fontSize: 14))),
            Icon(Icons.chevron_right_rounded, color: tc.text20, size: 18),
          ])));
}
