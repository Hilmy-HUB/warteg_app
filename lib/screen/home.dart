import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:warteg_app/screen/home_page.dart';
import 'package:warteg_app/screen/menu_page.dart';
import 'package:warteg_app/screen/order_page.dart';
import 'package:warteg_app/screen/profil_page.dart';
import 'package:warteg_app/theme/color_theme.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _tabAktif = 0;

  void _pindahTab(int index) {
    setState(() {
      _tabAktif = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _daftarHalaman = [
      HomePage(onSearchTapped: () => _pindahTab(1)),
      MenuPage(),
      OrderPage(),
      ProfilPage(),
    ];

    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,
      body: Stack(
        children: [
          // --- PAGE CONTENT (fills entire screen including behind navbar) ---
          _daftarHalaman[_tabAktif],

          // --- FLOATING NAVBAR OVERLAID AT BOTTOM ---
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
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _tabAktif,
                    onTap: _pindahTab,
                    selectedItemColor: ColorTheme.buttonPrimary,
                    unselectedItemColor: Colors.grey.withOpacity(0.6),
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    selectedLabelStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                    ),
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.menu_book_outlined),
                        activeIcon: Icon(Icons.menu_book),
                        label: "Menu",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.receipt_long_outlined),
                        activeIcon: Icon(Icons.receipt_long),
                        label: "Order",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        activeIcon: Icon(Icons.person),
                        label: "Profil",
                      ),
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