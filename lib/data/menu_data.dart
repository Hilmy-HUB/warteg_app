import 'package:warteg_app/model/menu_model.dart';

final List<MenuModel> initialMenus = [
  // ── Lauk ──────────────────────────────────────────────────────────────────
  MenuModel(
    id: '1',
    name: 'Ayam Kalio',
    description:
        'Ayam Kalio adalah hidangan ayam yang disajikan dalam kuah santan kental berbumbu rempah khas Padang.',
    price: 16000,
    category: MenuCategory.lauk,
    imageUrl: 'assets/images/product/ayamkalio.png',
  ),
  MenuModel(
    id: '2',
    name: 'Cumi Cabe Ijo',
    description:
        'Cumi segar yang ditumis dengan cabai hijau pedas, bawang, dan bumbu gurih. Rasanya pedas, gurih, dan cocok disantap dengan nasi hangat.',
    price: 15000,
    category: MenuCategory.lauk,
    imageUrl: 'assets/images/product/cumicabeijo.png',
  ),
  MenuModel(
    id: '3',
    name: 'Mujair Cabe Ijo',
    description:
        'Ikan mujair goreng yang dimasak dengan sambal cabai hijau. Rasanya pedas, gurih, dan segar.',
    price: 20000,
    category: MenuCategory.lauk,
    imageUrl: 'assets/images/product/mujaircabeijo.png',
  ),
  MenuModel(
    id: '4',
    name: 'Sop Buntut',
    description:
        'Sup berbahan buntut sapi yang dimasak lama hingga empuk, disajikan dengan kuah kaldu bening yang gurih dan sayuran.',
    price: 28000,
    category: MenuCategory.lauk,
    imageUrl: 'assets/images/product/sopbuntut.png',
  ),
  MenuModel(
    id: '6',
    name: 'Sambel Ati',
    description:
        'Sambal yang terbuat dari ati ampela, cabai, dan bumbu pilihan. Rasanya pedas dan gurih.',
    price: 10000,
    category: MenuCategory.lauk,
    imageUrl: 'assets/images/product/sambelati.png',
  ),
  MenuModel(
    id: '7',
    name: 'Telor Balado',
    description:
        'Telur rebus yang dimasak dengan sambal balado pedas. Cocok sebagai lauk pendamping nasi.',
    price: 7000,
    category: MenuCategory.lauk,
    imageUrl: 'assets/images/product/telorbalado.png',
  ),

  // ── Nasi ──────────────────────────────────────────────────────────────────
  MenuModel(
    id: '8',
    name: 'Nasi Goreng',
    description:
        'Nasi yang digoreng dengan kecap, bawang, dan cabai, sering ditambah telur atau ayam. Gurih, sedikit manis, dan aromanya khas.',
    price: 15000,
    category: MenuCategory.nasi,
    imageUrl: 'assets/images/product/nasgor.png',
  ),

  // ── Sayur ─────────────────────────────────────────────────────────────────
  MenuModel(
    id: '5',
    name: 'Tempe Orek',
    description:
        'Tempe yang ditumis dengan bumbu kecap manis, bawang, dan cabai hingga kering. Rasanya manis, gurih, dan sedikit pedas.',
    price: 9000,
    category: MenuCategory.sayur,
    imageUrl: 'assets/images/product/tempeorek.png',
  ),
  // ── Minuman ────────────────────────────────────────────────────────────────
  MenuModel(
    id: '9',
    name: 'Es Teh',
    description:
        'Minuman dingin yang terbuat dari teh manis dan es batu. Rasanya manis dan segar.',
    price: 5000,
    category: MenuCategory.minuman,
    imageUrl: 'assets/images/product/esteh.png',
  ),
  MenuModel(
    id: '10',
    name: 'Air Mineral',
    description:
        'Air mineral dalam kemasan botol, cocok untuk melepas dahaga. Rasanya segar dan netral.',
    price: 3000,
    category: MenuCategory.minuman,
    imageUrl: 'assets/images/product/air.png',
  ),
];

// Helper: filter berdasarkan kategori
List<MenuModel> menuByCategory(MenuCategory cat) =>
    initialMenus.where((m) => m.category == cat).toList();