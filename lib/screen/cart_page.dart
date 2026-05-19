import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/cart_item_model.dart';
import 'package:warteg_app/provider/cart_provider.dart';
import 'package:warteg_app/theme/color_theme.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);

    bool semuaDipilih =
        items.isNotEmpty && items.every((e) => e.isSelected);

    List<CartItemModel> itemDipilih =
        items.where((e) => e.isSelected).toList();

    int totalBayar = itemDipilih.fold(
      0,
      (sum, item) => sum + item.totalHarga,
    );

    int totalItemDipilih = itemDipilih.fold(
      0,
      (sum, item) => sum + item.quantity,
    );

    void toggleSelectAll(bool? value) {
      for (var item in items) {
        item.isSelected = value ?? false;
      }

      ref.read(cartProvider.notifier).state = [...items];
    }

    void hapusItem(CartItemModel item) {
      ref
          .read(cartProvider.notifier)
          .removeItem(item.id);
    }

    void hapusItemTerpilih() {
      for (var item in itemDipilih) {
        ref
            .read(cartProvider.notifier)
            .removeItem(item.id);
      }
    }

    Widget buildCartItem(CartItemModel item) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.isSelected
                ? ColorTheme.buttonPrimary
                    .withOpacity(0.3)
                : Colors.grey.shade100,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // CHECKBOX
              Padding(
                padding:
                    const EdgeInsets.only(top: 2),
                child: Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: item.isSelected,
                    onChanged: (val) {
                      item.isSelected =
                          val ?? false;

                      ref
                          .read(
                              cartProvider.notifier)
                          .state = [...items];
                    },
                    activeColor:
                        ColorTheme.buttonPrimary,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              5),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // IMAGE
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(14),
                child: Image.network(
                  item.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              // INFO
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.menuName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    // ADDONS
                    if (item.addOns.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                                top: 6),
                        child: Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children: item.addOns
                              .map(
                                (addOn) =>
                                    Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: ColorTheme
                                        .buttonPrimary
                                        .withOpacity(
                                            0.07),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                20),
                                  ),
                                  child: Text(
                                    "+ $addOn",
                                    style:
                                        const TextStyle(
                                      fontFamily:
                                          'Poppins',
                                      fontSize:
                                          10,
                                      color: ColorTheme
                                          .buttonPrimary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              "Rp ${item.hargaSatuan}",
                              style:
                                  const TextStyle(
                                fontFamily:
                                    'Poppins',
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "Rp ${item.totalHarga}",
                              style:
                                  const TextStyle(
                                fontFamily:
                                    'Poppins',
                                fontSize: 15,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                color: ColorTheme
                                    .buttonPrimary,
                              ),
                            ),
                          ],
                        ),

                        // QUANTITY
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (item.quantity >
                                    1) {
                                  ref
                                      .read(
                                          cartProvider
                                              .notifier)
                                      .decreaseQty(
                                          item.id);
                                } else {
                                  hapusItem(item);
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration:
                                    BoxDecoration(
                                  color: item
                                              .quantity ==
                                          1
                                      ? Colors.red
                                          .shade50
                                      : ColorTheme
                                          .buttonPrimary
                                          .withOpacity(
                                              0.08),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              10),
                                ),
                                child: Icon(
                                  item.quantity ==
                                          1
                                      ? Icons
                                          .delete_outline_rounded
                                      : Icons
                                          .remove_rounded,
                                  size: 16,
                                  color: item
                                              .quantity ==
                                          1
                                      ? Colors
                                          .redAccent
                                      : ColorTheme
                                          .buttonPrimary,
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 32,
                              child: Center(
                                child: Text(
                                  "${item.quantity}",
                                  style:
                                      const TextStyle(
                                    fontFamily:
                                        'Poppins',
                                    fontSize:
                                        14,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                ref
                                    .read(
                                        cartProvider
                                            .notifier)
                                    .increaseQty(
                                        item.id);
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration:
                                    BoxDecoration(
                                  color: ColorTheme
                                      .buttonPrimary
                                      .withOpacity(
                                          0.08),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              10),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  size: 16,
                                  color: ColorTheme
                                      .buttonPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          ColorTheme.backgroundColor,

      // BOTTOM NAV
      bottomNavigationBar: Container(
        padding:
            const EdgeInsets.fromLTRB(
                20, 14, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                  "$totalItemDipilih item dipilih",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      "Total Pembayaran  ",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "Rp $totalBayar",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                        color: ColorTheme
                            .buttonPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      itemDipilih.isEmpty
                          ? Colors.grey
                              .shade300
                          : ColorTheme
                              .buttonPrimary,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                  elevation: 0,
                ),
                onPressed:
                    itemDipilih.isEmpty
                        ? null
                        : () {},
                child: Text(
                  itemDipilih.isEmpty
                      ? "Pilih produk dulu"
                      : "Pesan Sekarang ($totalItemDipilih item)",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 14,
                    color:
                        itemDipilih.isEmpty
                            ? Colors.grey
                            : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // APPBAR
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                      20, 16, 20, 0),
              child: Row(
                children: [
                  InkWell(
                    borderRadius:
                        BorderRadius.circular(
                            50),
                    onTap: () =>
                        Navigator.pop(context),
                    child: Container(
                      padding:
                          const EdgeInsets.all(
                              9),
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius
                                .circular(50),
                      ),
                      child: const Icon(
                        Icons
                            .arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Text(
                    "Keranjang",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  if (itemDipilih.isNotEmpty)
                    GestureDetector(
                      onTap:
                          hapusItemTerpilih,
                      child: Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.red.shade50,
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      10),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons
                                  .delete_outline_rounded,
                              size: 16,
                              color: Colors
                                  .redAccent,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Hapus",
                              style:
                                  TextStyle(
                                fontFamily:
                                    'Poppins',
                                fontSize:
                                    12,
                                color: Colors
                                    .redAccent,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // SELECT ALL
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                          14),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: semuaDipilih,
                      onChanged: items.isEmpty
                          ? null
                          : toggleSelectAll,
                      activeColor:
                          ColorTheme
                              .buttonPrimary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Pilih Semua",
                    ),
                    const Spacer(),
                    Text(
                      "${items.length} produk",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // LIST ITEM
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons
                                .shopping_bag_outlined,
                            size: 72,
                            color: Colors
                                .grey.shade300,
                          ),
                          const SizedBox(
                              height: 16),
                          const Text(
                            "Keranjang kamu kosong",
                            style: TextStyle(
                              fontFamily:
                                  'Poppins',
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color:
                                  Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 20,
                      ),
                      itemCount: items.length,
                      itemBuilder:
                          (_, index) =>
                              buildCartItem(
                        items[index],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}