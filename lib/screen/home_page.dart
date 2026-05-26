import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/data/homepage_data.dart';
import 'package:warteg_app/data/menu_data.dart';
import 'package:warteg_app/provider/address_provider.dart';
import 'package:warteg_app/provider/cart_provider.dart';
import 'package:warteg_app/screen/address_page.dart';
import 'package:warteg_app/screen/cart_page.dart';
import 'package:warteg_app/theme/color_theme.dart';
import 'package:warteg_app/widgets/menu_card.dart';

class HomePage extends ConsumerStatefulWidget {
  final VoidCallback? onSearchTapped;

  const HomePage({super.key, this.onSearchTapped});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _halamanAktif = 0;

  // Height of the floating bar so the scroll content doesn't hide behind it
  static const double _barHeight = 46;
  static const double _barTopPadding = 16;
  static const double _barBottomPadding = 12;
  static const double _floatingBarTotalHeight =
      _barTopPadding + _barHeight + _barBottomPadding;

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final addresses = ref.watch(addressProvider);

    final int totalCart = cartItems.fold(0, (sum, item) => sum + item.quantity);
    final selectedAddress = addresses.where((a) => a.isSelected).firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Scrollable content ────────────────────────────────────────
            SingleChildScrollView(
              // Push content below the floating bar
              padding: EdgeInsets.only(
                top: _floatingBarTotalHeight,
                bottom: 120,
              ),
              child: Column(
                children: [
                  // =====================================================
                  // LOCATION CARD
                  // =====================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddressPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              ColorTheme.primaryColor,
                              ColorTheme.secondaryColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: ColorTheme.primaryColor.withOpacity(0.20),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedAddress != null
                                        ? selectedAddress.label
                                        : "Deliver to",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedAddress != null
                                        ? selectedAddress.fullAddress
                                        : "Tap to set address",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // =====================================================
                  // BANNER
                  // =====================================================
                  CarouselSlider(
                    items: bannerImages.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              image: DecorationImage(
                                image: AssetImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 180,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      enlargeCenterPage: true,
                      viewportFraction: 0.88,
                      onPageChanged: (index, reason) {
                        setState(() => _halamanAktif = index);
                      },
                    ),
                  ),

                  // =====================================================
                  // INDICATOR
                  // =====================================================
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: bannerImages.asMap().entries.map((entry) {
                      final isActive = _halamanAktif == entry.key;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isActive ? 18 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: ColorTheme.primaryColor.withOpacity(
                            isActive ? 1 : 0.25,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // =====================================================
                  // RECOMMENDED
                  // =====================================================
                  buildSectionTitle(
                    title: "Recommended",
                    subtitle: "Pilihan terbaik untuk kamu",
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendedMenu.length,
                      itemBuilder: (context, index) {
                        return MenuCard(menu: recommendedMenu[index]);
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // =====================================================
                  // TOP OF WEEK
                  // =====================================================
                  buildSectionTitle(
                    title: "Top of Week",
                    subtitle: "Menu paling populer minggu ini",
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: topOfWeekMenu.length,
                      itemBuilder: (context, index) {
                        return MenuCard(menu: topOfWeekMenu[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Floating search bar + cart ─────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                // Subtle frosted-glass feel: semi-transparent background
                // that blurs content scrolling behind it
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7F4).withOpacity(0.92),
                ),
                padding: const EdgeInsets.fromLTRB(20, _barTopPadding, 20, _barBottomPadding),
                child: Row(
                  children: [
                    // SEARCH BAR
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onSearchTapped?.call(),
                        child: Container(
                          height: _barHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: ColorTheme.buttonPrimary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Cari makanan...",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.5,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // CART BUTTON
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartPage()),
                        );
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: _barHeight,
                            height: _barHeight,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              color: ColorTheme.buttonPrimary,
                              size: 22,
                            ),
                          ),
                          if (totalCart > 0)
                            Positioned(
                              top: -3,
                              right: -3,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  totalCart > 99 ? "99+" : totalCart.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}