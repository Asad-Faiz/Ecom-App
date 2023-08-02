// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:amazone_clone/features/admin/screens/notification.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

// import 'package:amazone_clone/common/widgets/custom_button.dart';
import 'package:amazone_clone/common/widgets/custom_textfield.dart';
import 'package:amazone_clone/constants/utills.dart';
import 'package:amazone_clone/features/admin/services/admin_services.dart';
// import 'package:amazone_clone/models/product.dart';

import '../../../constants/global-variables.dart';

class AddProductScreen extends StatefulWidget {
  static const String routeName = '/add-product';
  final productData;
  AddProductScreen({
    Key? key,
    this.productData,
  }) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
// notification partt

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  String category = 'Mobiles';
  List<dynamic> images = [];

  final _AddProductFormKey = GlobalKey<FormState>();
  final AdminServices adminServices = AdminServices();

  @override
  void initState() {
    super.initState();
    if (widget.productData != null) {
      setState(() {
        images = widget.productData.images;
      });
      productNameController.text = widget.productData!.name;
      descriptionController.text = widget.productData!.description;
      priceController.text = widget.productData!.price.toString();
      quantityController.text = widget.productData!.quantity.toString();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    productNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
  }

  List<String> productCategories = [
    "Mobiles",
    "Essentials",
    "Appliances",
    "Books",
    "Fashion",
  ];
  void sellProduct() {
    if (_AddProductFormKey.currentState!.validate() && images.isNotEmpty) {
      adminServices.sellProducts(
          context: context,
          name: productNameController.text,
          description: descriptionController.text,
          price: double.parse(priceController.text),
          quantity: int.parse(quantityController.text),
          category: category,
          images: images as List<File>);
    }
  }

  void selectImages() async {
    // pickImage() function is imported from utils.dart
    var res = await pickImages();
    setState(() {
      images = res;
    });
  }

  void change() {
    log("hi");
  }

  // update data
  void updateData(String id) {
    adminServices.UpdateProducts(
        context: context,
        id: widget.productData.id,
        name: productNameController.text,
        description: descriptionController.text,
        price: double.parse(priceController.text),
        quantity: int.parse(quantityController.text),
        category: category,
        images: widget.productData.images);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: GlobalVariables.appBarGradient),
          ),
          title: const Text(
            "Add Product",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _AddProductFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                images.isNotEmpty
                    ? CarouselSlider(
                        items: images.map((i) {
                          return Builder(builder: (BuildContext context) {
                            if (i is File) {
                              return Image.file(
                                i,
                                fit: BoxFit.cover,
                                height: 200,
                              );
                            } else {
                              return Image.network(
                                "${i}",
                                fit: BoxFit.cover,
                                height: 200,
                              );
                            }
                          });
                        }).toList(),
                        options:
                            CarouselOptions(viewportFraction: 1, height: 200),
                      )
                    : GestureDetector(
                        onTap: selectImages,
                        // onTap: change,
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10),
                          dashPattern: const [10, 4],
                          strokeCap: StrokeCap.round,
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.folder_open_outlined,
                                  size: 40,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Select Product Images",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey[400]),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                // dotted border end here
                const SizedBox(
                  height: 30,
                ),
                CustomTextFields(
                  controller: productNameController,
                  hintText: "Product Name",
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextFields(
                  controller: descriptionController,
                  hintText: "Description",
                  maxLines: 7,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextFields(
                  controller: priceController,
                  hintText: "Price",
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextFields(
                  controller: quantityController,
                  hintText: "Quantity",
                ),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButton(
                    value: category,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: productCategories.map((String item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (String? newVal) {
                      setState(() {
                        category = newVal!;
                      });
                    },
                  ),
                ),
                // button
                const SizedBox(
                  height: 10,
                ),

                // CustomButton(text: "Sell", onTap: sellProduct)
                ElevatedButton(
                  onPressed: () {
                    if (widget.productData != null) {
                      updateData(widget.productData.id);
                    } else {
                      sellProduct;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: GlobalVariables.secondaryColor),
                  child: Text(
                    widget.productData != null ? "Update" : "Sell",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, NotificationScreen.routeName);
                  },
                  child: const Text("go to otfication scren"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
