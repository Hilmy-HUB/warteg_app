import 'package:warteg_app/model/menu_model.dart';

class BannerItem {
  final String image;
  final MenuModel product;

  const BannerItem({required this.image, required this.product});
}

final List<BannerItem> bannerItems = [
  BannerItem(
    image: 'assets/images/homepage/paket1.png',
    product: MenuModel(
      id: 'banner_1',
      name: "Paket 1",
      description:
          'YANG KAMU DAPATKAN:\nNasi, Ayam Serundeng, Sambel Goreng Kentang, Minum Es Teh Manis.',
      price: 27000,
      category: MenuCategory.nasi,
      imageUrl: 'assets/images/homepage/paket1.png',
    ),
  ),
  BannerItem(
    image: 'assets/images/homepage/paket2.png',
    product: MenuModel(
      id: 'banner_2',
      name: "Paket 2",
      description:
          'YANG KAMU DAPATKAN:\nNasi, Telur Balado, Sambel Goreng Kentang, Minum Es Teh Manis.',
      price: 20000,
      category: MenuCategory.nasi,
      imageUrl: 'assets/images/homepage/paket2.png',
    ),
  ),
  BannerItem(
    image: 'assets/images/homepage/paket3.png',
    product: MenuModel(
      id: 'banner_3',
      name: "Paket 3",
      description:
          'YANG KAMU DAPATKAN:\nNasi, Orek Tempe & Labu Siam, Tumis Sayur, Minum Es Teh Manis.',
      price: 23000,
      category: MenuCategory.nasi,
      imageUrl: 'assets/images/homepage/paket3.png',
    ),
  ),
  BannerItem(
    image: 'assets/images/homepage/paket4.png',
    product: MenuModel(
      id: 'banner_4',
      name: "Paket 4",
      description:
          'YANG KAMU DAPATKAN:\nNasi, Ayam Serundeng, Telur Dadar, Sambel Goreng Kentang.',
      price: 30000,
      category: MenuCategory.nasi,
      imageUrl: 'assets/images/homepage/paket4.png',
    ),
  ),
];