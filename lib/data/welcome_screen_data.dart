// Lokasi file: lib/data/banner_data.dart

// 1. Membuat Model Data (Cetakan)
class BannerItem {
  final String judul;
  final String deskripsi;
  final String gambar;

  BannerItem({
    required this.judul,
    required this.deskripsi,
    required this.gambar,
  });
}

// 2. Membuat List berisi data berdasarkan model di atas
final List<BannerItem> daftarBanner = [
  BannerItem(
    judul: "BERAGAM MACAM MENU MASAKAN NUSANTARA!",
    deskripsi: "Jangan khawatir memilih menu hari ini karena kami memiliki berbagai menu makanan Indonesia!",
    gambar: "assets/images/welcome_screen/image1.jpg"
  ),
  BannerItem(
    judul: "YOU CAN EAT GOOD ANYWHERE AND ANYTIME.",
    deskripsi: "Are you tired of getting stuck in traffic jams to buy food? Let us take you to your place!",
    gambar: "assets/images/welcome_screen/image2.png",
  ),
  BannerItem(
    judul: "Enjoy your foods, Fellas!",
    deskripsi: "",
    gambar: "assets/images/welcome_screen/image3.png",
  ),
];