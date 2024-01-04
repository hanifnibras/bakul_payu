class CartItem {
  final String productImgUrl;
  final String productTitle;
  final int productPrice;
  int quantity;

  CartItem({
    required this.productImgUrl,
    required this.productTitle,
    required this.productPrice,
    this.quantity = 1,
  });
}
