// lib/model/driver_model.dart

class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String vehicleNumber;
  final String vehicleType; // e.g. "Motor", "Mobil"
  final String? photoUrl;
  final double rating;

  const DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleNumber,
    required this.vehicleType,
    this.photoUrl,
    this.rating = 5.0,
  });

  DriverModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? vehicleNumber,
    String? vehicleType,
    String? photoUrl,
    double? rating,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'vehicleNumber': vehicleNumber,
        'vehicleType': vehicleType,
        'photoUrl': photoUrl,
        'rating': rating,
      };

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        vehicleNumber: json['vehicleNumber'] ?? '',
        vehicleType: json['vehicleType'] ?? 'Motor',
        photoUrl: json['photoUrl'] as String?,
        rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 5.0,
      );

  // Pool driver dummy — di production ganti dengan fetch dari backend
  static DriverModel randomDriver() {
    const drivers = [
      DriverModel(
        id: 'd001',
        name: 'Budi Santoso',
        phone: '08112345678',
        vehicleNumber: 'B 3421 XYZ',
        vehicleType: 'Motor',
        rating: 4.9,
      ),
      DriverModel(
        id: 'd002',
        name: 'Agus Prasetyo',
        phone: '08223456789',
        vehicleNumber: 'B 7812 ABK',
        vehicleType: 'Motor',
        rating: 4.7,
      ),
      DriverModel(
        id: 'd003',
        name: 'Rina Wulandari',
        phone: '08534567890',
        vehicleNumber: 'B 2290 KLS',
        vehicleType: 'Motor',
        rating: 4.8,
      ),
    ];
    final idx = DateTime.now().millisecond % drivers.length;
    return drivers[idx];
  }
}