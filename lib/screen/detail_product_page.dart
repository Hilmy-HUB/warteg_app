import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/cart_item_model.dart';
import 'package:warteg_app/model/product_model.dart';
import 'package:warteg_app/provider/cart_provider.dart';
import 'package:warteg_app/screen/cart_page.dart';
import 'package:warteg_app/theme/color_theme.dart';

class DetailProductPage extends ConsumerStatefulWidget {
  final ProductModel product;

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

  int get hargaAwal => widget.product.price;

  int get hargaSatuan {
    int total = hargaAwal;

    if (addOn1) total += 2000;
    if (addOn2) total += 2000;
    if (addOn3) total += 3000;
    if (addOn4) total += 4000;

    return total;
  }

  int get totalHarga => hargaSatuan * quantity;

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
        color: value
            ? ColorTheme.buttonPrimary.withOpacity(0.06)
            : Colors.white,
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
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

      // ================= BOTTOM NAVBAR =================
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
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            onPressed: () {
              final cartItem = CartItemModel(
                id: UniqueKey().toString(),
                menuName: widget.product.menuName,
                image: widget.product.image,
                basePrice: widget.product.price,
                addOns: [
                  if (addOn1) "White Crackers",
                  if (addOn2) "Skin Crackers",
                  if (addOn3) "Extra Sambal",
                  if (addOn4) "Extra Rice",
                ],
                hargaSatuan: hargaSatuan,
                quantity: quantity,
              );

              ref.read(cartProvider.notifier).addToCart(cartItem);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Item successfully added to cart 🛒",
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Text(
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
                  color: Colors.white.withOpacity(0.4),
                ),
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Rp $totalHarga",
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
          // ================= SCROLLABLE CONTENT =================
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HERO IMAGE =================
                Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 380, // Sedikit lebih tinggi untuk efek overlap
                      child: Image.network(
                        widget.product.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradient overlay agar tombol atas lebih jelas
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 120,
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

                // ================= CONTENT =================
                Container(
                  transform: Matrix4.translationValues(
                    0.0,
                    -32.0,
                    0.0,
                  ), // Efek overlap ditarik ke atas
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
                      // ================= TITLE & QUANTITY =================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.menuName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // ================= QUANTITY =================
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
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
                                      setState(() {
                                        quantity--;
                                      });
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
                                    child: Icon(
                                      Icons.remove_rounded,
                                      size: 18,
                                      color: quantity > 1
                                          ? ColorTheme.buttonPrimary
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 36,
                                  child: Center(
                                    child: Text(
                                      "$quantity",
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      quantity++;
                                    });
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: ColorTheme.buttonPrimary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.add_rounded,
                                      size: 18,
                                      color: ColorTheme.buttonPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ================= PRICE =================
                      Text(
                        "Rp ${widget.product.price}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: ColorTheme.buttonPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= DESCRIPTION =================
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

                      // ================= ADD ONS TITLE =================
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
                          const Text(
                            "Pilih Tambahan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Optional",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ================= ADD ONS =================
                      buildAddOn(
                        title: "Kerupuk Putih",
                        price: 2000,
                        value: addOn1,
                        onChanged: (value) => setState(() => addOn1 = value!),
                      ),
                      buildAddOn(
                        title: "Kerupuk Kulit",
                        price: 2000,
                        value: addOn2,
                        onChanged: (value) => setState(() => addOn2 = value!),
                      ),
                      buildAddOn(
                        title: "Ekstra Sambal",
                        price: 3000,
                        value: addOn3,
                        onChanged: (value) => setState(() => addOn3 = value!),
                      ),
                      buildAddOn(
                        title: "Ekstra Nasi",
                        price: 4000,
                        value: addOn4,
                        onChanged: (value) => setState(() => addOn4 = value!),
                      ),

                      const SizedBox(height: 24),
                      Divider(color: Colors.grey.shade200, thickness: 1.5),
                      const SizedBox(height: 24),

                      // ================= NOTES =================
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
                          const Text(
                            "Catatan untuk Restoran",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: notesController,
                        maxLines: 4,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Misal: Jangan terlalu pedas, ya!",
                          hintStyle: const TextStyle(
                            color: Colors.black38,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(20),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: ColorTheme.buttonPrimary,
                              width: 1.5,
                            ),
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

          // ================= FLOATING APPBAR =================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BACK BUTTON
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
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // CART BUTTON
                  // CART BUTTON
                  Consumer(
                    builder: (context, ref, child) {
                      final cartItems = ref.watch(cartProvider);

                      int totalItems = 0;

                      for (var item in cartItems) {
                        totalItems += item.quantity;
                      }

                      return InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartPage(),
                            ),
                          );
                        },
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
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                size: 20,
                                color: ColorTheme.buttonPrimary,
                              ),
                            ),

                            // BADGE JUMLAH ITEM
                            if (totalItems > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "$totalItems",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
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
