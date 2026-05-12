import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warteg_app/model/product_model.dart';
import 'package:warteg_app/theme/color_theme.dart';

class MenuCard extends StatelessWidget {
  final ProductModel menu;

  const MenuCard({Key? key, required this.menu}) : super(key: key);

  // ==========================================
  // FUNGSI UNTUK MEMUNCULKAN BOTTOM SHEET
  // ==========================================
  void _tampilkanDetailMenu(BuildContext context) {
    // 1. Variabel ditaruh di LUAR showModalBottomSheet agar tidak reset saat keyboard muncul
    int jumlahPorsi = 1;
    TextEditingController catatanController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Wajib true agar bisa menyesuaikan tinggi keyboard
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              // 2. JURUS RAHASIA: Mendorong bottom sheet ke atas sejauh tinggi keyboard
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                padding: const EdgeInsets.all(20),
                // 3. Wajib dibungkus SingleChildScrollView agar bisa di-scroll saat keyboard nutupin layar
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Garis Handle ---
                      Center(
                        child: Container(
                          height: 5,
                          width: 50,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: ColorTheme.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // --- Gambar Besar ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          menu.image,
                          height:
                              180, // Sedikit dipendekkan agar ruang untuk keyboard lebih lega
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- Nama Menu & Harga Satuan ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              menu.menuName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ColorTheme.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(menu.price),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ColorTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Text(
                        menu.description,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: ColorTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- Pengatur Porsi ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Jumlah Porsi",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  color: jumlahPorsi > 1
                                      ? ColorTheme.textPrimary
                                      : Colors.grey,
                                  onPressed: () {
                                    if (jumlahPorsi > 1) {
                                      setModalState(() {
                                        jumlahPorsi--;
                                      });
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    "$jumlahPorsi",
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  color: ColorTheme.primaryColor,
                                  onPressed: () {
                                    setModalState(() {
                                      jumlahPorsi++;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ==========================================
                      // 4. KOLOM CATATAN PESANAN
                      // ==========================================
                      const Text(
                        "Catatan Pesanan",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller:
                            catatanController, // Menyimpan teks yang diketik
                        maxLines: 2, // Mengizinkan teks menjadi 2 baris
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              "Contoh: Nasinya setengah aja, kuah dipisah...",
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.all(15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                BorderSide.none, // Menghilangkan garis pinggir
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // --- Tombol Keranjang ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            // MENGAMBIL DATA CATATAN DENGAN 'catatanController.text'
                            print("--------------------------------");
                            print("Menu: ${menu.menuName}");
                            print("Jumlah: $jumlahPorsi");
                            print(
                              "Catatan: ${catatanController.text.isEmpty ? 'Tidak ada' : catatanController.text}",
                            );
                            print("Total: Rp ${menu.price * jumlahPorsi}");
                            print("--------------------------------");

                            Navigator.pop(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Tambah ke Keranjang",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                  locale: 'id_ID',
                                  symbol: 'Rp',
                                  decimalDigits: 0,
                                ).format(menu.price * jumlahPorsi),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Jarak aman untuk batas bawah layar
                      SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (KODE TAMPILAN KARTU UTAMA TETAP SAMA SEPERTI SEBELUMNYA)
    return GestureDetector(
      onTap: () {
        _tampilkanDetailMenu(context);
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: ColorTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
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
                style: TextStyle(
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
