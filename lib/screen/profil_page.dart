import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/controller/auth_controller.dart';
import 'package:warteg_app/screen/landing_page.dart';
import 'package:warteg_app/screen/myaccount.dart';
import 'package:warteg_app/screen/payment_page.dart';
import 'package:warteg_app/screen/promo_page.dart';
// import 'package:warteg_app/screen/signin_page.dart';
// import 'package:warteg_app/screen/welcome_page.dart';
import 'package:warteg_app/theme/color_theme.dart';

class ProfilPage extends ConsumerWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ==========================================
              // HEADER
              // ==========================================
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
                  children: [
                    // TITLE
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "My Profile",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // PROFILE CARD
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          // PHOTO
                          Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),

                          const SizedBox(width: 18),

                          // USER INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // USERNAME
                                Text(
                                  user?["username"] ?? "Guest User",
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                // EMAIL
                                Text(
                                  user?["email"] ?? "guest@gmail.com",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.85),
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

              const SizedBox(height: 25),

              // ==========================================
              // ACCOUNT SECTION
              // ==========================================
              _buildSectionTitle("Account"),

              _buildMenuItem(
                icon: Icons.person_outline_rounded,
                title: "My Account",
                subtitle: "Make changes to your account",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyAccountPage()),
                  );
                },
              ),

              _buildMenuItem(
                icon: Icons.credit_card_rounded,
                title: "Payments",
                subtitle: "Manage your billings and payments",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentPage()),
                  );
                },
              ),

              _buildMenuItem(
                icon: Icons.discount_outlined,
                title: "Promo",
                subtitle: "Apply coupon codes and earn discount",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PromoPage()),
                  );
                },
              ),

              _buildMenuItem(
                icon: Icons.restaurant_menu_rounded,
                title: "Subscriptions",
                subtitle: "Manage your meal plans",
              ),

              const SizedBox(height: 10),

              // ==========================================
              // GENERAL SECTION
              // ==========================================
              _buildSectionTitle("General"),

              _buildMenuItem(
                icon: Icons.accessibility_new_rounded,
                title: "Accessibility",
                subtitle: "Customize your experience",
              ),

              _buildMenuItem(
                icon: Icons.help_outline_rounded,
                title: "Help & Support",
                subtitle: "Get help from customer service",
              ),

              _buildMenuItem(
                icon: Icons.info_outline_rounded,
                title: "About App",
                subtitle: "Version 1.0.0",
              ),

              const SizedBox(height: 10),

              // ==========================================
              // LOGOUT BUTTON
              // ==========================================
              Padding(
                padding: const EdgeInsets.only(right: 20, left: 20, bottom: 55),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),

                  onTap: () async {
                    // LOGOUT SERVICE
                    await ref.read(authServiceProvider).logout();

                    // CLEAR PROVIDER
                    ref.read(currentUserProvider.notifier).state = null;

                    // PINDAH KE LOGIN
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LandingPage()),
                      (route) => false,
                    );
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.red),

                        SizedBox(width: 15),

                        Expanded(
                          child: Text(
                            "Log Out",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // SECTION TITLE
  // ==========================================
  static Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MENU ITEM
  // ==========================================
  static Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),

        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),

          child: Row(
            children: [
              // ICON
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorTheme.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Icon(icon, color: ColorTheme.primaryColor, size: 22),
              ),

              const SizedBox(width: 15),

              // TEXT
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

                    if (subtitle != null) ...[
                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[500],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
