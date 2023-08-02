import 'package:amazone_clone/common/widgets/loader.dart';
import 'package:amazone_clone/features/account/widgets/sngle_product.dart';
import 'package:amazone_clone/features/admin/services/admin_services.dart';
import 'package:amazone_clone/features/order_details/screens/order_details.dart';
import 'package:amazone_clone/models/order.dart';
import 'package:flutter/material.dart';

class OrdersScreeen extends StatefulWidget {
  const OrdersScreeen({super.key});

  @override
  State<OrdersScreeen> createState() => _OrdersScreeenState();
}

class _OrdersScreeenState extends State<OrdersScreeen> {
  List<Order>? orders;
  final AdminServices adminServices = AdminServices();
  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  void fetchOrders() async {
    orders = await adminServices.fetchAllOrders(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return orders == null
        ? const Loader()
        : GridView.builder(
            itemCount: orders!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemBuilder: (context, index) {
              final orderData = orders![index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, OrdersDetailScreen.routeName,
                      arguments: orderData);
                },
                child: SizedBox(
                  height: 140,
                  child: SignleProduct(
                    image: orderData.products[0].images[0],
                  ),
                ),
              );
            });
  }
}
