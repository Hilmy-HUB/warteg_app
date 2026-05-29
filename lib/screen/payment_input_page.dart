import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warteg_app/model/payment_detail_mode.dart';
import 'package:warteg_app/provider/payment_detail_provider.dart';
import 'package:warteg_app/theme/color_theme.dart';

class PaymentInputPage extends ConsumerStatefulWidget {
  final String methodName;

  const PaymentInputPage({super.key, required this.methodName});

  @override
  ConsumerState<PaymentInputPage> createState() => _PaymentInputPageState();
}

class _PaymentInputPageState extends ConsumerState<PaymentInputPage> {
  final _cardNumber = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  final _phone = TextEditingController();
  final _pin = TextEditingController();

  bool _obscurePin = true;
  bool _obscureCvv = true;
  final _formKey = GlobalKey<FormState>();

  bool get _isCard => widget.methodName == "Mastercard";
  bool get _isEwallet =>
      {"DANA", "GoPay", "OVO"}.contains(widget.methodName);

  @override
  void initState() {
    super.initState();
    final existing = ref
        .read(paymentDetailProvider.notifier)
        .getByMethod(widget.methodName);

    if (existing != null) {
      _cardNumber.text = existing.cardNumber ?? '';
      _expiry.text = existing.expiry ?? '';
      _cvv.text = existing.cvv ?? '';
      _phone.text = existing.phoneNumber ?? '';
      _pin.text = existing.pin ?? '';
    }
  }

  @override
  void dispose() {
    _cardNumber.dispose();
    _expiry.dispose();
    _cvv.dispose();
    _phone.dispose();
    _pin.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(paymentDetailProvider.notifier).saveOrUpdate(
          PaymentDetailModel(
            methodName: widget.methodName,
            cardNumber: _isCard ? _cardNumber.text.trim() : null,
            expiry: _isCard ? _expiry.text.trim() : null,
            cvv: _isCard ? _cvv.text.trim() : null,
            phoneNumber: _isEwallet ? _phone.text.trim() : null,
            pin: _isEwallet ? _pin.text.trim() : null,
          ),
        );

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Payment details saved!',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                  Text(
                    widget.methodName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero banner ─────────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              ColorTheme.primaryColor,
                              ColorTheme.secondaryColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  ColorTheme.primaryColor.withOpacity(0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                _isCard
                                    ? Icons.credit_card_rounded
                                    : Icons.account_balance_wallet_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.methodName,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isCard
                                        ? 'Masukkan detail kartu anda di bawah ini'
                                        : 'Masukkan detail akun e-wallet anda',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12.5,
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Simulation notice ────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 16, color: Colors.amber.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '.',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11.5,
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── MASTERCARD fields ────────────────────────────────
                      if (_isCard) ...[
                        _FieldLabel(label: 'Nomor Kartu'),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _cardNumber,
                          hint: '0000 0000 0000 0000',
                          icon: Icons.credit_card_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                            _CardNumberFormatter(),
                          ],
                          validator: (v) {
                            final digits = v?.replaceAll(' ', '') ?? '';
                            if (digits.isEmpty) return 'Nomor kartu wajib diisi';
                            if (digits.length < 16)
                              return 'Masukkan nomor kartu 16 digit yang valid';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel(label: 'Tanggal Kedaluwarsa'),
                                  const SizedBox(height: 8),
                                  _InputField(
                                    controller: _expiry,
                                    hint: 'MM/YY',
                                    icon: Icons.calendar_month_rounded,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                      _ExpiryFormatter(),
                                    ],
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Wajib diisi';
                                      if (v.length < 5)
                                        return 'Masukkan MM/YY';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel(label: 'CVV'),
                                  const SizedBox(height: 8),
                                  _InputField(
                                    controller: _cvv,
                                    hint: '•••',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscureCvv,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3),
                                    ],
                                    suffixIcon: GestureDetector(
                                      onTap: () => setState(
                                          () => _obscureCvv = !_obscureCvv),
                                      child: Icon(
                                        _obscureCvv
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        size: 18,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Wajib diisi';
                                      if (v.length < 3)
                                        return 'Masukkan CVV 3 digit';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],

                      // ── E-WALLET fields ──────────────────────────────────
                      if (_isEwallet) ...[
                        _FieldLabel(label: 'Nomor Telepon / Akun'),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _phone,
                          hint: '08xx xxxx xxxx',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(13),
                          ],
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Nomor telepon wajib diisi';
                            if (v.length < 10)
                              return 'Masukkan nomor telepon yang valid';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _FieldLabel(label: 'PIN / Password'),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _pin,
                          hint: '••••••',
                          icon: Icons.lock_rounded,
                          obscureText: _obscurePin,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          suffixIcon: GestureDetector(
                            onTap: () =>
                                setState(() => _obscurePin = !_obscurePin),
                            child: Icon(
                              _obscurePin
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 18,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'PIN wajib diisi';
                            if (v.length < 4) return 'Masukkan setidaknya 4 digit';
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 36),

                      // ── Save button ──────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorTheme.buttonPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _save,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Simpan & Lanjutkan',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Field Label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

// ─── Input Field ──────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Colors.black87,
        letterSpacing: 0.5,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.5,
          color: Colors.grey.shade400,
          letterSpacing: 0,
        ),
        prefixIcon: Icon(icon, size: 20, color: ColorTheme.buttonPrimary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: ColorTheme.buttonPrimary.withOpacity(0.6),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
        ),
      ),
    );
  }
}

// ─── Card Number Formatter (adds spaces every 4 digits) ───────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ─── Expiry Formatter (MM/YY) ─────────────────────────────────────────────────

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}