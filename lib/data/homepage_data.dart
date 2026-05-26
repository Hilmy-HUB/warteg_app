import 'package:warteg_app/model/product_model.dart';

class BannerItem {
  final String image;
  final ProductModel product;

  const BannerItem({required this.image, required this.product});
}

final List<BannerItem> bannerItems = [
  BannerItem(
    image: 'assets/images/homepage/paket1.png',
    product: ProductModel(
      id: '1',
      menuName: "Paket 1",
      description:
          'YANG KAMU DAPATKAN:\nNasi, Ayam Serundeng, Sambel Goreng Kentang, Minum Es Teh Manis .',
      price: 27000,
      image: 'assets/images/homepage/paket1.png',
      category: 'recommended',
    ),
  ),
  BannerItem(
    image: 'assets/images/homepage/paket2.png',
    product: ProductModel(
      id: '2',
      menuName: "Paket 2",
      description:
          'YANG KAMU DAPATKAN:\nNasi, Telur Balado, Sambel Goreng Kentang, Minum Es Teh Manis .',
      price: 20000,
      image: 'assets/images/homepage/paket2.png',
      category: 'recommended',
    ),
  ),
  BannerItem(
    image: 'assets/images/homepage/paket3.png',
    product: ProductModel(
      id: '3',
      menuName: "Paket 3",
      description:
          'YANG KAMU DAPATKAN:\nNasi, Orek Tempe & Labu Siam, Tumis Sayur, Minum Es Teh Manis .',
      price: 23000,
      image: 'assets/images/homepage/paket3.png',
      category: 'recommended',
    ),
  ),
  BannerItem(
    image: 'assets/images/homepage/paket4.png',
    product: ProductModel(
      id: '4',
      menuName: "Paket 4",
      description:
          'YANG KAMU DAPATKAN:\nNasi, Ayam Serundeng, Telur Dadar, Sambel Goreng Kentang.',
      price: 30000,
      image: 'assets/images/homepage/paket4.png',
      category: 'recommended',
    ),
  ),
];