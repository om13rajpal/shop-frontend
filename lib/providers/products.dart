import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductNotifier extends StateNotifier<List<dynamic>> {
  ProductNotifier() : super([]);

  void list(List<dynamic> products) {
    state = products;
  }

  void remove(String id) {
    state = state.where((product) => product.id != id).toList();
  }

  void clear() {
    state.clear();
  }
}

final productsProvider = StateNotifierProvider<ProductNotifier, List<dynamic>>(
  (ref) => ProductNotifier(),
);
