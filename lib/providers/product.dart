import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  //to avoid code duplication
  void setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  //we are sending token along with this to product_item.dart
  // **Storing favourite data into another path
  Future<void> toggleFavoriteStatus(String token, String userId) async {
    var _oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        "https://shop-app2-51b5f.firebaseio.com/userfavorites/$userId/$id.json?auth=$token";
    try {
      //we can use "put" instead of "patch" coz we need to only send true or false value
      final response = await http.put(url,
          body: json.encode(
            isFavorite,
          )); //isFavorite is a standalone value
      if (response.statusCode >= 400) {
        setFavValue(_oldStatus); //reverting
      }
    } // for any network errors
    catch (error) {
      setFavValue(_oldStatus);
    }
  }
}
