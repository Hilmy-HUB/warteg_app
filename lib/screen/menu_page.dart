import 'package:flutter/material.dart';
import 'package:warteg_app/data/category_data.dart';
import 'package:warteg_app/data/menu_data.dart';
import 'package:warteg_app/model/product_model.dart';
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
  String _searchQuery = '';                          // [BARU] state pencarian
  final TextEditingController _searchController = TextEditingController(); // [BARU]

  @override
  void dispose() {
    _searchController.dispose();                     // [BARU] bersihkan controller
    super.dispose();
  }

  List<ProductModel> get filteredMenu {
    final selectedId = category[_kategoriAktifIndex].id;

    // Filter by kategori
    List<ProductModel> result = selectedId == "all"
        ? allMenu
        : allMenu.where((menu) => menu.category == selectedId).toList();

    // [BARU] Filter by search query (nama menu, case-insensitive)
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((menu) =>
              menu.menuName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return result;
  }

  // [BARU] Reset pencarian dan kategori
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuList = filteredMenu;

    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= SEARCH BAR =================
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
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
                  controller: _searchController,         // [BARU]
                  autofocus: false,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  onChanged: (value) {                   // [BARU] update state saat mengetik
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Mau cari makan apa hari ini?",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: ColorTheme.buttonPrimary,
                    ),
                    // [BARU] Tampilkan tombol X hanya saat ada teks
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: _clearSearch,
                          )
                        : IconButton(
                            icon: const Icon(Icons.tune, color: Colors.grey),
                            onPressed: () {},
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ================= CATEGORY =================
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

              // ================= TITLE =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(                            // [BARU] tampilkan info hasil search
                  children: [
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Hasil untuk "$_searchQuery"'
                          : "Semua Menu",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // [BARU] badge jumlah hasil
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: ColorTheme.buttonPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${menuList.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: ColorTheme.buttonPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ================= GRID / EMPTY STATE =================
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 0, bottom: 30),
                child: menuList.isEmpty
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off,
                                  size: 80, color: Colors.grey), // [BARU] icon lebih relevan
                              const SizedBox(height: 10),
                              Text(
                                _searchQuery.isNotEmpty      // [BARU] pesan dinamis
                                    ? 'Menu "$_searchQuery" tidak ditemukan'
                                    : "Menu belum tersedia",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _searchQuery.isNotEmpty      // [BARU] saran dinamis
                                    ? "Coba kata kunci lain"
                                    : "Coba pilih kategori lain",
                                style:
                                    const TextStyle(color: Colors.grey),
                              ),
                              // [BARU] tombol hapus pencarian jika ada query
                              if (_searchQuery.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: _clearSearch,
                                  icon: const Icon(Icons.refresh,
                                      color: ColorTheme.buttonPrimary),
                                  label: const Text(
                                    "Reset Pencarian",
                                    style: TextStyle(
                                        color: ColorTheme.buttonPrimary),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 70),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: menuList.length,
                        itemBuilder: (context, index) {
                          return MenuCard(menu: menuList[index]);
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