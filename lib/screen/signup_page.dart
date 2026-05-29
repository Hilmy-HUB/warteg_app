import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/controller/auth_controller.dart';
import 'package:warteg_app/screen/signin_page.dart';
import 'package:warteg_app/theme/color_theme.dart';
import 'package:warteg_app/widgets/custom_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    final Size screen = MediaQuery.of(context).size;
    final double w = screen.width;
    final double h = screen.height;

    final bool isTablet = w >= 600;
    final bool isSmallPhone = h < 650;

    final double horizontalPadding = isTablet ? w * 0.12 : 20.0;
    final double cardPadding = isTablet ? 32.0 : (isSmallPhone ? 18.0 : 24.0);
    final double titleFontSize = isTablet ? 22.0 : (isSmallPhone ? 16.0 : 18.0);
    final double bodyFontSize = isTablet ? 15.0 : 13.0;
    final double buttonHeight = isTablet ? 56.0 : (isSmallPhone ? 46.0 : 52.0);
    final double buttonFontSize = isTablet ? 17.0 : 15.0;
    final double spacingLg = isSmallPhone ? 16.0 : 24.0;
    final double spacingMd = isSmallPhone ? 10.0 : 16.0;
    final double spacingSm = isSmallPhone ? 6.0 : 10.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 480.0 : double.infinity,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // --- FORM CARD ---
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: ColorTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Create An Account",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: ColorTheme.textSecondary,
                          ),
                        ),

                        SizedBox(height: spacingLg),

                        // USERNAME
                        CustomTextField(
                          controller: nameController,
                          judul: "Username",
                          petunjuk: "Your name",
                        ),

                        // EMAIL
                        CustomTextField(
                          controller: emailController,
                          judul: "Email",
                          petunjuk: "Your email",
                        ),

                        // PASSWORD
                        _buildPasswordField(
                          label: "Password",
                          controller: passwordController,
                          obscure: _obscurePassword,
                          onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),

                        // KONFIRMASI PASSWORD
                        _buildPasswordField(
                          label: "Confirm Password",
                          controller: confirmPasswordController,
                          obscure: _obscureConfirm,
                          onToggle: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),

                        if (state.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacingMd),

                  // --- TERMS ---
                  Text(
                    'If you sign up, you agree to the',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: bodyFontSize,
                      color: Colors.grey[700],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 0,
                          ),
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () {},
                        child: Text(
                          'Terms & Condition',
                          style: TextStyle(fontSize: bodyFontSize),
                        ),
                      ),
                      Text('and', style: TextStyle(fontSize: bodyFontSize)),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 0,
                          ),
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () {},
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(fontSize: bodyFontSize),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: spacingSm),

                  // --- CONTINUE BUTTON ---
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: buttonHeight * 0.9,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: ColorTheme.buttonPrimary,
                        elevation: 0,
                      ),
                      onPressed: () async {
                        // VALIDASI KOSONG
                        if (nameController.text.trim().isEmpty ||
                            emailController.text.trim().isEmpty ||
                            passwordController.text.trim().isEmpty ||
                            confirmPasswordController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Semua field wajib diisi"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // VALIDASI EMAIL
                        if (!emailController.text.contains("@")) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Email tidak valid"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // VALIDASI PASSWORD LENGTH
                        if (passwordController.text.length < 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password minimal 8 karakter"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // VALIDASI KONFIRMASI PASSWORD
                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password tidak cocok"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // REGISTER
                        final result = await ref
                            .read(authControllerProvider.notifier)
                            .register(
                              nameController.text.trim(),
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );

                        if (!mounted) return;

                        // ERROR
                        if (result != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }

                        // SUCCESS
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Register berhasil"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => SigninPage()),
                          );
                        }
                      },
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // --- SIGN IN LINK ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          fontSize: bodyFontSize,
                          color: Colors.grey[700],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 0,
                          ),
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SigninPage()),
                          );
                        },
                        child: Text(
                          'Sign in',
                          style: TextStyle(fontSize: bodyFontSize),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: spacingMd),

                  // --- DIVIDER ---
                  Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.8, color: Colors.grey[350]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'or',
                          style: TextStyle(
                            fontSize: bodyFontSize,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 0.8, color: Colors.grey[350]),
                      ),
                    ],
                  ),

                  SizedBox(height: spacingMd),

                  // --- SOCIAL BUTTONS ---
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.google,
                            size: 17,
                            color: Color(0xFFEA4335),
                          ),
                          label: 'Google',
                          height: buttonHeight,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.apple,
                            size: 20,
                            color: Colors.black87,
                          ),
                          label: 'Apple',
                          height: buttonHeight,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallPhone ? 8 : 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            decoration: InputDecoration(
              hintText: "***",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final double height;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}