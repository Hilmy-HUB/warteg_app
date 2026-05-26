import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/provider/checkout_provider.dart';
import 'package:warteg_app/provider/promo_provider.dart';
import 'package:warteg_app/theme/color_theme.dart';

class PromoPage extends ConsumerWidget {
  const PromoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promos = ref.watch(promoProvider);

    final checkout = ref.watch(checkoutProvider);

    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,

      appBar: AppBar(
        backgroundColor: ColorTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Promo & Voucher",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: Column(
        children: [
          // =========================
          // HEADER
          // =========================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
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
                const Text(
                  "Hemat lebih banyak 🎉",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Pilih promo terbaik untuk pesanan kamu dan dapatkan potongan harga menarik.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // =========================
          // PROMO LIST
          // =========================
          Expanded(
            child: promos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.discount,
                          size: 70,
                          color: Colors.grey.shade300,
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "Belum ada promo",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: promos.length,
                    itemBuilder: (_, index) {
                      final promo = promos[index];

                      final isSelected =
                          checkout.selectedPromo?.code == promo.code;

                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(checkoutProvider.notifier)
                              .selectPromo(promo);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: ColorTheme.primaryColor,
                              content: Text(
                                "${promo.code} berhasil digunakan",
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );

                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? ColorTheme.buttonPrimary
                                  : Colors.grey.shade200,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // LEFT SIDE
                              Container(
                                width: 95,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorTheme.buttonPrimary,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(22),
                                    bottomLeft: Radius.circular(22),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.discount_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "${promo.discountPercent.toInt()}%",
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(height: 2),

                                    const Text(
                                      "OFF",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // RIGHT SIDE
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              promo.code,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                          if (isSelected)
                                            const Icon(
                                              Icons.check_circle,
                                              color: ColorTheme.buttonPrimary,
                                            ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        promo.title,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          color: Colors.grey,
                                          height: 1.5,
                                        ),
                                      ),

                                      const SizedBox(height: 14),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ColorTheme.buttonPrimary
                                              .withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: Text(
                                          "Diskon ${promo.discountPercent.toInt()}% dari total belanja",
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: ColorTheme.buttonPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
