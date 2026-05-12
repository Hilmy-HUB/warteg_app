import 'package:flutter/material.dart';
import 'package:warteg_app/data/category_data.dart';
import 'package:warteg_app/data/menu_data.dart';
import 'package:warteg_app/theme/color_theme.dart'; 
import 'package:warteg_app/widgets/category_widget.dart';
import 'package:warteg_app/widgets/menu_card.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _kategoriAktifIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,
      // WAJIB pakai SafeArea agar Search Bar tidak menabrak jam/sinyal di ujung atas HP
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SEARCH BAR ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                child: TextField(
                  autofocus: true,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Mau cari makan apa hari ini?",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: ColorTheme.buttonPrimary),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.tune, color: Colors.grey),
                      onPressed: () {},
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),

              // --- KATEGORI (HANYA BISA PILIH SATU) ---
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: category.length, 
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    final dataCategory = category[index];

                    return CategoryWidget(
                      category: dataCategory,
                      isSelected: _kategoriAktifIndex == index,
                      onTap: () {
                        setState(() {
                          _kategoriAktifIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 25),

              // --- JUDUL DAFTAR MENU ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Semua Menu",
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'
                  ),
                ),
              ),
              
              const SizedBox(height: 15), 

              // --- GRID DAFTAR MENU ---
              Padding(
                // PERBAIKAN 1: EdgeInsetsGeometry diganti EdgeInsets
                padding: const EdgeInsets.only(left: 20, right: 0, bottom: 30), 
                
                // PERBAIKAN 2: SizedBox height dihapus, langsung panggil GridView
                child: GridView.builder(
                  // PERBAIKAN 3: Dua baris sakti agar bisa di-scroll dengan mulus di dalam SingleChildScrollView
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(), 
                  
                  // PERBAIKAN 4: Mengatur jarak antar kartu dan bentuk kartunya
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 kolom
                    crossAxisSpacing: 0, // Jarak kiri-kanan antar kartu
                    mainAxisSpacing: 15, // Jarak atas-bawah antar kartu
                    childAspectRatio: 0.85, // Mengatur agar bentuk kartu memanjang (tidak kotak)
                  ),
                  itemCount: allMenu.length,
                  itemBuilder: (context, index) {
                    final dataMenuSatuIni = allMenu[index];
                    return MenuCard(menu: dataMenuSatuIni);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}