import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;

  final String authToken;
  final String userId; //pass it in proxyprovider
  //initializing items to to load the previousproducts
  Products(
    this.authToken,
    this.userId,
    this._items,
  );

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  //[] around positional arguments makes it optional
  //if its true we order it base on diff users or no filtering
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    //token sent at last
    final filterString =
        filterByUser ? "orderBy='creatorId'&equalTo='$userId'" : "";
    var url =
        "https://shop-app2-51b5f.firebaseio.com/products.json?auth=$authToken&$filterString";
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      //here map contains a nested map which we denote as DYNAMIC
      if (extractedData == null) {
        return;
      }
      url =
          "https://shop-app2-51b5f.firebaseio.com/userfavorites/$userId.json?auth=$authToken";
      //not looking for a specific prodId,but fetch all the fav info
      final favoriteResponse = await http.get(url);
      final favoriteData =
          json.decode(favoriteResponse.body); //map with userId & value
      final List<Product> _loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        _loadedProducts.add(Product(
            id: prodId,
            title: prodData["title"],
            description: prodData["description"],
            price: prodData["price"],
            // isFavorite: prodData["isFavorite"],  changed it from products.dart
            isFavorite: favoriteData == null
                ? false
                : favoriteData[prodId] ?? false, //"??" if no entry is found
            imageUrl: prodData["imageUrl"]));
      });
      _items = _loadedProducts;
      notifyListeners(); //storing to the list
    } catch (error) {
      throw error;
    }
  }

  //used in EDIT_PRODUCTS_SCREEN
  Future<void> addProduct(Product product) async {
    final url =
        "https://shop-app2-51b5f.firebaseio.com/products.json?auth=$authToken";
    try {
      final response = await http.post(
        //USING "AWAIT" CREATES A SITUATION SIMILAR TO "THEN"
        url,
        body: json.encode({
          "title": product.title,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          "creatorId": userId, //a new field is added
          // "isFavorite": product.isFavorite,  **we are setting it separately **
        }),
      ); //THIS BLOCKS GETS RUN ONLY AFTER HTTP REQUEST IS SENT(LIKE "THEN")
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)["name"], //gives same id as server
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //used in EDIT_PRODUCTS_SCREEN
  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    final url =
        "https://shop-app2-51b5f.firebaseio.com/products/$id.json?auth=$authToken";
    if (prodIndex >= 0) {
      await http.patch(url,
          body: json.encode({
            //we are not giving is isFavorite (repetition)
            "title": newProduct.title,
            "description": newProduct.description,
            "price": newProduct.price,
            "imageUrl": newProduct.imageUrl,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  //used in USER_PRODUCTS_ITEM
  //OPTIMISTIC APPROACH
  //delete doesnot detect error like get and post
  Future<void> deleteProduct(String id) async {
    final url =
        "https://shop-app2-51b5f.firebaseio.com/products/$id.json?auth=$authToken";
    final _existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var _existingProduct = _items[_existingProductIndex]; //storing a copy
    _items.removeAt(_existingProductIndex);
    notifyListeners();
    await http.delete(url).then((response) {
      if (response.statusCode >= 400) {
        _items.insert(_existingProductIndex, _existingProduct);
        notifyListeners();
        throw HttpException("An error occured");
      }
      _existingProduct = null;
      notifyListeners();
    });
  }
}
