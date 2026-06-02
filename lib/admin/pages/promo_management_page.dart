import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/promo_model.dart';
import 'package:warteg_app/provider/promo_provider.dart';
import 'package:warteg_app/theme/color_theme.dart';

class PromoManagementPage extends ConsumerWidget {
  const PromoManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promos = ref.watch(promoProvider);

    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 24),
              decoration: const BoxDecoration(
                color: ColorTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
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
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Kelola Promo',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showPromoForm(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Tambah',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── List ────────────────────────────────────────
            Expanded(
              child: promos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.local_offer_outlined,
                              size: 38,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada promo',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: promos.length,
                      itemBuilder: (_, i) => _PromoCard(promo: promos[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPromoForm(BuildContext context, WidgetRef ref) {
    final codeC = TextEditingController();
    final titleC = TextEditingController();
    final discountC = TextEditingController();
    final minPurchaseC = TextEditingController();
    bool freeShipping = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                'Tambah Promo',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 20),

              _field(codeC, 'Kode Promo', hint: 'contoh: HEMAT20'),
              const SizedBox(height: 12),
              _field(titleC, 'Judul Promo', hint: 'contoh: Diskon 20%'),
              const SizedBox(height: 12),

              // Diskon % — disable kalau freeShipping
              _field(
                discountC,
                'Diskon (%)',
                hint: '0–100',
                keyboard: TextInputType.number,
                enabled: !freeShipping,
              ),
              const SizedBox(height: 12), 
             
              _field(
                minPurchaseC,
                'Minimal Pembelian (Rp)',
                hint: 'contoh: 20000',
                keyboard: TextInputType.number,
              ),
              const SizedBox(height: 4),

              // Free shipping toggle
              GestureDetector(
                onTap: () => setS(() {
                  freeShipping = !freeShipping;
                  if (freeShipping) discountC.text = '0';
                }),
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: freeShipping
                        ? ColorTheme.primaryColor.withOpacity(0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: freeShipping
                          ? ColorTheme.primaryColor.withOpacity(0.3)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          color: ColorTheme.primaryColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gratis Ongkir',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Aktifkan untuk promo bebas ongkos kirim',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: freeShipping,
                        activeColor: ColorTheme.primaryColor,
                        onChanged: (v) => setS(() {
                          freeShipping = v;
                          if (v) discountC.text = '0';
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorTheme.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    final code = codeC.text.trim().toUpperCase();
                    final title = titleC.text.trim();
                    final pct = int.tryParse(discountC.text.trim()) ?? 0;

                    if (code.isEmpty || title.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Kode dan judul tidak boleh kosong',
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        ),
                      );
                      return;
                    }

                    // Cek duplikat kode
                    final existing = ref.read(promoProvider);
                    if (existing.any((p) => p.code.toUpperCase() == code)) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Kode promo sudah ada',
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        ),
                      );
                      return;
                    }

                    ref
                        .read(promoProvider.notifier)
                        .addPromo(
                          PromoModel(
                            code: code,
                            title: title,
                            discountPercent: freeShipping ? 0 : pct,
                            freeShipping: freeShipping,
                          ),
                        );
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'Tambah Promo',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    String? hint,
    TextInputType keyboard = TextInputType.text,
    bool enabled = true,
  }) => TextField(
    controller: c,
    keyboardType: keyboard,
    enabled: enabled,
    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
      hintStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: Colors.grey.shade400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorTheme.primaryColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade100),
      ),
      filled: true,
      fillColor: enabled ? ColorTheme.backgroundColor : Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}

// ─────────────────────────────────────────────
// Promo Card
// ─────────────────────────────────────────────

class _PromoCard extends ConsumerWidget {
  final PromoModel promo;
  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(promoProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: promo.isActive
              ? ColorTheme.primaryColor.withOpacity(0.2)
              : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Badge diskon / ongkir
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: promo.isActive
                    ? ColorTheme.primaryColor.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: promo.freeShipping
                  ? Icon(
                      Icons.local_shipping_rounded,
                      color: promo.isActive
                          ? ColorTheme.primaryColor
                          : Colors.grey.shade400,
                      size: 22,
                    )
                  : Center(
                      child: Text(
                        '${promo.discountPercent}%',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: promo.isActive
                              ? ColorTheme.primaryColor
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: promo.isActive
                          ? Colors.black87
                          : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: promo.isActive
                              ? ColorTheme.primaryColor.withOpacity(0.08)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          promo.code,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: promo.isActive
                                ? ColorTheme.primaryColor
                                : Colors.grey.shade400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (promo.freeShipping) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Gratis Ongkir',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                Switch(
                  value: promo.isActive,
                  activeColor: ColorTheme.primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (_) => notifier.toggleActive(promo.code),
                ),
                GestureDetector(
                  onTap: () => _confirmDelete(context, notifier),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PromoNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Promo',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Hapus promo "${promo.title}"?',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              notifier.deletePromo(promo.code);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
