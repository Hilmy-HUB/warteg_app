import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna latar belakang krem (cream) senada dengan gambar
      backgroundColor: Colors.amber[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ==========================================
            // 1. KARTU PROFIL (ORANYE)
            // ==========================================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFCA847), // Warna oranye kartu
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  // Foto Profil
                  const CircleAvatar(
                    radius: 30,
                    // Menggunakan gambar placeholder dari internet (bisa diganti asset lokal)
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=150&q=80'
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // Nama dan Tombol Edit
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Nanda septiani",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Edit profile",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.red[700], // Warna merah bata
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==========================================
            // 2. DAFTAR MENU PENGATURAN
            // ==========================================
            _buildMenuItem(
              icon: Icons.person_outline,
              title: "My Account",
              subtitle: "Make changes to your account",
            ),
            _buildMenuItem(
              icon: Icons.credit_card,
              title: "Payments",
              subtitle: "Manage your billings and payments",
            ),
            _buildMenuItem(
              icon: Icons.percent,
              title: "Promo",
              subtitle: "Apply coupon codes and earn discount",
            ),
            _buildMenuItem(
              icon: Icons.lock_outline,
              title: "Subcriptions",
              subtitle: "Manage your meal plans",
            ),
            _buildMenuItem(
              icon: Icons.person_off_outlined,
              title: "Log Out",
              subtitle: "Further secure your account for safety",
            ),
            
            // Dua menu terakhir tidak memiliki subtitle
            _buildMenuItem(
              icon: Icons.accessibility_new,
              title: "Accessibility",
            ),
            _buildMenuItem(
              icon: Icons.menu,
              title: "Help and Support",
            ),
            
            const SizedBox(height: 40), // Jarak aman ke bottom nav
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET KUSTOM UNTUK BARIS MENU (REUSABLE)
  // ==========================================
  // Dibuat sebagai fungsi agar kodenya tidak panjang dan berulang-ulang
  Widget _buildMenuItem({
    required IconData icon, 
    required String title, 
    String? subtitle // Subtitle opsional (bisa kosong)
  }) {
    return InkWell( // Agar ada efek klik
      onTap: () {
        print("Menu $title ditekan");
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Ikon Lingkaran Oranye
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFFCA847), // Warna oranye
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.black87, size: 20),
            ),
            const SizedBox(width: 15),

            // Teks Judul dan Subjudul
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  // Hanya tampilkan subtitle jika datanya tidak kosong
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ]
                ],
              ),
            ),

            // Ikon Panah ke Kanan (Chevron)
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[800]),
          ],
        ),
      ),
    );
  }
}