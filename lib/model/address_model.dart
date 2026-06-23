class AddressModel {
  final String id;
  final String label;
  final String receiverName;
  final String phone;
  final String fullAddress;
  final String note;
  final bool isSelected;

  AddressModel({
    required this.id,
    required this.label,
    required this.receiverName,
    required this.phone,
    required this.fullAddress,
    required this.note,
    this.isSelected = false,
  });

  AddressModel copyWith({
    String? id,
    String? label,
    String? receiverName,
    String? phone,
    String? fullAddress,
    String? note,
    bool? isSelected,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      receiverName: receiverName ?? this.receiverName,
      phone: phone ?? this.phone,
      fullAddress: fullAddress ?? this.fullAddress,
      note: note ?? this.note,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'receiverName': receiverName,
      'phoneNumber': phone, // Aligned to backend 'phoneNumber'
      'phone': phone,       // Fallback for local uses
      'fullAddress': fullAddress,
      'note': note,
      'isSelected': isSelected,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      receiverName: json['receiverName'] ?? '',
      phone: json['phoneNumber'] ?? json['phone'] ?? '', // Handles both phoneNumber (backend) and phone (local/legacy)
      fullAddress: json['fullAddress'] ?? '',
      note: json['note'] ?? '',
      isSelected: json['isSelected'] ?? false,
    );
  }
}