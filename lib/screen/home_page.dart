import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:warteg_app/data/homepage_data.dart';
import 'package:warteg_app/data/menu_data.dart';
import 'package:warteg_app/theme/color_theme.dart';
import 'package:warteg_app/widgets/menu_card.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onSearchTapped;

  const HomePage({Key? key, this.onSearchTapped}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _halamanAktif = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // ==========================================
                // 1. SEARCH BAR & LOKASI PENGGUNA
                // ==========================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: TextField(
                            readOnly: true,
                            onTap: () {
                              if (widget.onSearchTapped != null) {
                                widget.onSearchTapped!();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Cari makan apa?",
                              hintStyle: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: Colors.grey[400],
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: ColorTheme.buttonPrimary,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Lokasi Anda",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: ColorTheme.primaryColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "Bekasi, Jawa Barat",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ==========================================
                // 2. CAROUSEL SLIDER
                // ==========================================
                CarouselSlider(
                  items: bannerImages.map((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () {
                            print('Klik $imageUrl');
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 170,
                    autoPlay: true,
                    enableInfiniteScroll: true,
                    autoPlayInterval: const Duration(seconds: 10),
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _halamanAktif = index;
                      });
                    },
                  ),
                ),

                // ==========================================
                // INDICATOR
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: bannerImages.asMap().entries.map((entry) {
                    final isActive = _halamanAktif == entry.key;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 16 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: ColorTheme.primaryColor.withOpacity(
                          isActive ? 0.9 : 0.3,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // ==========================================
                // 3. RECOMMENDED
                // ==========================================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Recommended',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                  ),
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendedMenu.length,
                      itemBuilder: (context, index) {
                        final dataMenuSatuIni = recommendedMenu[index];

                        return MenuCard(
                          menu: dataMenuSatuIni,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==========================================
                // 4. TOP OF WEEK
                // ==========================================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Top of Week',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                  ),
                  child: SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: topOfWeekMenu.length,
                      itemBuilder: (context, index) {
                        final dataMenuSatuIni = topOfWeekMenu[index];

                        return MenuCard(
                          menu: dataMenuSatuIni,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}