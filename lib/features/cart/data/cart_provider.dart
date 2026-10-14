import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cart_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem({
    required String id,
    required String title,
    required String serviceCategory,
    required double price,
    required String priceFormatted,
    required String imageUrl,
  }) {
    final index = state.indexWhere((item) => item.id == id || item.title == title);
    if (index >= 0) {
      final updated = List<CartItem>.from(state);
      updated[index] = updated[index].copyWith(quantity: updated[index].quantity + 1);
      state = updated;
    } else {
      state = [
        ...state,
        CartItem(
          id: id,
          title: title,
          serviceCategory: serviceCategory,
          price: price,
          priceFormatted: priceFormatted,
          imageUrl: imageUrl,
          quantity: 1,
        ),
      ];
    }
  }

  void increment(String id) {
    final index = state.indexWhere((item) => item.id == id || item.title == id);
    if (index >= 0) {
      final updated = List<CartItem>.from(state);
      updated[index] = updated[index].copyWith(quantity: updated[index].quantity + 1);
      state = updated;
    }
  }

  void decrement(String id) {
    final index = state.indexWhere((item) => item.id == id || item.title == id);
    if (index >= 0) {
      if (state[index].quantity > 1) {
        final updated = List<CartItem>.from(state);
        updated[index] = updated[index].copyWith(quantity: updated[index].quantity - 1);
        state = updated;
      } else {
        state = state.where((item) => item.id != id && item.title != id).toList();
      }
    }
  }

  int getItemQuantity(String idOrTitle) {
    final item = state.where((item) => item.id == idOrTitle || item.title == idOrTitle).firstOrNull;
    return item?.quantity ?? 0;
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id && item.title != id).toList();
  }

  void clearCart() {
    state = [];
  }

  double get subtotal => state.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  int get totalCount => state.fold(0, (sum, item) => sum + item.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});

final cartSubtotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
});
