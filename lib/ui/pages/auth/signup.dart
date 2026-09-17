import 'package:Thinkpay/core/repository/userRepo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Thinkpay/core/errors/exceptions.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum _UserRole { member, leader }

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _socialMediaController = TextEditingController();

  DateTime? _birthday;
  _UserRole _selectedRole = _UserRole.member;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late AnimationController _leaderCardController;
  late Animation<double> _leaderCardAnimation;

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await UserRepository().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        birthday: _birthday!,
        isLeader: _selectedRole == _UserRole.leader,
        socialMediaChannelName:
            _selectedRole == _UserRole.leader &&
                    _socialMediaController.text.trim().isNotEmpty
                ? _socialMediaController.text.trim()
                : null,
      );
      debugPrint('SIGNUP: token="${response.token}" user=${response.user?.name}');
      if(!mounted) return;
      if(response.token.isNotEmpty){
         Navigator.pushReplacementNamed(context, '/onboarding');
        // if(_selectedRole == _UserRole.leader){
        //   Navigator.pushNamed(context, '/create-community');
        // }else{
        //   Navigator.pushReplacementNamed(context, '/onboarding');
        // }
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-up failed: empty token received.'),
            duration: Duration(seconds: 6),
          ),
        );
      }
    } on ApiException catch (e) {
      debugPrint('SIGNUP API ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      // Step 1 – Google account chooser.
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled the picker — nothing to do.
        return;
      }

      // Step 2 – Exchange for a Firebase credential and sign into Firebase.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final UserCredential firebaseCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? firebaseUser = firebaseCredential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase sign-in returned no user.');
      }
      final String googleProviderId = firebaseUser.uid;
      final String email = firebaseUser.email ?? googleUser.email;
      final String name =
          firebaseUser.displayName ?? googleUser.displayName ?? '';

      if (!mounted) return;
      final response = await UserRepository().googleSignIn(
        googleProviderId: googleProviderId,
        email: email,
        name: name,
      );

      if (!mounted) return;

      if (response.token.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in failed. Please try again.')),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
    

  @override
  void initState() {
    super.initState();
    _leaderCardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _leaderCardAnimation = CurvedAnimation(
      parent: _leaderCardController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _leaderCardController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _socialMediaController.dispose();
    super.dispose();
  }

  void _selectRole(_UserRole role) {
    setState(() => _selectedRole = role);
    if (role == _UserRole.leader) {
      _leaderCardController.forward();
    } else {
      _leaderCardController.reverse();
    }
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final DateTime initialDate =
        _birthday ?? DateTime(now.year - 18, now.month, now.day);
    final DateTime firstDate = DateTime(1900);
    final DateTime lastDate = DateTime(now.year - 13, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select your birthday',
      builder: (context, child) {
        final tc = ThemeColors.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: tc.intelligenceAccent,
                    onPrimary: Colors.white,
                    surface: tc.surface,
                    onSurface: tc.text100,
                  )
                : ColorScheme.light(
                    primary: tc.intelligenceAccent,
                    onPrimary: Colors.white,
                    surface: tc.surface,
                    onSurface: tc.text100,
                  ), dialogTheme: DialogThemeData(backgroundColor: tc.surface),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthday = picked;
        _birthdayController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your birthday.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await UserRepository().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        birthday: _birthday!,
        isLeader: _selectedRole == _UserRole.leader,
        socialMediaChannelName:
            _selectedRole == _UserRole.leader &&
                    _socialMediaController.text.trim().isNotEmpty
                ? _socialMediaController.text.trim()
                : null,
      );

      debugPrint('SIGNUP: token="${response.token}" user=${response.user?.name}');
      if (!mounted) return;
      if (response.token.isNotEmpty) {
        if (_selectedRole == _UserRole.leader) {
          Navigator.pushNamed(context, '/create-community');
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-up failed: empty token received.'),
            duration: Duration(seconds: 6),
          ),
        );
      }
    } on ApiException catch (e) {
      debugPrint('SIGNUP API ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          duration: const Duration(seconds: 6),
        ),
      );
    } catch (e, st) {
      debugPrint('SIGNUP ERROR: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-up failed: ${e.toString()}'),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: tc.text100,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: tc.intelligenceAccentDim,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: tc.intelligenceAccent,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Create account.',
                  style: AppTypography.headlineLg.copyWith(
                    color: tc.text100,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Join a focused community building better financial habits together.',
                  style: AppTypography.bodyMd.copyWith(color: tc.text70),
                ),
                const SizedBox(height: 32),

                // // ── Role Selector ──────────────────────────────────────────
                // Text(
                //   'I want to join as',
                //   style: AppTypography.bodySm.copyWith(
                //     color: tc.text70,
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
                // const SizedBox(height: 12),
                // Row(
                //   children: [
                //     Expanded(
                //       child: _RoleChip(
                //         label: 'Member',
                //         icon: Icons.person_rounded,
                //         isSelected: _selectedRole == _UserRole.member,
                //         onTap: () => _selectRole(_UserRole.member),
                //         tc: tc,
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     Expanded(
                //       child: _RoleChip(
                //         label: 'Community Leader',
                //         icon: Icons.group_rounded,
                //         isSelected: _selectedRole == _UserRole.leader,
                //         onTap: () => _selectRole(_UserRole.leader),
                //         tc: tc,
                //       ),
                //     ),
                //   ],
                // ),

                // ── Leader Info Card (animated) ────────────────────────────
                SizeTransition(
                  sizeFactor: _leaderCardAnimation,
                  axisAlignment: -1,
                  child: FadeTransition(
                    opacity: _leaderCardAnimation,
                    child: _LeaderInfoCard(tc: tc),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Name ──────────────────────────────────────────────────
                _buildField(
                  controller: _nameController,
                  label: 'Full name',
                  icon: Icons.person_outline_rounded,
                  tc: tc,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Email ─────────────────────────────────────────────────
                _buildField(
                  controller: _emailController,
                  label: 'Email address',
                  icon: Icons.email_outlined,
                  tc: tc,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Birthday ──────────────────────────────────────────────
                TextFormField(
                  controller: _birthdayController,
                  readOnly: true,
                  onTap: _pickBirthday,
                  style: AppTypography.bodyMd.copyWith(color: tc.text100),
                  decoration: _fieldDecoration(
                    label: 'Birthday (YYYY-MM-DD)',
                    icon: Icons.cake_outlined,
                    tc: tc,
                  ).copyWith(
                    hintText: 'Tap to select birthday',
                    hintStyle: AppTypography.bodySm.copyWith(color: tc.text40),
                    suffixIcon: _birthday != null
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: tc.intelligenceAccent,
                            size: 20,
                          )
                        : Icon(
                            Icons.calendar_today_outlined,
                            color: tc.text70,
                            size: 20,
                          ),
                  ),
                  validator: (_) {
                    if (_birthday == null) {
                      return 'Please select your birthday';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Password ──────────────────────────────────────────────
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppTypography.bodyMd.copyWith(color: tc.text100),
                  decoration: _fieldDecoration(
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    tc: tc,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: tc.text70,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter a password';
                    if (v.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Confirm Password ──────────────────────────────────────
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  style: AppTypography.bodyMd.copyWith(color: tc.text100),
                  decoration: _fieldDecoration(
                    label: 'Confirm password',
                    icon: Icons.lock_outline_rounded,
                    tc: tc,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: tc.text70,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Social Media (leader only, animated) ──────────────────
                SizeTransition(
                  sizeFactor: _leaderCardAnimation,
                  axisAlignment: -1,
                  child: FadeTransition(
                    opacity: _leaderCardAnimation,
                    child: Column(
                      children: [
                        _buildField(
                          controller: _socialMediaController,
                          label: 'Social media channel name (optional)',
                          icon: Icons.link_rounded,
                          tc: tc,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ── Sign Up Button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tc.intelligenceAccent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          tc.intelligenceAccent.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'By creating an account, you agree to our Terms and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySm.copyWith(
                      color: tc.text40,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.bodySm.copyWith(color: tc.text70),
                        children: [
                          const TextSpan(text: 'Already a member? '),
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                              color: tc.intelligenceAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a standard outlined [TextFormField] with consistent styling.
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeColors tc,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTypography.bodyMd.copyWith(color: tc.text100),
      decoration: _fieldDecoration(label: label, icon: icon, tc: tc),
      validator: validator,
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    required ThemeColors tc,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTypography.bodySm.copyWith(color: tc.text70),
      prefixIcon: Icon(icon, color: tc.text70, size: 22),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: tc.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: tc.intelligenceAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}

// ── Role Chip ───────────────────────────────────────────────────────────────
class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors tc;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? tc.intelligenceAccentDim : tc.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? tc.intelligenceAccent : tc.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? tc.intelligenceAccent : tc.text70,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTypography.bodySm.copyWith(
                  color: isSelected ? tc.intelligenceAccent : tc.text70,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Leader Info Card ────────────────────────────────────────────────────────
class _LeaderInfoCard extends StatelessWidget {
  final ThemeColors tc;
  const _LeaderInfoCard({required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tc.limeDim,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: tc.limeBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: tc.coreAction, size: 18),
              const SizedBox(width: 8),
              Text(
                'Community Leader Requirements',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: tc.coreAction,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _BulletPoint(
            text: 'You must create a community before completing sign-up.',
            tc: tc,
          ),
          _BulletPoint(
            text: 'Your community will be visible to all members immediately.',
            tc: tc,
          ),
          _BulletPoint(
            text:
                'You can post updates and manage your community from the dashboard.',
            tc: tc,
          ),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final ThemeColors tc;
  const _BulletPoint({required this.text, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: tc.coreAction,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySm.copyWith(
                color: tc.coreAction,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
