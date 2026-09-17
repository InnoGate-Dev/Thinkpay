import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

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
        title: Text('Help & Support',
            style: TextStyle(color: tc.text100, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hero banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [tc.cardGradientStart, tc.cardGradientEnd],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tc.limeBorder),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.support_agent_rounded, color: tc.lime, size: 36),
              const SizedBox(height: 10),
              Text('How can we help?',
                  style: TextStyle(color: tc.text100, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Browse topics or reach out to our team.',
                  style: TextStyle(color: tc.text40, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 24),

          _SectionTitle('Get in Touch', tc),
          const SizedBox(height: 10),
          _SettingsCard(tc: tc, children: [
            _NavRow(icon: Icons.chat_bubble_outline_rounded, label: 'Live Chat', subtitle: 'Chat with support now', tc: tc, accent: tc.lime),
            Divider(height: 1, color: tc.border, indent: 52),
            _NavRow(icon: Icons.email_outlined, label: 'Email Support', subtitle: 'support@thinkpay.app', tc: tc),
            Divider(height: 1, color: tc.border, indent: 52),
            _NavRow(icon: Icons.phone_outlined, label: 'Call Us', subtitle: '+94 11 000 0000', tc: tc),
          ]),
          const SizedBox(height: 20),

          _SectionTitle('Resources', tc),
          const SizedBox(height: 10),
          _SettingsCard(tc: tc, children: [
            _NavRow(icon: Icons.help_outline_rounded, label: 'FAQ', subtitle: 'Frequently asked questions', tc: tc),
            Divider(height: 1, color: tc.border, indent: 52),
            _NavRow(icon: Icons.menu_book_rounded, label: 'User Guide', subtitle: 'Learn how to use ThinkPay', tc: tc),
            Divider(height: 1, color: tc.border, indent: 52),
            _NavRow(icon: Icons.bug_report_outlined, label: 'Report a Bug', subtitle: 'Tell us what went wrong', tc: tc),
          ]),
          const SizedBox(height: 20),

          _SectionTitle('App Info', tc),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
                color: tc.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: tc.border)),
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: tc.limeDim, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.info_outline_rounded, color: tc.lime, size: 22),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ThinkPay', style: TextStyle(color: tc.text100, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Version 1.0.0 • Build 100', style: TextStyle(color: tc.text40, fontSize: 12)),
              ]),
            ]),
          ),
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

class _NavRow extends StatelessWidget {
  const _NavRow({required this.icon, required this.label, required this.subtitle, required this.tc, this.accent});
  final IconData icon; final String label, subtitle; final ThemeColors tc; final Color? accent;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Icon(icon, color: accent ?? tc.text70, size: 20),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(color: accent ?? tc.text100, fontSize: 14)),
              Text(subtitle, style: TextStyle(color: tc.text40, fontSize: 11)),
            ])),
            Icon(Icons.chevron_right_rounded, color: tc.text20, size: 18),
          ])));
}
