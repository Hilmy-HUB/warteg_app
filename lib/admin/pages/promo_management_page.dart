import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/promo_model.dart';
import 'package:warteg_app/provider/promo_provider.dart';

class PromoManagementPage extends ConsumerWidget {
  const PromoManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promos = ref.watch(promoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Kelola Promo',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.black87)),
      ),
      body: promos.isEmpty
          ? const Center(
              child: Text('Belum ada promo', style: TextStyle(fontFamily: 'Poppins')))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: promos.length,
              itemBuilder: (_, i) => _PromoCard(promo: promos[i]),
            ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final PromoModel promo;
  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: promo.freeShipping
              ? const Icon(Icons.local_shipping, color: Colors.pink, size: 20)
              : Text('${promo.discountPercent}%',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.pink)),
        ),
        title: Text(promo.title,
            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kode: ${promo.code}',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey[600])),
            if (promo.freeShipping)
              const Text('Gratis Ongkir',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 11, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}