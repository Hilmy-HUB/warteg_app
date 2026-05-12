import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:warteg_app/screen/signin_page.dart';
import 'package:warteg_app/screen/signup_page.dart';
import 'package:warteg_app/theme/color_theme.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double w = screen.width;
    final double h = screen.height;

    final bool isTablet = w >= 600;
    final bool isSmallPhone = h < 650;

    // Responsive sizing
    final double maxContentWidth = isTablet ? 420.0 : double.infinity;
    final double horizontalPadding = isTablet ? w * 0.12 : 28.0;
    final double titleFontSize = isTablet ? 80 : (isSmallPhone ? 52 : 68);
    final double subtitleFontSize = isTablet ? 52 : (isSmallPhone ? 32 : 44);
    final double taglineFontSize = isTablet ? 17 : (isSmallPhone ? 13 : 15);
    final double buttonHeight = isTablet ? 58 : (isSmallPhone ? 48 : 54);
    final double buttonFontSize = isTablet ? 17 : 15;
    final double spacingXl = isSmallPhone ? 24 : 36;
    final double spacingLg = isSmallPhone ? 16 : 24;
    final double spacingSm = isSmallPhone ? 10 : 14;

    return Scaffold(
      body: Stack(
        children: [
          // --- BACKGROUND IMAGE ---
          Positioned.fill(
            child: Image.asset(
              'assets/images/landing_page/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // --- GRADIENT OVERLAY (bottom-heavy for readability) ---
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x55FFFFFF), // subtle at top
                    Color(0xE8FFFFFF), // strong at bottom
                  ],
                  stops: [0.0, 0.55],
                ),
              ),
            ),
          ),

          // --- MAIN CONTENT ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: isSmallPhone ? 12 : 20),

                      // --- LOGO / TITLE BLOCK ---
                      Column(
                        children: [
                          Text(
                            'WARTEG',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w900,
                              color: ColorTheme.buttonPrimary,
                              height: 1.0,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            'ENDAH',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w700,
                              color: ColorTheme.buttonPrimary.withOpacity(0.75),
                              height: 1.0,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 60),

                      // --- TAGLINE ---
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: ColorTheme.buttonPrimary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Log in or Create an account',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: taglineFontSize,
                            fontWeight: FontWeight.w500,
                            color: ColorTheme.buttonPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: spacingXl),

                      // --- SIGN UP BUTTON ---
                      _PrimaryButton(
                        label: 'Daftar Sekarang',
                        height: buttonHeight,
                        fontSize: buttonFontSize,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignupPage()),
                          );
                        },
                      ),

                      SizedBox(height: spacingSm),

                      // --- SIGN IN BUTTON ---
                      _SecondaryButton(
                        label: 'Masuk ke Akun',
                        height: buttonHeight,
                        fontSize: buttonFontSize,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SigninPage()),
                          );
                        },
                      ),

                      SizedBox(height: spacingLg),

                      // --- DIVIDER ---
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.8,
                              color: Colors.grey[350],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.8,
                              color: Colors.grey[350],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: spacingLg),

                      // --- SOCIAL BUTTONS ROW ---
                      Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              icon: const FaIcon(FontAwesomeIcons.google, size: 18, color: Color(0xFFEA4335)),
                              label: 'Google',
                              height: buttonHeight,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SocialButton(
                              icon: const FaIcon(FontAwesomeIcons.apple, size: 22, color: Colors.black87),
                              label: 'Apple',
                              height: buttonHeight,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: spacingLg),

                      // --- TERMS TEXT ---
                      Text(
                        'Dengan mendaftar, kamu menyetujui Syarat & Ketentuan\nserta Kebijakan Privasi kami.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.grey[500],
                          height: 1.6,
                        ),
                      ),

                      SizedBox(height: isSmallPhone ? 8 : 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- REUSABLE BUTTON WIDGETS ---

class _PrimaryButton extends StatelessWidget {
  final String label;
  final double height;
  final double fontSize;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.height,
    required this.fontSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorTheme.buttonPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final double height;
  final double fontSize;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.label,
    required this.height,
    required this.fontSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: ColorTheme.buttonPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white.withOpacity(0.7),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: ColorTheme.buttonPrimary,
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
          backgroundColor: Colors.white.withOpacity(0.85),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}