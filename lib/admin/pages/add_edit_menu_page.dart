// lib/admin/pages/add_edit_menu_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/menu_model.dart';
import 'package:warteg_app/provider/menu_provider.dart';
import 'package:warteg_app/theme/color_theme.dart';
import 'package:image_picker/image_picker.dart';

const _availableAssets = [
  _AssetOption('assets/images/product/ayamkalio.png', 'Ayam Kalio'),
  _AssetOption('assets/images/product/cumicabeijo.png', 'Cumi Cabe Ijo'),
  _AssetOption('assets/images/product/mujaircabeijo.png', 'Mujair Cabe Ijo'),
  _AssetOption('assets/images/product/sopbuntut.png', 'Sop Buntut'),
  _AssetOption('assets/images/product/sambelati.png', 'Sambel Ati'),
  _AssetOption('assets/images/product/telorbalado.png', 'Telor Balado'),
  _AssetOption('assets/images/product/nasgor.png', 'Nasi Goreng'),
  _AssetOption('assets/images/product/tempeorek.png', 'Tempe Orek'),
];

class _AssetOption {
  final String path;
  final String label;
  const _AssetOption(this.path, this.label);
}

class AddEditMenuPage extends ConsumerStatefulWidget {
  final MenuModel? menu;
  const AddEditMenuPage({super.key, this.menu});

  @override
  ConsumerState<AddEditMenuPage> createState() => _AddEditMenuPageState();
}

class _AddEditMenuPageState extends ConsumerState<AddEditMenuPage> {
  late final TextEditingController _nameC;
  late final TextEditingController _descC;
  late final TextEditingController _priceC;
  late MenuCategory _selectedCategory;
  late bool _isAvailable;
  String? _selectedImagePath;

  bool get _isEdit => widget.menu != null;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.menu?.name ?? '');
    _descC = TextEditingController(text: widget.menu?.description ?? '');
    _priceC = TextEditingController(
      text: widget.menu != null ? widget.menu!.price.toInt().toString() : '',
    );
    _selectedCategory = widget.menu?.category ?? MenuCategory.lauk;
    _isAvailable = widget.menu?.isAvailable ?? true;
    _selectedImagePath = widget.menu?.imageUrl;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _descC.dispose();
    _priceC.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameC.text.trim();
    final desc = _descC.text.trim();
    final price = double.tryParse(_priceC.text.trim()) ?? 0;

    if (name.isEmpty || price <= 0) {
      _snack('Nama dan harga tidak boleh kosong', Colors.redAccent);
      return;
    }

    final notifier = ref.read(menuProvider.notifier);
    final newMenu = MenuModel(
      id: _isEdit ? widget.menu!.id : notifier.generateId(),
      name: name,
      description: desc,
      price: price,
      category: _selectedCategory,
      isAvailable: _isAvailable,
      imageUrl: _selectedImagePath,
    );

    if (_isEdit) {
      notifier.updateMenu(newMenu);
    } else {
      notifier.addMenu(newMenu);
    }

    _snack(
      _isEdit ? 'Menu berhasil diperbarui!' : 'Menu berhasil ditambahkan!',
      Colors.green,
    );
    Navigator.pop(context);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Pilih Gambar',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // ── Tombol dari galeri ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(
                  Icons.photo_library_rounded,
                  color: ColorTheme.primaryColor,
                ),
                label: const Text(
                  'Pilih dari Galeri',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: ColorTheme.primaryColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: ColorTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (picked != null) {
                    setState(() => _selectedImagePath = picked.path);
                  }
                },
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              '— atau pilih foto bawaan —',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),

          // ── Asset bawaan ──
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _availableAssets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final opt = _availableAssets[i];
                final selected = _selectedImagePath == opt.path;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedImagePath = opt.path);
                    Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? ColorTheme.primaryColor
                            : Colors.grey.withOpacity(0.2),
                        width: selected ? 2.5 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: ColorTheme.primaryColor.withOpacity(
                                  0.25,
                                ),
                                blurRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(opt.path, fit: BoxFit.cover),
                          if (selected)
                            Container(
                              color: ColorTheme.primaryColor.withOpacity(0.25),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 5,
                              ),
                              color: Colors.black.withOpacity(0.45),
                              child: Text(
                                opt.label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
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
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        _isEdit ? 'Edit Menu' : 'Tambah Menu',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
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
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _isEdit
                                ? Icons.edit_note_rounded
                                : Icons.add_circle_outline_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEdit ? 'Perbarui data menu' : 'Menu baru',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _isEdit
                                  ? 'Ubah informasi menu yang ada'
                                  : 'Isi detail menu yang akan ditambahkan',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto
                    _SectionCard(
                      title: 'Foto Menu',
                      icon: Icons.image_outlined,
                      iconColor: Colors.purple,
                      children: [
                        GestureDetector(
                          onTap: _showImagePicker,
                          child: Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.25),
                              ),
                            ),
                            child: _selectedImagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        _selectedImagePath!.startsWith('http')
                                            ? Image.network(
                                                _selectedImagePath!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _placeholder(),
                                              )
                                            : Image.asset(
                                                _selectedImagePath!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _placeholder(),
                                              ),
                                        Positioned(
                                          bottom: 10,
                                          right: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.55,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.edit_rounded,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  'Ganti Foto',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 11,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : _placeholder(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Informasi
                    _SectionCard(
                      title: 'Informasi Menu',
                      icon: Icons.info_outline_rounded,
                      iconColor: Colors.blue,
                      children: [
                        _FormField(
                          controller: _nameC,
                          label: 'Nama Menu',
                          hint: 'Contoh: Ayam Goreng',
                          icon: Icons.restaurant_menu_rounded,
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          controller: _descC,
                          label: 'Deskripsi (opsional)',
                          hint: 'Contoh: Ayam goreng crispy bumbu rempah',
                          icon: Icons.notes_rounded,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          controller: _priceC,
                          label: 'Harga (Rp)',
                          hint: 'Contoh: 15000',
                          icon: Icons.payments_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Kategori
                    _SectionCard(
                      title: 'Kategori',
                      icon: Icons.category_outlined,
                      iconColor: Colors.orange,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: MenuCategory.values.map((c) {
                            final selected = _selectedCategory == c;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = c),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? ColorTheme.primaryColor
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: selected
                                        ? ColorTheme.primaryColor
                                        : Colors.grey.withOpacity(0.25),
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: ColorTheme.primaryColor
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _categoryIcon(c),
                                      size: 14,
                                      color: selected
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      c.label,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Ketersediaan
                    _SectionCard(
                      title: 'Ketersediaan',
                      icon: Icons.toggle_on_rounded,
                      iconColor: Colors.green,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _isAvailable
                                ? Colors.green.withOpacity(0.07)
                                : Colors.grey.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isAvailable
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isAvailable
                                      ? Colors.green.withOpacity(0.12)
                                      : Colors.grey.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _isAvailable
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  color: _isAvailable
                                      ? Colors.green
                                      : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isAvailable
                                          ? 'Menu Tersedia'
                                          : 'Menu Tidak Tersedia',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _isAvailable
                                            ? Colors.green.shade700
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      _isAvailable
                                          ? 'Pelanggan dapat memesan menu ini'
                                          : 'Menu disembunyikan dari pelanggan',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isAvailable,
                                activeColor: Colors.green,
                                onChanged: (v) =>
                                    setState(() => _isAvailable = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: ColorTheme.primaryColor.withOpacity(0.4),
                        ),
                        onPressed: _submit,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isEdit
                                  ? Icons.save_rounded
                                  : Icons.add_circle_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isEdit ? 'Simpan Perubahan' : 'Tambah Menu',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_isEdit) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey.withOpacity(0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.add_photo_alternate_outlined,
        size: 40,
        color: Colors.grey.shade400,
      ),
      const SizedBox(height: 8),
      Text(
        'Ketuk untuk pilih foto',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: Colors.grey.shade400,
        ),
      ),
    ],
  );

  IconData _categoryIcon(MenuCategory c) => switch (c) {
    MenuCategory.nasi => Icons.rice_bowl_outlined,
    MenuCategory.lauk => Icons.set_meal_outlined,
    MenuCategory.sayur => Icons.eco_outlined,
    MenuCategory.minuman => Icons.local_drink_outlined,
    MenuCategory.snack => Icons.cookie_outlined,
  };
}

// Reusable widgets

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: Colors.grey.shade400,
        ),
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: ColorTheme.primaryColor,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
