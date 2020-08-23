import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String authToken;
  final String userId;
  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  // to Cartscreen
  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final dateTime = DateTime.now();
    final url =
        "https://shop-app2-51b5f.firebaseio.com/orders/$userId.json?auth=$authToken";
    final response = await http.post(url,
        body: json.encode({
          "amount": total,
          "dateTime": dateTime.toIso8601String(), //standard way
          "products": cartProducts
              .map((cp) => {
                    "id": cp.id,
                    "title": cp.title,
                    "quantity": cp.quantity,
                    "price": cp.price,
                  })
              .toList(),
        }));
    //cartProducts is a list ,we need to map these cart items into maps and not
    //have any objects.A function which runs on "cp" ,there we return a new map,so
    //"convert objects on cart items into maps"
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)["name"],
        amount: total,
        dateTime: DateTime.now(),
        products: cartProducts,
      ),
    );
    notifyListeners();
  }

  //to ordersScreen
  Future<void> fetchAndSetOrders() async {
    final url =
        "https://shop-app2-51b5f.firebaseio.com/orders/$userId.json?auth=$authToken";
    final response = await http.get(url);
    final List<OrderItem> loadedProducts = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    extractedData.forEach((orderId, orderData) {
      loadedProducts.insert(
        //to make the new orders come up top
        0,
        OrderItem(
            id: orderId,
            amount: orderData["amount"],
            products:
                (orderData["products"] as List<dynamic>) //as List is necessary
                    .map((item) => CartItem(
                        //we are taking in all the cartItems using map
                        id: item["id"],
                        title: item["title"],
                        quantity: item["quantity"],
                        price: item["price"]))
                    .toList(),
            dateTime: DateTime.parse(orderData["dateTime"])),
      );
    });
    _orders = loadedProducts;
    notifyListeners();
  }
}
