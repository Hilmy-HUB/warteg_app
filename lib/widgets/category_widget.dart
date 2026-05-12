import 'package:flutter/material.dart';
import 'package:warteg_app/model/category_model.dart';
import 'package:warteg_app/theme/color_theme.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected; // Menerima status dari parent (halaman utama)
  final VoidCallback onTap; // Menerima fungsi klik dari parent

  const CategoryWidget({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          // Gunakan isSelected yang dikirim dari parent
          backgroundColor: isSelected ? ColorTheme.primaryColor : Colors.white,
          foregroundColor: isSelected ? Colors.white : ColorTheme.primaryColor,
          side: BorderSide(
            color: isSelected ? ColorTheme.primaryColor : Colors.grey.shade400,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          minimumSize: Size.zero,
        ),
        // Panggil fungsi onTap yang dikirim dari parent
        onPressed: onTap,
        child: Text(
          category.categoryName,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}