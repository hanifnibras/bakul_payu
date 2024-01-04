import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SellerSidePage extends StatefulWidget {
  const SellerSidePage({super.key});

  @override
  _SellerSidePageState createState() => _SellerSidePageState();
}

class _SellerSidePageState extends State<SellerSidePage> {
  ListingManager listingManager = ListingManager();
  OrderManager orderManager = OrderManager();
  OrderHistoryManager orderHistoryManager = OrderHistoryManager();
  ShopSettingsManager shopSettingsManager = ShopSettingsManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bakul Payu'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Atur Penjualan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listingManager.listings.length,
              itemBuilder: (context, index) {
                String item = listingManager.listings[index];
                return ListTile(
                  title: Text(item),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      listingManager.removeItem(item);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Riwayat Penjualan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              orderManager.placeOrder();
              orderHistoryManager.addToOrderHistory(orderManager.currentOrder);
              orderManager.clearCart();
            },
            child: Text('Lihat Riwayat Penjualan'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Riwayat Penjualan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orderHistoryManager.orderHistory.length,
              itemBuilder: (context, index) {
                Order order = orderHistoryManager.orderHistory[index];
                return ListTile(
                  title: Text('Order ${index + 1}'),
                  subtitle: Text(
                      'Items: ${order.items.length} | Date: ${order.dateTime}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Pengaturan Toko',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              PickedFile? image = await shopSettingsManager.pickImage();
              if (image != null) {
                shopSettingsManager.uploadImage(image);
              }
            },
            child: Text('Unggah Foto QR Rekening'),
          ),
          shopSettingsManager.paymentQRImage != null
              ? Image.network(shopSettingsManager.paymentQRImage!)
              : SizedBox.shrink(),
          ElevatedButton(
            onPressed: () {
              shopSettingsManager.editShopInformation();
            },
            child: Text('Atur Informasi Tentang Toko'),
          ),
        ],
      ),
    );
  }
}

class ListingManager {
  List<String> listings = [];

  void addItem(String item) {
    listings.add(item);
  }

  void removeItem(String item) {
    listings.remove(item);
  }
}

class OrderManager {
  List<String> cart = [];
  Order currentOrder = Order();

  void addToCart(String item) {
    cart.add(item);
  }

  void placeOrder() {
    currentOrder.items = List.from(cart);
    currentOrder.dateTime = DateTime.now();
  }

  void clearCart() {
    cart.clear();
  }
}

class OrderHistoryManager {
  List<Order> orderHistory = [];

  void addToOrderHistory(Order order) {
    orderHistory.add(order);
  }
}

class Order {
  List<String> items = [];
  DateTime dateTime;

  Order() : dateTime = DateTime.now();
}

class ShopSettingsManager {
  String? paymentQRImage;

  Future<PickedFile?> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    return await _picker.getImage(source: ImageSource.gallery);
  }

  void uploadImage(PickedFile image) {
    paymentQRImage = 'https://example.com/path/to/uploaded/image.jpg';
  }

  void editShopInformation() {
    print('Editing shop information.');
  }
}

class Item {
  final String name;
  final double price;

  Item({required this.name, required this.price});
}
