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

  List<ProductModel> get filteredMenu {
    final selectedId = category[_kategoriAktifIndex].id;

    if (selectedId == "all") {
      return allMenu;
    }

    return allMenu.where((menu) => menu.category == selectedId).toList();
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
                  autofocus: false,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Mau cari makan apa hari ini?",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: ColorTheme.buttonPrimary,
                    ),
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Semua Menu",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ================= GRID / EMPTY STATE =================
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 0, bottom: 30),
                child: menuList.isEmpty
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.no_food, size: 80, color: Colors.grey),
                              SizedBox(height: 10),
                              Text(
                                "Menu belum tersedia",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Coba pilih kategori lain",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom : 70),
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
