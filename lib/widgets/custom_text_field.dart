import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String judul;
  final String petunjuk;
  final bool isPassword;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.judul,
    required this.petunjuk,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          Text(
            judul,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 4),

          // Input
          TextField(
            controller: controller, // 🔥 ini yang penting
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: petunjuk,
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey[500],
                fontSize: 14,
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}