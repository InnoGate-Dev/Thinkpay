import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final Set<String> _selectedCategories = {};
  bool _isLoading = false;

  static const List<String> _categories = [
    'Personal Finance',
    'Investing',
    'Business',
    'Real Estate',
    'Crypto',
    'Side Hustle',
    'Budgeting',
    'Career Growth',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _createCommunity() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select at least one category.',
            style: AppTypography.bodySm.copyWith(color: Colors.white),
          ),
          backgroundColor: ThemeColors.of(context).red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    // Simulate network call
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: tc.text100, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Create Your Community',
          style: GoogleFonts.manrope(
            color: tc.text100,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
            children: [
              // ── Hero section ────────────────────────────────────────────
              _CommunityBannerPicker(tc: tc),
              const SizedBox(height: 32),

              // ── Community Name ───────────────────────────────────────────
              _SectionLabel(text: 'Community Name *', tc: tc),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: AppTypography.bodyMd.copyWith(color: tc.text100),
                decoration: InputDecoration(
                  hintText: 'e.g. Investing 101',
                  hintStyle: AppTypography.bodyMd.copyWith(color: tc.text40),
                  prefixIcon: Icon(Icons.group_rounded, color: tc.text40, size: 20),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Community name is required'
                    : null,
              ),
              const SizedBox(height: 20),

              // ── Description ──────────────────────────────────────────────
              _SectionLabel(text: 'Description', tc: tc),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                style: AppTypography.bodyMd.copyWith(color: tc.text100),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'What is your community about? What value will members get?',
                  hintStyle: AppTypography.bodyMd.copyWith(color: tc.text40),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // ── Categories ───────────────────────────────────────────────
              _SectionLabel(text: 'Categories *', tc: tc),
              const SizedBox(height: 4),
              Text(
                'Select topics that best describe your community',
                style: AppTypography.bodySm.copyWith(color: tc.text40, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final selected = _selectedCategories.contains(cat);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) {
                        _selectedCategories.remove(cat);
                      } else {
                        _selectedCategories.add(cat);
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? tc.intelligenceAccentDim : tc.surface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: selected ? tc.intelligenceAccent : tc.border,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: AppTypography.bodySm.copyWith(
                          color: selected ? tc.intelligenceAccent : tc.text70,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // ── Community Rules (optional) ────────────────────────────────
              _SectionLabel(text: 'Community Rules (optional)', tc: tc),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: tc.surface2,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: tc.border),
                ),
                child: Column(
                  children: [
                    _RuleRow(number: '1', hint: 'e.g. Be respectful to all members', tc: tc),
                    Divider(color: tc.border, height: 20),
                    _RuleRow(number: '2', hint: 'e.g. No spam or self-promotion', tc: tc),
                    Divider(color: tc.border, height: 20),
                    _RuleRow(number: '3', hint: 'e.g. Stay on topic', tc: tc),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── Submit Button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createCommunity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tc.intelligenceAccent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: tc.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Create Community',
                              style: AppTypography.bodyMd.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Banner/Logo Picker Placeholder ──────────────────────────────────────────
class _CommunityBannerPicker extends StatelessWidget {
  final ThemeColors tc;
  const _CommunityBannerPicker({required this.tc});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner
        Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tc.intelligenceAccentDim,
                tc.limeDim,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: tc.border),
          ),
          child: Center(
            child: Icon(Icons.add_photo_alternate_outlined, color: tc.text40, size: 32),
          ),
        ),
        // Logo circle
        Positioned(
          bottom: -28,
          left: 20,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: tc.surface,
              shape: BoxShape.circle,
              border: Border.all(color: tc.border, width: 3),
            ),
            child: Icon(Icons.group_rounded, color: tc.text40, size: 30),
          ),
        ),
        // Edit badge on logo
        Positioned(
          bottom: -24,
          left: 62,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: tc.intelligenceAccent,
              shape: BoxShape.circle,
              border: Border.all(color: tc.background, width: 2),
            ),
            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 12),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final ThemeColors tc;
  const _SectionLabel({required this.text, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.bodySm.copyWith(
        color: tc.text70,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String number;
  final String hint;
  final ThemeColors tc;
  const _RuleRow({required this.number, required this.hint, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: tc.intelligenceAccentDim,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTypography.bodySm.copyWith(
                color: tc.intelligenceAccent,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            style: AppTypography.bodySm.copyWith(color: tc.text100),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodySm.copyWith(color: tc.text40, fontSize: 12),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              filled: false,
            ),
          ),
        ),
      ],
    );
  }
}
