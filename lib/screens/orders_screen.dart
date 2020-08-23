import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  // @override
  // _OrdersScreenState createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen> {
//   // var _isLoading = false;

//   @override
//   void initState() {
//     _isLoading = true; //setState not needed coz it runs first
//     Provider.of<Orders>(context, listen: false)
//         .fetchAndSetOrders()
//         .then((_) => setState(() {
//               _isLoading = false;
//             }));

//     super.initState();
//   }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context); *********
    //When it is done fetching and setting the orders,it will notify listeners,
    // since we set up a listener to orders here whole build would run again,then a
    // new future builder would run again send request again & again
    //SO USING A "CONSUMER" IS THE REMEDY
    print("looping");
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapShot.error != null) {
              return Center(
                child: Text("An error occured"),
              );
            } else {
              return Consumer<Orders>(builder: (ctx, orderData, child) {
                return ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                );
              });
            }
          }),
    );
  }
}
