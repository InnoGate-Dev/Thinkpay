import 'package:Thinkpay/core/repository/userRepo.dart';
import 'package:flutter/material.dart';
import 'package:Thinkpay/core/constant/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await UserRepository().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Login succeeded if we received a non-empty token.
      // Token is already persisted inside UserRepository.login via TokenStorage.
      debugPrint('LOGIN: token="${response.token}" user=${response.user?.name}');
      if (!mounted) return;
      if (response.token.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-in failed: empty token received.'),
            duration: Duration(seconds: 6),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('LOGIN ERROR: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-in failed: ${e.toString()}'),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Signs the user in with Google.
  ///
  /// Flow:
  ///   1. Trigger the Google account chooser via [GoogleSignIn.signIn].
  ///   2. Exchange the Google credentials with Firebase to obtain a Firebase
  ///      [User], whose [uid] is the stable `google_provider_id` we send to
  ///      the backend. This ensures the same backend user is matched even when
  ///      the account also has an email/password auth provider linked to it.
  ///   3. Call [UserRepository.googleSignIn] with the Firebase UID, email and
  ///      display name so the backend can create-or-link the account.
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
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in failed. Please try again.')),
        );
      }
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
                // Brand icon (unchanged)
                Container(
                  width: 56,
                  height: 56,
                  child: Center(
                    child: Text(
                      'D1',
                      style: AppTypography.headlineLg.copyWith(
                        color: tc.text100,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome back.',
                  style: AppTypography.headlineLg.copyWith(
                    color: tc.text100,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sign in with email or Google to continue your journey.',
                  style: AppTypography.bodyMd.copyWith(color: tc.text70),
                ),
                const SizedBox(height: 48),

                // --- Email & Password fields ---
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTypography.bodyMd.copyWith(color: tc.text100),
                  decoration: InputDecoration(
                    labelText: 'Email address',
                    labelStyle: AppTypography.bodySm.copyWith(color: tc.text70),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: tc.text70,
                      size: 22,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: tc.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: tc.intelligenceAccent,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.red.shade400),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.red.shade400,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: AppTypography.bodyMd.copyWith(color: tc.text100),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: AppTypography.bodySm.copyWith(color: tc.text70),
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: tc.text70,
                      size: 22,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: tc.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: tc.intelligenceAccent,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.red.shade400),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.red.shade400,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to forgot password screen
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot password?',
                      style: AppTypography.bodySm.copyWith(
                        color: tc.intelligenceAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign In button (email/password)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleEmailLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tc.intelligenceAccent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: tc.intelligenceAccent
                          .withOpacity(0.6),
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
                            'Sign In',
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // Divider with "or"
                Row(
                  children: [
                    Expanded(child: Divider(thickness: 1, color: tc.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or continue with',
                        style: AppTypography.bodySm.copyWith(color: tc.text70),
                      ),
                    ),
                    Expanded(child: Divider(thickness: 1, color: tc.border)),
                  ],
                ),
                const SizedBox(height: 32),

                // Google button (unchanged, but using the same style)
                _GoogleAuthButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  isPrimary: false,
                  // TODO: implement Google sign-in once google_sign_in is configured
                  onPressed: () async => await _handleGoogleLogin(),
                  tc: tc,
                ),
                const SizedBox(height: 48),

                // Sign up prompt
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/signup'),
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.bodySm.copyWith(color: tc.text70),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Join the 1%',
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
}

// ---- Google Auth Button (unchanged) ----
class _GoogleAuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;
  final ThemeColors tc;

  const _GoogleAuthButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? tc.intelligenceAccent : tc.surface,
          foregroundColor: isPrimary ? Colors.white : tc.text100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary ? BorderSide.none : BorderSide(color: tc.border),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: isPrimary ? Colors.white : tc.text100),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.bodyMd.copyWith(
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : tc.text100,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
