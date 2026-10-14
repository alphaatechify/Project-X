class CartItem {
  final String id;
  final String title;
  final String serviceCategory;
  final double price;
  final String priceFormatted;
  final String imageUrl;
  final int quantity;

  const CartItem({
    required this.id,
    required this.title,
    required this.serviceCategory,
    required this.price,
    required this.priceFormatted,
    required this.imageUrl,
    this.quantity = 1,
  });

  CartItem copyWith({
    int? quantity,
  }) {
    return CartItem(
      id: id,
      title: title,
      serviceCategory: serviceCategory,
      price: price,
      priceFormatted: priceFormatted,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}
