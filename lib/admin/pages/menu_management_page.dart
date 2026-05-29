// lib/admin/pages/menu_management_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:warteg_app/model/menu_model.dart';
import 'package:warteg_app/provider/menu_provider.dart';


class MenuManagementPage extends ConsumerWidget {
  const MenuManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menus = ref.watch(menuProvider);
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Grouped by category
    final grouped = <MenuCategory, List<MenuModel>>{};
    for (final m in menus) {
      grouped.putIfAbsent(m.category, () => []).add(m);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Kelola Menu',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Menu',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        onPressed: () => _showMenuForm(context, ref),
      ),
      body: menus.isEmpty
          ? const Center(
              child: Text('Belum ada menu',
                  style: TextStyle(fontFamily: 'Poppins')))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final category in MenuCategory.values)
                  if (grouped.containsKey(category)) ...[
                    // Category header
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              category.label,
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final menu in grouped[category]!)
                      _MenuCard(
                        menu: menu,
                        currency: currency,
                        onEdit: () => _showMenuForm(context, ref, menu),
                      ),
                  ],
                const SizedBox(height: 80),
              ],
            ),
    );
  }

  void _showMenuForm(BuildContext context, WidgetRef ref, [MenuModel? menu]) {
    final isEdit = menu != null;
    final nameC = TextEditingController(text: menu?.name);
    final descC = TextEditingController(text: menu?.description);
    final priceC =
        TextEditingController(text: menu?.price.toInt().toString() ?? '');
    MenuCategory selectedCategory = menu?.category ?? MenuCategory.nasi;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Menu' : 'Tambah Menu',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(height: 16),
              _field(nameC, 'Nama Menu'),
              const SizedBox(height: 10),
              _field(descC, 'Deskripsi'),
              const SizedBox(height: 10),
              _field(priceC, 'Harga (Rp)',
                  keyboard: TextInputType.number),
              const SizedBox(height: 10),
              DropdownButtonFormField<MenuCategory>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  labelStyle:
                      const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.black87),
                items: MenuCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.label),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setS(() => selectedCategory = v);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final notifier = ref.read(menuProvider.notifier);
                    final m = MenuModel(
                      id: isEdit ? menu.id : notifier.generateId(),
                      name: nameC.text.trim(),
                      description: descC.text.trim(),
                      price: double.tryParse(priceC.text) ?? 0,
                      category: selectedCategory,
                      isAvailable: menu?.isAvailable ?? true,
                    );
                    if (isEdit) {
                      notifier.updateMenu(m);
                    } else {
                      notifier.addMenu(m);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    isEdit ? 'Simpan' : 'Tambah',
                    style: const TextStyle(
                        fontFamily: 'Poppins', color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
          {TextInputType keyboard = TextInputType.text}) =>
      TextField(
        controller: c,
        keyboardType: keyboard,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(fontFamily: 'Poppins', fontSize: 13),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );
}

class _MenuCard extends ConsumerWidget {
  final MenuModel menu;
  final NumberFormat currency;
  final VoidCallback onEdit;

  const _MenuCard(
      {required this.menu, required this.currency, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(menuProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
        border: Border.all(
          color: menu.isAvailable
              ? Colors.green.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.fastfood,
              color: Colors.redAccent, size: 22),
        ),
        title: Text(
          menu.name,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 13),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (menu.description.isNotEmpty)
              Text(
                menu.description,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 2),
            Text(
              currency.format(menu.price),
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: menu.isAvailable,
              activeColor: Colors.green,
              onChanged: (_) => notifier.toggleAvailability(menu.id),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.blue, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 20),
              onPressed: () => _confirmDelete(context, notifier),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MenuNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Menu',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Text('Hapus "${menu.name}" dari daftar menu?',
            style: const TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(fontFamily: 'Poppins')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              notifier.deleteMenu(menu.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus',
                style:
                    TextStyle(fontFamily: 'Poppins', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}