import 'package:flutter_riverpod/flutter_riverpod.dart';

class SaleNotifier extends StateNotifier<List<dynamic>> {
  SaleNotifier() : super([]);

  void list(List<dynamic> sale) {
    state = sale;
  }

  int getTotalProfit() {
      num profit = 0;
    for (final sale in state) {
      profit = profit + sale['margin'];
    }

    return profit.toInt();
  }
}

final saleProvider = StateNotifierProvider<SaleNotifier, List<dynamic>>((ref) {
  return SaleNotifier();
});
