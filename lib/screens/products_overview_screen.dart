import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import 'package:shop_app/providers/products.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = "/products-overview";
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  @override
  void initState() {
    //THIS CAN ALSO BE USED WITH LISTEN FALSE

    // Provider.of<Products>(context, listen: false).fetchAndSetProducts();

    //"FUTURE.DELAYED CAN ALSO BE USED INSTEAD OF ABOVE SYNTAX"

    // Future.delayed(Duration.zero).then((value) {
    //   Provider.of<Products>(context, listen: false).fetchAndSetProducts();});
    super.initState();
  }

  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  //didChangedependencies RUNS more often so make condition
  void didChangeDependencies() {
    if (_isInit) {
      // setState(() {
      _isLoading = true;
      // });
      // loading spinner works only if THEN is given
      Provider.of<Products>(context).fetchAndSetProducts().then(
            (_) => setState(() {
              _isLoading = false;
            }),
          );
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              //the child will not rebuild
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
