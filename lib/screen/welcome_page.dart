import 'package:flutter/material.dart';
import 'package:warteg_app/data/welcome_screen_data.dart';
import 'package:warteg_app/screen/landing_page.dart';
import 'package:warteg_app/theme/color_theme.dart';

class WelcomePage extends StatefulWidget {
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _kontrolHalaman = PageController(initialPage: 0);
  int _halamanAktif = 0;

  @override
  Widget build(BuildContext context) {
    // --- RESPONSIVE HELPERS ---
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    // Breakpoints
    final bool isSmallPhone = screenHeight < 600;   // e.g. iPhone SE
    final bool isTablet = screenWidth >= 600;

    // Dynamic sizing
    final double horizontalMargin = isTablet ? screenWidth * 0.1 : 15;
    final double imageHeight = isSmallPhone
        ? screenHeight * 0.30
        : isTablet
            ? screenHeight * 0.45
            : screenHeight * 0.38;
    final double titleFontSize = isTablet ? 28 : (isSmallPhone ? 18 : 22);
    final double descFontSize = isTablet ? 16 : (isSmallPhone ? 12 : 14);
    final double buttonHeight = isTablet ? 60 : 50;
    final double buttonFontSize = isTablet ? 18 : 16;
    final double spacingMd = isSmallPhone ? 20 : 30;
    final double spacingSm = isSmallPhone ? 10 : 15;

    return Scaffold(
      backgroundColor: ColorTheme.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 8),
          child: Column(
            children: [
              // --- 1. SKIP BUTTON ---
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _kontrolHalaman.animateToPage(
                      daftarBanner.length - 1,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                      color: ColorTheme.textSecondary,
                    ),
                  ),
                ),
              ),

              // --- 2. PAGE VIEW ---
              Expanded(
                child: PageView.builder(
                  controller: _kontrolHalaman,
                  onPageChanged: (nilai) {
                    setState(() {
                      _halamanAktif = nilai;
                    });
                  },
                  itemCount: daftarBanner.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Image card — height driven by screen size
                          Container(
                            height: imageHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                daftarBanner[index].gambar,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),

                          SizedBox(height: spacingMd),

                          // Title
                          Text(
                            daftarBanner[index].judul,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: ColorTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: spacingSm),

                          // Description — constrained width on tablets
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 500 : double.infinity,
                            ),
                            child: Text(
                              daftarBanner[index].deskripsi,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: descFontSize,
                                fontFamily: 'Poppins',
                                color: ColorTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- 3. DOT INDICATORS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  daftarBanner.length,
                  (index) => _indikatorBanner(index: index),
                ),
              ),

              SizedBox(height: spacingMd),

              // --- 4. BOTTOM BUTTON ---
              SizedBox(
                width: isTablet ? 400 : double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTheme.buttonPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_halamanAktif == daftarBanner.length - 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LandingPage()),
                      );
                    } else {
                      _kontrolHalaman.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Text(
                    _halamanAktif == daftarBanner.length - 1
                        ? "Mulai Aplikasi"
                        : "Selanjutnya",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: isSmallPhone ? 6 : 10),
            ],
          ),
        ),
      ),
    );
  }

  // --- DOT INDICATOR WIDGET ---
  AnimatedContainer _indikatorBanner({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _halamanAktif == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _halamanAktif == index
            ? ColorTheme.buttonPrimary
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}