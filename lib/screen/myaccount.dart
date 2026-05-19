import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warteg_app/controller/auth_controller.dart';
import 'package:warteg_app/theme/color_theme.dart';

class MyAccountPage extends ConsumerStatefulWidget {
  const MyAccountPage({super.key});

  @override
  ConsumerState<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends ConsumerState<MyAccountPage> {

  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {

    final user = ref.read(currentUserProvider);

    if (user != null) {
      usernameController.text = user['username'] ?? '';
      phoneController.text = user['phone'] ?? '';
      addressController.text = user['address'] ?? '';
    }
  }

  Future<void> saveChanges() async {

    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) return;

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    final usersString = prefs.getString('users');

    if (usersString == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    List users = jsonDecode(usersString);

    final index = users.indexWhere(
      (u) => u['email'] == currentUser['email'],
    );

    if (index == -1) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // VALIDASI PASSWORD LAMA
    if (oldPasswordController.text.isNotEmpty ||
        newPasswordController.text.isNotEmpty) {

      if (oldPasswordController.text != users[index]['password']) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password lama salah'),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          isLoading = false;
        });

        return;
      }

      if (newPasswordController.text.length < 8) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password baru minimal 8 karakter',
            ),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          isLoading = false;
        });

        return;
      }

      users[index]['password'] =
          newPasswordController.text;
    }

    // UPDATE DATA
    users[index]['username'] =
        usernameController.text.trim();

    users[index]['phone'] =
        phoneController.text.trim();

    users[index]['address'] =
        addressController.text.trim();

    // SAVE USERS
    await prefs.setString(
      'users',
      jsonEncode(users),
    );

    // UPDATE CURRENT USER
    final updatedUser = users[index];

    await prefs.setString(
      'current_user',
      jsonEncode(updatedUser),
    );

    // UPDATE PROVIDER
    ref.read(currentUserProvider.notifier).state = {
      'username': updatedUser['username'],
      'email': updatedUser['email'],
      'phone': updatedUser['phone'],
      'address': updatedUser['address'],
    };

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil diperbarui'),
        backgroundColor: Colors.green,
      ),
    );

    oldPasswordController.clear();
    newPasswordController.clear();
  }

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,

      appBar: AppBar(
        backgroundColor: ColorTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Account',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ======================
            // PROFILE INFO
            // ======================
            const Text(
              'Profile Information',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _buildField(
              controller: usernameController,
              label: 'Username',
              hint: 'Input username',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 16),

            _buildField(
              controller: phoneController,
              label: 'Phone Number',
              hint: 'Input phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            _buildField(
              controller: addressController,
              label: 'Address',
              hint: 'Input address',
              icon: Icons.location_on_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 30),

            // ======================
            // CHANGE PASSWORD
            // ======================
            const Text(
              'Change Password',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _buildField(
              controller: oldPasswordController,
              label: 'Old Password',
              hint: 'Input old password',
              icon: Icons.lock_outline,
              isPassword: true,
            ),

            const SizedBox(height: 16),

            _buildField(
              controller: newPasswordController,
              label: 'New Password',
              hint: 'Input new password',
              icon: Icons.lock_reset_outlined,
              isPassword: true,
            ),

            const SizedBox(height: 40),

            // ======================
            // SAVE BUTTON
            // ======================
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      ColorTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),

                onPressed: isLoading
                    ? null
                    : saveChanges,

                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: controller,
          obscureText: isPassword,
          maxLines: maxLines,
          keyboardType: keyboardType,

          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),

            filled: true,
            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}