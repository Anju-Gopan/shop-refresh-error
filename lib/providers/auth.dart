import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  //not final because they change after some time
  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  //for toggleFavourites and proxyprovider
  String get userId {
    return _userId;
  }

  Future<void> authenticate(
      String email, String password, String method) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$method?key=AIzaSyAWI9mhz5hARteQcQo7gmntZNsby3_I6fI";
    try {
      final response = await http.post(url,
          body: json.encode({
            "email": email,
            "password": password,
            "returnSecureToken": true,
          }));
      //Eventhough we get an error message , the error is 200 status code,
      // so we have check the message it contains
      final responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        print(json.decode(response.body));
        throw HttpException(responseData["error"]["message"]);
      }
      _userId = responseData["localId"];
      _token = responseData["idToken"];
      // we get "expires in" as string value.so we have to parse it to int
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData["expiresIn"])));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return authenticate(email, password, "signUp");
    //We use return here since authenticate will return a future which yields nothing
    //because we await in there.To have the LOADING SPINNER work correctly,we want to return th future
    //which actually does the work.Without RETURN ,we would also return a future ,but this wouldn't
    //wait for the future of authenticate to do its job
  }

  Future<void> login(String email, String password) async {
    return authenticate(email, password, "signInWithPassword");
  }

  void logout() {
    _token = null;
    _expiryDate = null;
    _userId = null;
    notifyListeners();
  }
}
