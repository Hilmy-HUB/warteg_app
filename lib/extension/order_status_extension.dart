import 'package:warteg_app/model/order_status_model.dart';

extension OrderStatusX on OrderStatusModel {
  String get label {
    switch (this) {
      case OrderStatusModel.bayar:
        return "Bayar";
      case OrderStatusModel.diproses:
        return "Diproses";
      case OrderStatusModel.dijemput:
        return "Dijemput";
      case OrderStatusModel.diantar:
        return "Diantar";
      case OrderStatusModel.selesai:
        return "Selesai";
    }
  }
}