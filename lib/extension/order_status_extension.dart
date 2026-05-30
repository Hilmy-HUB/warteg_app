import 'package:warteg_app/model/order_status_model.dart';
 
extension OrderStatusExtension on OrderStatusModel {
  String get label {
    switch (this) {
      case OrderStatusModel.bayar:
        return 'Bayar';
      case OrderStatusModel.tungguKonfirmasi:
        return 'Tunggu Konfirmasi';
      case OrderStatusModel.diproses:
        return 'Diproses';
      case OrderStatusModel.diantar:
        return 'Diantar';
      case OrderStatusModel.selesai:
        return 'Selesai';
      case OrderStatusModel.dibatalkan:
        return 'Dibatalkan';
    }
  }
}
 