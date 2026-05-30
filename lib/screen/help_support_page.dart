import 'package:flutter/material.dart';
import 'package:warteg_app/theme/color_theme.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'Bagaimana cara memesan makanan?',
      answer:
          'Pilih menu yang kamu inginkan, tambahkan ke keranjang, lalu lanjutkan ke halaman checkout. Isi alamat pengiriman dan pilih metode pembayaran, kemudian tekan "Pesan Sekarang".',
    ),
    _FaqItem(
      question: 'Metode pembayaran apa saja yang tersedia?',
      answer:
          'Kami menerima pembayaran melalui COD (bayar di tempat), Virtual Account (BCA, BNI, Mandiri), serta dompet digital seperti GoPay, OVO, dan DANA.',
    ),
    _FaqItem(
      question: 'Berapa lama waktu pengiriman?',
      answer:
          'Estimasi pengiriman sekitar 30–60 menit tergantung jarak dan kondisi lalu lintas. Kamu bisa memantau status pesanan di halaman Pesanan.',
    ),
    _FaqItem(
      question: 'Apakah bisa membatalkan pesanan?',
      answer:
          'Pesanan COD bisa dibatalkan dalam 2 menit setelah pemesanan. Setelah itu, pesanan tidak dapat dibatalkan karena sudah diproses oleh restoran.',
    ),
    _FaqItem(
      question: 'Bagaimana cara menggunakan kode promo?',
      answer:
          'Di halaman Detail Pesanan, ketuk bagian "Gunakan Kode Promo" dan pilih promo yang tersedia. Diskon akan otomatis diterapkan ke total belanja.',
    ),
    _FaqItem(
      question: 'Apakah ada minimum pembelian?',
      answer:
          'Tidak ada minimum pembelian. Namun ongkos kirim mungkin berlaku tergantung jarak pengiriman.',
    ),
    _FaqItem(
      question: 'Bagaimana jika pesanan saya salah atau tidak sesuai?',
      answer:
          'Segera hubungi kami melalui fitur Bantuan di aplikasi atau langsung ke restoran. Kami akan membantu menyelesaikan masalah kamu secepat mungkin.',
    ),
  ];

  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 30),
              decoration: const BoxDecoration(
                color: ColorTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 17, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Bantuan & Dukungan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.support_agent_rounded,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ada yang bisa kami bantu?',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Temukan jawaban dari pertanyaan yang sering diajukan di bawah ini',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Pertanyaan yang Sering Diajukan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  ...List.generate(_faqs.length, (i) {
                    final faq = _faqs[i];
                    final isExpanded = _expandedIndex == i;

                    return GestureDetector(
                      onTap: () => setState(
                          () => _expandedIndex = isExpanded ? null : i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: isExpanded
                              ? Border.all(
                                  color: ColorTheme.primaryColor
                                      .withOpacity(0.3),
                                  width: 1.5)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: ColorTheme.primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isExpanded
                                        ? Icons.remove_rounded
                                        : Icons.add_rounded,
                                    color: ColorTheme.primaryColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    faq.question,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: isExpanded
                                          ? ColorTheme.primaryColor
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (isExpanded) ...[
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.only(left: 44),
                                child: Text(
                                  faq.answer,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 16, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tidak menemukan jawaban yang kamu cari? Hubungi langsung ke restoran Warteg Endah.',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}