import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/controller/auth_controller.dart';
import 'package:warteg_app/screen/address_page.dart';
import 'package:warteg_app/theme/color_theme.dart';

class MyAccountPage extends ConsumerStatefulWidget {
  const MyAccountPage({super.key});

  @override
  ConsumerState<MyAccountPage> createState() =>
      _MyAccountPageState();
}

class _MyAccountPageState
    extends ConsumerState<MyAccountPage> {
  final usernameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final oldPasswordController =
      TextEditingController();

  final newPasswordController =
      TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user =
        ref.read(currentUserProvider);

    if (user != null) {
      usernameController.text =
          user['username'] ?? '';

      phoneController.text =
          user['phone'] ?? '';
    }
  }

  Future<void> saveChanges() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    // UPDATE CURRENT USER DATA LOCALLY
    final updatedUser = Map<String, dynamic>.from(currentUser);
    updatedUser['username'] = usernameController.text.trim();
    updatedUser['phone'] = phoneController.text.trim();

    // SAVE TO PREFS
    await prefs.setString(
      'current_user',
      jsonEncode(updatedUser),
    );

    // UPDATE RIVERPOD STATE
    ref.read(currentUserProvider.notifier).state = updatedUser;

    setState(() {
      isLoading = false;
    });

    oldPasswordController.clear();
    newPasswordController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile berhasil diperbarui'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user =
        ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F7F4),

      // ======================
      // FIXED SAVE BUTTON
      // ======================
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          MediaQuery.of(context)
                  .padding
                  .bottom +
              14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  ColorTheme.buttonPrimary,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                        18),
              ),
            ),
            onPressed:
                isLoading ? null : saveChanges,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                        CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                : const Text(
                    "Simpan Perubahan",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight:
                          FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ======================
            // APPBAR
            // ======================
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                      16, 14, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                                    0.06),
                            blurRadius: 8,
                            offset:
                                const Offset(
                                    0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons
                            .arrow_back_ios_new_rounded,
                        size: 17,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Text(
                    "Akun Saya",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),

            // ======================
            // CONTENT
            // ======================
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(
                        16, 4, 16, 30),
                children: [
                  // ======================
                  // PROFILE CARD
                  // ======================
                  Container(
                    padding:
                        const EdgeInsets.all(
                            20),
                    decoration: BoxDecoration(
                      gradient:
                          const LinearGradient(
                        colors: [
                          ColorTheme
                              .primaryColor,
                          ColorTheme
                              .secondaryColor,
                        ],
                        begin:
                            Alignment.topLeft,
                        end: Alignment
                            .bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                              24),
                      boxShadow: [
                        BoxShadow(
                          color: ColorTheme
                              .primaryColor
                              .withOpacity(
                                  0.25),
                          blurRadius: 18,
                          offset:
                              const Offset(
                                  0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration:
                              BoxDecoration(
                            color: Colors.white
                                .withOpacity(
                                    0.15),
                            shape:
                                BoxShape.circle,
                            border: Border.all(
                              color: Colors
                                  .white
                                  .withOpacity(
                                      0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),

                        const SizedBox(
                            width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                user?['username'] ??
                                    '-',
                                style:
                                    const TextStyle(
                                  fontFamily:
                                      'Poppins',
                                  fontSize: 21,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  color: Colors
                                      .white,
                                ),
                              ),

                              const SizedBox(
                                  height: 6),

                              Text(
                                user?['email'] ??
                                    '-',
                                style:
                                    TextStyle(
                                  fontFamily:
                                      'Poppins',
                                  fontSize: 13,
                                  color: Colors
                                      .white
                                      .withOpacity(
                                          0.9),
                                ),
                              ),

                              const SizedBox(
                                  height: 10),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                          0.14),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              20),
                                ),
                                child:
                                    const Text(
                                  "Premium Member",
                                  style:
                                      TextStyle(
                                    fontFamily:
                                        'Poppins',
                                    fontSize:
                                        11,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                    color: Colors
                                        .white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ======================
                  // ACCOUNT MENU
                  // ======================
                  const Text(
                    "Menu akun",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddressPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.all(
                              18),
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                                    0.04),
                            blurRadius: 10,
                            offset:
                                const Offset(
                                    0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration:
                                BoxDecoration(
                              color: ColorTheme
                                  .buttonPrimary
                                  .withOpacity(
                                      0.08),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          14),
                            ),
                            child: const Icon(
                              Icons
                                  .location_on_rounded,
                              color: ColorTheme
                                  .buttonPrimary,
                            ),
                          ),

                          const SizedBox(
                              width: 14),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  "Alamat Saya",
                                  style:
                                      TextStyle(
                                    fontFamily:
                                        'Poppins',
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    fontSize:
                                        14,
                                  ),
                                ),

                                SizedBox(
                                    height: 4),

                                Text(
                                  "Atur alamat kamu",
                                  style:
                                      TextStyle(
                                    fontFamily:
                                        'Poppins',
                                    fontSize:
                                        12,
                                    color: Colors
                                        .grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons
                                .chevron_right_rounded,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ======================
                  // EDIT PROFILE
                  // ======================
                  const Text(
                    "Edit Profil",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  buildField(
                    controller:
                        usernameController,
                    label: "Username",
                    hint: "Input username",
                    icon:
                        Icons.person_outline,
                  ),

                  const SizedBox(height: 24),

                  // ======================
                  // PASSWORD
                  // ======================
                  const Text(
                    "Ganti Password",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  buildField(
                    controller:
                        oldPasswordController,
                    label: "Password Lama",
                    hint:
                        "Input password lama",
                    icon:
                        Icons.lock_outline,
                    isPassword: true,
                  ),

                  const SizedBox(height: 16),

                  buildField(
                    controller:
                        newPasswordController,
                    label: "Password Baru",
                    hint:
                        "Input password baru",
                    icon: Icons
                        .lock_reset_outlined,
                    isPassword: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField({
    required TextEditingController
        controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.grey.shade400,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            icon,
            color: ColorTheme.buttonPrimary,
          ),
        ),
      ),
    );
  }
}