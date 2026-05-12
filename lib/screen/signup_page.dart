import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/controller/auth_controller.dart';
import 'package:warteg_app/screen/signin_page.dart';
import 'package:warteg_app/theme/color_theme.dart';
import 'package:warteg_app/widgets/custom_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignupPage extends ConsumerStatefulWidget {
  SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

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
                        CustomTextField(
                          controller: nameController,
                          judul: "Username",
                          petunjuk: "Your name",
                        ),
                        CustomTextField(
                          controller: emailController,
                          judul: "Email",
                          petunjuk: "Your email",
                        ),
                        CustomTextField(
                          controller: passwordController,
                          judul: "Password",
                          petunjuk: "***",
                          isPassword: true,
                        ),
                        if (state.isLoading) const CircularProgressIndicator(),
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
                        await ref
                            .read(authControllerProvider.notifier)
                            .register(
                              emailController.text,
                              passwordController.text,
                            );
                        Navigator.pop(context);
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
                            MaterialPageRoute(
                              builder: (context) => SigninPage(),
                            ),
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
