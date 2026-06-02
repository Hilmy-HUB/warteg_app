import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/cart_item_model.dart';
import 'package:warteg_app/provider/cart_provider.dart';
import 'package:warteg_app/screen/order_detail_page.dart';
import 'package:warteg_app/theme/color_theme.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  static String _formatRupiah(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    final mod = s.length % 3;
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (i - mod) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);

    final bool allSelected =
        items.isNotEmpty && items.every((e) => e.isSelected);
    final List<CartItemModel> selectedItems = items
        .where((e) => e.isSelected)
        .toList();
    final int totalPrice = selectedItems.fold(
      0,
      (sum, item) => sum + item.totalHarga,
    );
    final int totalQty = selectedItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );

    void toggleSelectAll(bool? value) {
      for (var item in items) {
        item.isSelected = value ?? false;
      }
      ref.read(cartProvider.notifier).updateCart(items);
    }

    void removeItem(CartItemModel item) {
      ref.read(cartProvider.notifier).removeItem(item.id);
    }

    void removeSelected() {
      for (var item in selectedItems) {
        ref.read(cartProvider.notifier).removeItem(item.id);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),

      // ── Bottom Bar ─────────────────────────────────────────────────────────
      bottomNavigationBar: _BottomBar(
        selectedCount: totalQty,
        totalPrice: totalPrice,
        hasSelection: selectedItems.isNotEmpty,
        formatRupiah: _formatRupiah,
        onCheckout: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailPage(items: selectedItems),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ───────────────────────────────────────────────────────
            _CartAppBar(
              hasSelected: selectedItems.isNotEmpty,
              onBack: () => Navigator.maybePop(context),
              onDelete: removeSelected,
            ),

            const SizedBox(height: 12),

            // ── Select All Row ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SelectAllRow(
                allSelected: allSelected,
                itemCount: items.length,
                enabled: items.isNotEmpty,
                onToggle: toggleSelectAll,
              ),
            ),

            const SizedBox(height: 12),

            // ── Cart List ─────────────────────────────────────────────────────
            Expanded(
              child: items.isEmpty
                  ? const _EmptyCart()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: items.length,
                      itemBuilder: (_, index) => _CartItemCard(
                        item: items[index],
                        allItems: items,
                        ref: ref,
                        onRemove: () => removeItem(items[index]),
                        formatRupiah: _formatRupiah,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _CartAppBar extends StatelessWidget {
  final bool hasSelected;
  final VoidCallback onBack;
  final VoidCallback onDelete;

  const _CartAppBar({
    required this.hasSelected,
    required this.onBack,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(width: 14),

          const Text(
            'Keranjang Saya',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.4,
            ),
          ),

          const Spacer(),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: hasSelected
                ? GestureDetector(
                    key: const ValueKey('delete'),
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Hapus',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }
}

// ─── Select All Row ───────────────────────────────────────────────────────────

class _SelectAllRow extends StatelessWidget {
  final bool allSelected;
  final int itemCount;
  final bool enabled;
  final ValueChanged<bool?> onToggle;

  const _SelectAllRow({
    required this.allSelected,
    required this.itemCount,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: allSelected,
            onChanged: enabled ? onToggle : null,
            activeColor: ColorTheme.buttonPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Pilih Semua',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7F4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

// ─── Cart Item Card ───────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final List<CartItemModel> allItems;
  final WidgetRef ref;
  final VoidCallback onRemove;
  final String Function(int) formatRupiah;

  const _CartItemCard({
    required this.item,
    required this.allItems,
    required this.ref,
    required this.onRemove,
    required this.formatRupiah,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isSelected
              ? ColorTheme.buttonPrimary.withOpacity(0.35)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Checkbox ──
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: item.isSelected,
                  onChanged: (val) {
                    item.isSelected = val ?? false;

                    ref.read(cartProvider.notifier).updateCart(allItems);
                  },
                  activeColor: ColorTheme.buttonPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 6),

            // ── Image ──
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                item.image,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 76,
                  height: 76,
                  color: Colors.grey.shade100,
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    color: Colors.grey.shade300,
                    size: 26,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ── Details ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.menuName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Add-ons
                  if (item.addOns.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: item.addOns
                            .map(
                              (addOn) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorTheme.buttonPrimary.withOpacity(
                                    0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '+ $addOn',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: ColorTheme.buttonPrimary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 6),

                  // Notes
                  if (item.notes != null && item.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catatan untuk penjual',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.sticky_note_2_outlined,
                                size: 12,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.notes!,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rp ${formatRupiah(item.hargaSatuan)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Text(
                            'Rp ${formatRupiah(item.totalHarga)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: ColorTheme.buttonPrimary,
                            ),
                          ),
                        ],
                      ),

                      // Quantity Controls
                      _QtyControls(
                        quantity: item.quantity,
                        onDecrease: () {
                          if (item.quantity > 1) {
                            ref
                                .read(cartProvider.notifier)
                                .decreaseQty(item.id);
                          } else {
                            onRemove();
                          }
                        },
                        onIncrease: () {
                          ref.read(cartProvider.notifier).increaseQty(item.id);
                        },
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
}

// ─── Quantity Controls ────────────────────────────────────────────────────────

class _QtyControls extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QtyControls({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = quantity == 1;

    return Row(
      children: [
        GestureDetector(
          onTap: onDecrease,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isLast
                  ? Colors.red.shade50
                  : ColorTheme.buttonPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isLast ? Icons.delete_outline_rounded : Icons.remove_rounded,
              size: 16,
              color: isLast ? Colors.redAccent : ColorTheme.buttonPrimary,
            ),
          ),
        ),

        SizedBox(
          width: 34,
          child: Center(
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
        ),

        GestureDetector(
          onTap: onIncrease,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ColorTheme.buttonPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 16,
              color: ColorTheme.buttonPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Empty Cart ───────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 42,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add items to get started',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int selectedCount;
  final int totalPrice;
  final bool hasSelection;
  final String Function(int) formatRupiah;
  final VoidCallback onCheckout;

  const _BottomBar({
    required this.selectedCount,
    required this.totalPrice,
    required this.hasSelection,
    required this.formatRupiah,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPadding + 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary row
          Row(
            children: [
              // Item count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: hasSelection
                      ? ColorTheme.buttonPrimary.withOpacity(0.08)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasSelection
                      ? '$selectedCount ${selectedCount == 1 ? 'Item' : 'Items'} dipilih'
                      : 'Tidak ada item yang dipilih',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: hasSelection
                        ? ColorTheme.buttonPrimary
                        : Colors.grey.shade400,
                  ),
                ),
              ),

              const Spacer(),

              // Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Text(
                    'Rp ${formatRupiah(totalPrice)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: ColorTheme.buttonPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Checkout button
          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasSelection
                    ? ColorTheme.buttonPrimary
                    : Colors.grey.shade200,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: hasSelection ? onCheckout : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasSelection
                        ? Icons.shopping_bag_rounded
                        : Icons.remove_shopping_cart_outlined,
                    size: 18,
                    color: hasSelection ? Colors.white : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasSelection
                        ? 'Pesan ($selectedCount ${selectedCount == 1 ? 'Item' : 'Items'})'
                        : 'Pilih item untuk checkout',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: hasSelection ? Colors.white : Colors.grey.shade400,
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
