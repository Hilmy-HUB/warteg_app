import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/theme/color_theme.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final _subsKey = 'subscription_';

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, Map<String, bool>>(
  (_) => SubscriptionNotifier(),
);

class SubscriptionNotifier extends StateNotifier<Map<String, bool>> {
  SubscriptionNotifier() : super({}) {
    _load();
  }

  final _topics = ['promo', 'menu_baru', 'diskon', 'event'];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, bool>{};
    for (final t in _topics) {
      result[t] = prefs.getBool('$_subsKey$t') ?? false;
    }
    state = result;
  }

  Future<void> toggle(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = !(state[topic] ?? false);
    await prefs.setBool('$_subsKey$topic', newVal);
    state = {...state, topic: newVal};
  }

  Future<void> setAll(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, bool>{};
    for (final t in _topics) {
      await prefs.setBool('$_subsKey$t', value);
      result[t] = value;
    }
    state = result;
  }

  bool get allEnabled =>
      state.isNotEmpty && state.values.every((v) => v == true);
}

// ── Page ─────────────────────────────────────────────────────────────────────

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs = ref.watch(subscriptionProvider);
    final notifier = ref.read(subscriptionProvider.notifier);
    final allOn = notifier.allEnabled;

    final topics = [
      {
        'key': 'promo',
        'title': 'Promo & Penawaran',
        'subtitle': 'Dapatkan info promo eksklusif langsung ke email kamu',
        'icon': Icons.local_offer_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'key': 'menu_baru',
        'title': 'Menu Baru',
        'subtitle': 'Notifikasi setiap ada menu baru yang diluncurkan',
        'icon': Icons.restaurant_menu_rounded,
        'color': ColorTheme.primaryColor,
      },
      {
        'key': 'diskon',
        'title': 'Diskon Spesial',
        'subtitle': 'Info diskon dan potongan harga untuk pelanggan setia',
        'icon': Icons.percent_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'key': 'event',
        'title': 'Event & Kegiatan',
        'subtitle': 'Update acara dan kegiatan spesial dari Warteg Endah',
        'icon': Icons.celebration_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    ];

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
                        'Berlangganan',
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
                          child: const Icon(Icons.email_rounded,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tetap terhubung dengan kami',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Aktifkan notifikasi email untuk info terbaru dari Warteg Endah',
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
                  // Toggle semua
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded,
                            color: ColorTheme.primaryColor, size: 22),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Aktifkan Semua',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Switch(
                          value: allOn,
                          activeColor: ColorTheme.primaryColor,
                          onChanged: (val) => notifier.setAll(val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      'Pilih topik langganan',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  ...topics.map((topic) {
                    final key = topic['key'] as String;
                    final color = topic['color'] as Color;
                    final isOn = subs[key] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: isOn
                            ? Border.all(
                                color: color.withOpacity(0.3), width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withOpacity(isOn ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(topic['icon'] as IconData,
                                color: color.withOpacity(isOn ? 1 : 0.5),
                                size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topic['title'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                    color: isOn
                                        ? Colors.black87
                                        : Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  topic['subtitle'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isOn,
                            activeColor: color,
                            onChanged: (_) => notifier.toggle(key),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
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
                            'Informasi akan dikirim ke email yang terdaftar. Kamu bisa berhenti berlangganan kapan saja.',
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