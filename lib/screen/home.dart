import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/provider/navbar_provider.dart';
import 'package:warteg_app/screen/home_page.dart';
import 'package:warteg_app/screen/menu_page.dart';
import 'package:warteg_app/screen/order_page.dart';
import 'package:warteg_app/screen/pick_up_page.dart';
import 'package:warteg_app/screen/profil_page.dart';
import 'package:warteg_app/theme/color_theme.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabAktif = ref.watch(navbarIndexProvider);

    final daftarHalaman = [
      HomePage(
        onSearchTapped: () {
          ref.read(navbarIndexProvider.notifier).state = 1;
        },
      ),
      const MenuPage(),
      const OrderPage(),
      const PickupPage(),  // ← tab baru
      const ProfilPage(),
    ];

    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,
      body: Stack(
        children: [
          daftarHalaman[tabAktif],

          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorTheme.secondaryColor.withOpacity(0.90),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ColorTheme.secondaryColor.withOpacity(0.30),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.transparent,
                    ),
                    child: BottomNavigationBar(
                      currentIndex: tabAktif,
                      onTap: (index) {
                        ref.read(navbarIndexProvider.notifier).state = index;
                      },
                      selectedItemColor: Colors.white,
                      unselectedItemColor: Colors.white.withOpacity(0.55),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      type: BottomNavigationBarType.fixed,
                      selectedLabelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                      ),
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home_outlined),
                          activeIcon: Icon(Icons.home),
                          label: 'Beranda',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.menu_book_outlined),
                          activeIcon: Icon(Icons.menu_book),
                          label: 'Menu',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.directions_bike_outlined),
                          activeIcon: Icon(Icons.directions_bike),
                          label: 'Pengiriman',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.storefront_outlined),
                          activeIcon: Icon(Icons.storefront_rounded),
                          label: 'Pickup',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person_outline),
                          activeIcon: Icon(Icons.person),
                          label: 'Profil',
                        ),
                      ],
                    ),
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