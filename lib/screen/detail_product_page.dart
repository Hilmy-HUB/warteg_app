import 'package:flutter/material.dart';
import 'package:warteg_app/model/cart_item_model.dart';
import 'package:warteg_app/model/product_model.dart';
import 'package:warteg_app/theme/color_theme.dart';

class DetailProductPage extends StatefulWidget {
  final ProductModel product;

  const DetailProductPage({super.key, required this.product});

  @override
  State<DetailProductPage> createState() => _DetailProductPageState();
}

class _DetailProductPageState extends State<DetailProductPage> {
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: value ? ColorTheme.buttonPrimary.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? ColorTheme.buttonPrimary.withOpacity(0.4)
              : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: ColorTheme.buttonPrimary,
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: value ? ColorTheme.buttonPrimary : Colors.black87,
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.backgroundColor,

      // ================= BOTTOM NAVBAR =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorTheme.buttonPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: () {
              final cartItem = CartItemModel(
                id: UniqueKey().toString(),
                menuName: widget.product.menuName,
                image: widget.product.image,
                basePrice: widget.product.price,
                addOns: [
                  if (addOn1) "Kerupuk Putih",
                  if (addOn2) "Kerupuk Kulit",
                  if (addOn3) "Extra Sambal",
                  if (addOn4) "Nasi Extra",
                ],
                hargaSatuan: hargaSatuan,
                quantity: quantity,
              );
              // tambahkan ke state/provider keranjang
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      "Tambah ke Keranjang",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 28, color: Colors.white.withOpacity(0.3)),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      "Rp $totalHarga",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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
                // ================= HERO IMAGE FULL WIDTH =================
                Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 340,
                      child: Image.network(
                        widget.product.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradient overlay di bawah
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, ColorTheme.backgroundColor],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ================= KONTEN DETAIL =================
                Container(
                  color: ColorTheme.backgroundColor,
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= NAMA & QUANTITY =================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.menuName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (quantity > 1) setState(() => quantity--);
                                  },
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: quantity > 1
                                          ? ColorTheme.buttonPrimary.withOpacity(0.08)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.remove_rounded,
                                      size: 16,
                                      color: quantity > 1
                                          ? ColorTheme.buttonPrimary
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 32,
                                  child: Center(
                                    child: Text(
                                      "$quantity",
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => quantity++),
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: ColorTheme.buttonPrimary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.add_rounded,
                                      size: 16,
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

                      // ================= HARGA =================
                      Text(
                        "Rp ${widget.product.price}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorTheme.buttonPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ================= DESKRIPSI =================
                      Text(
                        widget.product.description,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.7,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 28),

                      Container(height: 1, color: Colors.grey.shade100),

                      const SizedBox(height: 24),

                      // ================= ADD ONS =================
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: ColorTheme.buttonPrimary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Tambah Add On",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Opsional",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

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
                        title: "Extra Sambal",
                        price: 3000,
                        value: addOn3,
                        onChanged: (value) => setState(() => addOn3 = value!),
                      ),
                      buildAddOn(
                        title: "Nasi Extra",
                        price: 4000,
                        value: addOn4,
                        onChanged: (value) => setState(() => addOn4 = value!),
                      ),

                      const SizedBox(height: 24),

                      Container(height: 1, color: Colors.grey.shade100),

                      const SizedBox(height: 24),

                      // ================= NOTES =================
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: ColorTheme.buttonPrimary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Catatan untuk Penjual",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: notesController,
                        maxLines: 4,
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Contoh: jangan pedas ya, kuahnya dipisah...",
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: ColorTheme.buttonPrimary.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ================= FIXED FLOATING APPBAR =================
          // Tombol back & keranjang di-overlay di atas Stack, tidak ikut scroll
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol back
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                  ),

                  // Tombol keranjang
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 18,
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
    );
  }
}