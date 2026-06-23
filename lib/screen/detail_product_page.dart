import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/cart_item_model.dart';
import 'package:warteg_app/model/menu_model.dart';
import 'package:warteg_app/provider/cart_provider.dart';
import 'package:warteg_app/screen/cart_page.dart';
import 'package:warteg_app/theme/color_theme.dart';
import 'package:warteg_app/model/addon_model.dart';

class DetailProductPage extends ConsumerStatefulWidget {
  final MenuModel product;

  const DetailProductPage({super.key, required this.product});

  @override
  ConsumerState<DetailProductPage> createState() => _DetailProductPageState();
}

class _DetailProductPageState extends ConsumerState<DetailProductPage> {
  final TextEditingController notesController = TextEditingController();

  bool addOn1 = false;
  bool addOn2 = false;
  bool addOn3 = false;
  bool addOn4 = false;

  int quantity = 1;

  // Daftar add on dengan harga
  static const _addOnList = [
    AddOnModel(name: 'Kerupuk Putih', price: 2000),
    AddOnModel(name: 'Kerupuk Kulit', price: 2000),
    AddOnModel(name: 'Ekstra Sambal', price: 3000),
    AddOnModel(name: 'Ekstra Nasi',   price: 4000),
  ];

  List<bool> get _addOnSelected => [addOn1, addOn2, addOn3, addOn4];

  List<AddOnModel> get selectedAddOns => [
        for (int i = 0; i < _addOnList.length; i++)
          if (_addOnSelected[i]) _addOnList[i],
      ];

  double get hargaAwal => widget.product.price;

  double get hargaSatuan {
    double total = hargaAwal;
    for (int i = 0; i < _addOnList.length; i++) {
      if (_addOnSelected[i]) total += _addOnList[i].price;
    }
    return total;
  }

  double get totalHarga => hargaSatuan * quantity;

  Widget _buildImage() {
    final url = widget.product.imageUrl;
    if (url == null) {
      return Container(
        width: double.infinity,
        height: 380,
        color: Colors.grey.shade200,
        child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
      );
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: double.infinity,
        height: 380,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: 380,
          color: Colors.grey.shade200,
          child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
        ),
      );
    }
    return Image.asset(
      url,
      width: double.infinity,
      height: 380,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: double.infinity,
        height: 380,
        color: Colors.grey.shade200,
        child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
      ),
    );
  }

  Widget buildAddOn({
    required String title,
    required int price,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: value ? ColorTheme.buttonPrimary.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? ColorTheme.buttonPrimary.withOpacity(0.4)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          if (!value)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: ColorTheme.buttonPrimary,
        checkboxShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: value ? ColorTheme.buttonPrimary : Colors.black87,
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ColorTheme.buttonPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "+ Rp $price",
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ColorTheme.buttonPrimary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTheme.buttonPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            onPressed: () {
              final cartItem = CartItemModel(
                id: UniqueKey().toString(),
                productId: widget.product.id,
                menuName: widget.product.name,
                image: widget.product.imageUrl ?? '',
                basePrice: widget.product.price.toInt(),
                addOns: selectedAddOns,
                quantity: quantity,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );

              ref.read(cartProvider.notifier).addToCart(cartItem);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Item successfully added to cart!",
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_bag_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Tambah ke Keranjang",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                    width: 1.5,
                    height: 24,
                    color: Colors.white.withOpacity(0.4)),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Rp ${totalHarga.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HERO IMAGE ──
                Stack(
                  children: [
                    _buildImage(),
                    Positioned(
                      top: 0, left: 0, right: 0, height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── CONTENT ──
                Container(
                  transform: Matrix4.translationValues(0, -32, 0),
                  decoration: BoxDecoration(
                    color: ColorTheme.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & quantity
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.grey.shade200, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (quantity > 1) {
                                      setState(() => quantity--);
                                    }
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: quantity > 1
                                          ? ColorTheme.buttonPrimary
                                              .withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(Icons.remove_rounded,
                                        size: 18,
                                        color: quantity > 1
                                            ? ColorTheme.buttonPrimary
                                            : Colors.grey.shade400),
                                  ),
                                ),
                                SizedBox(
                                  width: 36,
                                  child: Center(
                                    child: Text("$quantity",
                                        style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => quantity++),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: ColorTheme.buttonPrimary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.add_rounded,
                                        size: 18,
                                        color: ColorTheme.buttonPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Price
                      Text(
                        "Rp ${widget.product.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: ColorTheme.buttonPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        widget.product.description,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black54,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 28),
                      Divider(color: Colors.grey.shade200, thickness: 1.5),
                      const SizedBox(height: 24),

                      // Add-ons title
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 22,
                            decoration: BoxDecoration(
                              color: ColorTheme.buttonPrimary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text("Pilih Tambahan",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins')),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text("Optional",
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      buildAddOn(
                          title: _addOnList[0].name,
                          price: _addOnList[0].price,
                          value: addOn1,
                          onChanged: (v) => setState(() => addOn1 = v!)),
                      buildAddOn(
                          title: _addOnList[1].name,
                          price: _addOnList[1].price,
                          value: addOn2,
                          onChanged: (v) => setState(() => addOn2 = v!)),
                      buildAddOn(
                          title: _addOnList[2].name,
                          price: _addOnList[2].price,
                          value: addOn3,
                          onChanged: (v) => setState(() => addOn3 = v!)),
                      buildAddOn(
                          title: _addOnList[3].name,
                          price: _addOnList[3].price,
                          value: addOn4,
                          onChanged: (v) => setState(() => addOn4 = v!)),

                      const SizedBox(height: 24),
                      Divider(color: Colors.grey.shade200, thickness: 1.5),
                      const SizedBox(height: 24),

                      // Notes
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 22,
                            decoration: BoxDecoration(
                              color: ColorTheme.buttonPrimary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text("Catatan untuk Restoran",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins')),
                        ],
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: notesController,
                        maxLines: 4,
                        style: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Misal: Jangan terlalu pedas, ya!",
                          hintStyle: const TextStyle(
                              color: Colors.black38,
                              fontFamily: 'Poppins',
                              fontSize: 14),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(20),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color: Colors.grey.shade200, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: ColorTheme.buttonPrimary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating AppBar
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Colors.black87),
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final cartItems = ref.watch(cartProvider);
                      int totalItems = cartItems.fold(
                          0, (sum, item) => sum + item.quantity);
                      return InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CartPage())),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.shopping_cart_outlined,
                                  size: 20,
                                  color: ColorTheme.buttonPrimary),
                            ),
                            if (totalItems > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(
                                      minWidth: 20, minHeight: 20),
                                  decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle),
                                  child: Text("$totalItems",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins')),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}