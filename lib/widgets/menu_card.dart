import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warteg_app/model/product_model.dart';
import 'package:warteg_app/screen/detail_product_page.dart';
import 'package:warteg_app/theme/color_theme.dart';

class MenuCard extends StatelessWidget {
  final ProductModel menu;

  const MenuCard({Key? key, required this.menu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ==========================================
        // PINDAH KE DETAIL PRODUCT PAGE
        // KIRIM DATA PRODUK YANG DIKLIK
        // ==========================================
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailProductPage(
              product: menu,
            ),
          ),
        );
      },

      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: ColorTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  menu.image,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                menu.menuName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: ColorTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Text(
                NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp',
                  decimalDigits: 0,
                ).format(menu.price),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: ColorTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}