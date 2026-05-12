import 'package:flutter/material.dart';
import 'package:warteg_app/screen/home.dart';
import 'package:warteg_app/theme/color_theme.dart';
import 'package:warteg_app/widgets/custom_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SigninPage extends StatefulWidget {
  @override
  State<SigninPage> createState() => _SigninPageState();
  
}

class _SigninPageState extends State<SigninPage> {
  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    @override
    void dispose() {
      emailController.dispose();
      passwordController.dispose();
      super.dispose();
    }

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
    final double spacingSm = isSmallPhone ? 4.0 : 8.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 16,
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
                          "Sign In",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: ColorTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: spacingLg),
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
                      ],
                    ),
                  ),

                  // --- FORGOT PASSWORD ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 0),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: bodyFontSize),
                      ),
                    ),
                  ),

                  SizedBox(height: spacingMd),

                  // --- CONTINUE BUTTON ---
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: buttonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: ColorTheme.buttonPrimary,
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                        );
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

                  SizedBox(height: spacingSm),

                  // --- DON'T HAVE ACCOUNT ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                            fontSize: bodyFontSize, color: Colors.grey[700]),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          foregroundColor: Colors.redAccent,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Sign up',
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
                          child: Divider(
                              thickness: 0.8, color: Colors.grey[350])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'or',
                          style: TextStyle(
                              fontSize: bodyFontSize, color: Colors.grey[500]),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                              thickness: 0.8, color: Colors.grey[350])),
                    ],
                  ),

                  SizedBox(height: spacingMd),

                  // --- SOCIAL BUTTONS ---
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          icon: const FaIcon(FontAwesomeIcons.google,
                              size: 17, color: Color(0xFFEA4335)),
                          label: 'Google',
                          height: buttonHeight,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialButton(
                          icon: const FaIcon(FontAwesomeIcons.apple,
                              size: 20, color: Colors.black87),
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