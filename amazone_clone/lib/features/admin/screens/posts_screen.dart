// import 'dart:developer';

import 'package:amazone_clone/features/account/widgets/sngle_product.dart';
import 'package:amazone_clone/features/admin/screens/add_products_Screen.dart';
// import 'package:amazone_clone/features/admin/screens/admin_screen.dart';
import 'package:amazone_clone/features/admin/services/admin_services.dart';
import 'package:amazone_clone/models/product.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/loader.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<Product>? products;
  final AdminServices adminServices = AdminServices();
  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  fetchAllProducts() async {
    products = await adminServices.fetchAllProducts(context);
    setState(() {});
  }

  void navigateToAddProduct() {
    Navigator.pushNamed(context, AddProductScreen.routeName);
  }

  void deleteProduct(Product product, int index) {
    adminServices.deleteProduct(
      context: context,
      product: product,
      onSucces: () {
        products!.removeAt(index);
        setState(() {});
      },
    );
  }

  // edit Data
  editData(Product productData) {
    Navigator.pushNamed(context, AddProductScreen.routeName,
        arguments: productData);
  }

  @override
  Widget build(BuildContext context) {
    return products == null
        ? const Loader()
        : Scaffold(
            body: GridView.builder(
                itemCount: products!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.7),
                itemBuilder: (context, index) {
                  final productData = products![index];
                  // log(productData.toString());
                  return Column(
                    children: [
                      SizedBox(
                        height: 140,
                        child: SignleProduct(
                          image: productData.images[1],
                        ),
                      ),

                      //
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Text(
                              productData.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),

                          // icon button
                          IconButton(
                            onPressed: () {
                              editData(productData);
                            },
                            // deleteProduct(productData, index),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () => deleteProduct(productData, index),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      )
                    ],
                  );
                }),

            // floating  Button
            floatingActionButton: FloatingActionButton(
              onPressed: navigateToAddProduct,
              tooltip: "Add a product",
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }
}
