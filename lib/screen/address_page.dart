import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/address_model.dart';
import 'package:warteg_app/provider/address_provider.dart';
import 'package:warteg_app/provider/checkout_provider.dart';
import 'package:warteg_app/theme/color_theme.dart';

class AddressPage extends ConsumerStatefulWidget {
  const AddressPage({super.key});

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddressPage> {
  final _labelController = TextEditingController();
  final _receiverController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _receiverController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _labelController.clear();
    _receiverController.clear();
    _phoneController.clear();
    _addressController.clear();
    _noteController.clear();
  }

  void _saveAddress() {
    final label = _labelController.text.trim();
    final receiver = _receiverController.text.trim();
    final phone = _phoneController.text.trim();
    final fullAddress = _addressController.text.trim();

    if (label.isEmpty || receiver.isEmpty || phone.isEmpty || fullAddress.isEmpty) {
      _showSnack('Please fill in all required fields', isError: true);
      return;
    }

    final address = AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      receiverName: receiver,
      phone: phone,
      fullAddress: fullAddress,
      note: _noteController.text.trim(),
    );

    final notifier = ref.read(addressProvider.notifier);

    notifier.addAddress(address);

    if (ref.read(addressProvider).length == 1) {
      notifier.selectAddress(address.id);
      ref.read(checkoutProvider.notifier).selectAddress(address);
    }

    _clearFields();

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    _showSnack('Address saved successfully');
  }

  void _updateAddress(String id) {
    final label = _labelController.text.trim();
    final receiver = _receiverController.text.trim();
    final phone = _phoneController.text.trim();
    final fullAddress = _addressController.text.trim();

    if (label.isEmpty || receiver.isEmpty || phone.isEmpty || fullAddress.isEmpty) {
      _showSnack('Please fill in all required fields', isError: true);
      return;
    }

    final updated = AddressModel(
      id: id,
      label: label,
      receiverName: receiver,
      phone: phone,
      fullAddress: fullAddress,
      note: _noteController.text.trim(),
    );

    ref.read(addressProvider.notifier).updateAddress(updated);

    _clearFields();

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    _showSnack('Address updated successfully');
  }

  void _openEditModal(AddressModel address) {
    _labelController.text = address.label;
    _receiverController.text = address.receiverName;
    _phoneController.text = address.phone;
    _addressController.text = address.fullAddress;
    _noteController.text = address.note;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddAddressSheet(
        labelController: _labelController,
        receiverController: _receiverController,
        phoneController: _phoneController,
        addressController: _addressController,
        noteController: _noteController,
        onSave: () => _updateAddress(address.id),
        isEditing: true,
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              msg,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openAddModal() {
    _clearFields();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddAddressSheet(
        labelController: _labelController,
        receiverController: _receiverController,
        phoneController: _phoneController,
        addressController: _addressController,
        noteController: _noteController,
        onSave: _saveAddress,
        isEditing: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ColorTheme.buttonPrimary,
        elevation: 3,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text(
          'Add Address',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        onPressed: _openAddModal,
      ),

      body: SafeArea(
        child: Column(
          children: [
            _AddressAppBar(onBack: () => Navigator.maybePop(context)),
            const SizedBox(height: 8),
            Expanded(
              child: addresses.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: addresses.length,
                      itemBuilder: (_, index) {
                        final address = addresses[index];

                        return Dismissible(
                          key: Key(address.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.only(right: 20),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          onDismissed: (direction) {
                            ref
                                .read(addressProvider.notifier)
                                .removeAddress(address.id);
                            _showSnack('Address deleted successfully');
                            HapticFeedback.mediumImpact();
                          },
                          child: _AddressCard(
                            address: address,
                            onTap: () {
                              ref
                                  .read(addressProvider.notifier)
                                  .selectAddress(address.id);
                              ref
                                  .read(checkoutProvider.notifier)
                                  .selectAddress(address);
                              _showSnack('Address selected successfully');
                              HapticFeedback.lightImpact();
                            },
                            onEdit: () => _openEditModal(address),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _AddressAppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _AddressAppBar({required this.onBack});

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
            'My Addresses',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              color: ColorTheme.buttonPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_rounded,
              size: 42,
              color: ColorTheme.buttonPrimary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No addresses yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the button below to add one',
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

// ─── Address Card ─────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _AddressCard({
    required this.address,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: address.isSelected
                ? ColorTheme.buttonPrimary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: address.isSelected
                  ? ColorTheme.buttonPrimary.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: address.isSelected
                    ? ColorTheme.buttonPrimary
                    : ColorTheme.buttonPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: address.isSelected
                    ? Colors.white
                    : ColorTheme.buttonPrimary,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label + Selected badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.label,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (address.isSelected) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: ColorTheme.buttonPrimary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Selected',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Receiver + phone
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        address.receiverName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.phone_outlined,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        address.phone,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Full address
                  Text(
                    address.fullAddress,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      height: 1.55,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  // Note
                  if (address.note.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            size: 13,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              address.note,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Edit button ──────────────────────────────────────
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ColorTheme.buttonPrimary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              size: 13,
                              color: ColorTheme.buttonPrimary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ColorTheme.buttonPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: address.isSelected
                  ? ColorTheme.buttonPrimary
                  : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add / Edit Address Bottom Sheet ─────────────────────────────────────────

class _AddAddressSheet extends StatelessWidget {
  final TextEditingController labelController;
  final TextEditingController receiverController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController noteController;
  final VoidCallback onSave;
  final bool isEditing;

  const _AddAddressSheet({
    required this.labelController,
    required this.receiverController,
    required this.phoneController,
    required this.addressController,
    required this.noteController,
    required this.onSave,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Title
            Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: ColorTheme.buttonPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isEditing ? 'Edit Address' : 'Add New Address',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    color: Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            _SheetField(
              controller: labelController,
              hint: 'Label (e.g. Home, Office)',
              icon: Icons.label_rounded,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: receiverController,
              hint: 'Recipient name',
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: phoneController,
              hint: 'Phone number',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: addressController,
              hint: 'Full address',
              icon: Icons.location_on_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: noteController,
              hint: 'Additional notes (optional)',
              icon: Icons.sticky_note_2_outlined,
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorTheme.buttonPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: onSave,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isEditing ? Icons.update_rounded : Icons.save_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? 'Update Address' : 'Save Address',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sheet Text Field ─────────────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;

  const _SheetField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13.5,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: Colors.grey.shade400,
        ),
        prefixIcon: Icon(icon, size: 20, color: ColorTheme.buttonPrimary),
        filled: true,
        fillColor: const Color(0xFFF8F7F4),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ColorTheme.buttonPrimary.withOpacity(0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}