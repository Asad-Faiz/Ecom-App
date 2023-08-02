// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:amazone_clone/common/widgets/custom_button.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:amazone_clone/common/widgets/custom_button.dart';
import 'package:amazone_clone/common/widgets/custom_textfield.dart';
import 'package:amazone_clone/constants/utills.dart';
import 'package:amazone_clone/features/address/services/adress_services.dart';
import 'package:amazone_clone/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../constants/global-variables.dart';

class AddressScreen extends StatefulWidget {
  static const String routeName = '/address';
  final String totalAmount;

  const AddressScreen({
    Key? key,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<AddressScreen> createState() => _AdressScreenState();
}

class _AdressScreenState extends State<AddressScreen> {
  final TextEditingController flatBuildingController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final _addressFormKey = GlobalKey<FormState>();
  String addressToBeUsed = '';
  List<PaymentItem> paymentItems = []; //for Gpay
  final AddressServices addressServices = AddressServices();
  String paymentMethod = '';
  Map<String, dynamic>? paymentIntent; // for stripe paymeny

  @override
  void initState() {
    super.initState();
    paymentItems.add(
      PaymentItem(
          amount: widget.totalAmount,
          label: 'Total Amount',
          status: PaymentItemStatus.final_price),
    );
  }

  @override
  void dispose() {
    super.dispose();
    flatBuildingController.dispose();
    areaController.dispose();
    pincodeController.dispose();
    cityController.dispose();
  }

  void onGooglePayResult(res) {
    if (Provider.of<UserProvider>(context, listen: false)
        .user
        .address
        .isEmpty) {
      addressServices.saveUserAddress(
          context: context, address: addressToBeUsed);
    }
    addressServices.placeOrder(
      paymentMethod: paymentMethod,
      context: context,
      address: addressToBeUsed,
      totalSum: double.parse(widget.totalAmount),
    );
  }

  void payPressed(String addressFromProvider, String paymentMethod) {
    addressToBeUsed = '';
    bool isFrom = flatBuildingController.text.isNotEmpty ||
        areaController.text.isNotEmpty ||
        pincodeController.text.isNotEmpty ||
        cityController.text.isNotEmpty;

    if (isFrom) {
      if (_addressFormKey.currentState!.validate()) {
        addressToBeUsed =
            '${flatBuildingController.text}, ${areaController.text}, ${cityController.text} - ${pincodeController.text}';
      } else {
        throw Exception("Please Enter All fields");
      }
    } else if (addressFromProvider.isNotEmpty) {
      addressToBeUsed = addressFromProvider;
    } else {
      showSnackBar(context, "Error!");
    }
  }
// cashon delievery

  void cashOnDelievery(String addressFromProvider, String paymentMethod) {
    setState(() {
      paymentMethod = 'cash on delievery';
    });
    addressToBeUsed = '';
    bool isFrom = flatBuildingController.text.isNotEmpty ||
        areaController.text.isNotEmpty ||
        pincodeController.text.isNotEmpty ||
        cityController.text.isNotEmpty;

    if (isFrom) {
      if (_addressFormKey.currentState!.validate()) {
        addressToBeUsed =
            '${flatBuildingController.text}, ${areaController.text}, ${cityController.text} - ${pincodeController.text}';
      } else {
        throw Exception("Please Enter All fields");
      }
    } else if (addressFromProvider.isNotEmpty) {
      addressToBeUsed = addressFromProvider;
      // log(addressToBeUsed);
    } else {
      showSnackBar(context, "Error!");
    }
    if (Provider.of<UserProvider>(context, listen: false)
        .user
        .address
        .isEmpty) {
      addressServices.saveUserAddress(
          context: context, address: addressToBeUsed);
    }
    log(paymentMethod);
    addressServices.placeOrder(
      paymentMethod: paymentMethod,
      context: context,
      address: addressToBeUsed,
      totalSum: double.parse(widget.totalAmount),
    );
  }

  // pay with PayPal
  // void payWithPaypal() {}
  // Stripe payment methods
  Future<void> makePayment(
      String addressFromProvider, String paymentMethod) async {
    setState(() {
      paymentMethod = 'Stripe Pay';
    });
    addressToBeUsed = '';
    bool isFrom = flatBuildingController.text.isNotEmpty ||
        areaController.text.isNotEmpty ||
        pincodeController.text.isNotEmpty ||
        cityController.text.isNotEmpty;

    if (isFrom) {
      if (_addressFormKey.currentState!.validate()) {
        addressToBeUsed =
            '${flatBuildingController.text}, ${areaController.text}, ${cityController.text} - ${pincodeController.text}';
      } else {
        throw Exception("Please Enter All fields");
      }
    } else if (addressFromProvider.isNotEmpty) {
      addressToBeUsed = addressFromProvider;
      // log(addressToBeUsed);
    } else {
      showSnackBar(context, "Error!");
    }
    try {
      paymentIntent = await createPaymentIntent('${widget.totalAmount}', 'USD');
      //Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
                  // googlePay: const PaymentSheetGooglePay(testEnv: true, currencyCode: "US", merchantCountryCode: "+92"),
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Asad'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet();
      if (Provider.of<UserProvider>(context, listen: false)
          .user
          .address
          .isEmpty) {
        addressServices.saveUserAddress(
            context: context, address: addressToBeUsed);
      }
      log(paymentMethod);
      addressServices.placeOrder(
        paymentMethod: paymentMethod,
        context: context,
        address: addressToBeUsed,
        totalSum: double.parse(widget.totalAmount),
      );
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  // createPaymentIndent     Strip payment Button
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51NU5DSJlz3vuQc0CsZEzZZ1XY0ENFkJJ8vIGawR9bsOwOdCJW5fP3alhtZq2DCteTURy0t5AYuziAuxbxJegt6Ti00Ns5JrglM',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      // print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  // CalculateAmmount
  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }

// Display Sheet
  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        // showDialog(
        //     context: context,
        //     builder: (_) => AlertDialog(
        //           content: Column(
        //             mainAxisSize: MainAxisSize.min,
        //             children: [
        //               Row(
        //                 children: const [
        //                   Icon(
        //                     Icons.check_circle,
        //                     color: Colors.green,
        //                   ),
        //                   Text("Payment Successfull"),
        //                 ],
        //               ),
        //             ],
        //           ),
        //         ));
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));
        print('done');
        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  // SCaffold wal function
  Widget build(BuildContext context) {
    // getting user address
    var address = context.watch<UserProvider>().user.address;
    // var address = "house 78b street 3b 199rb";
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: GlobalVariables.appBarGradient),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (address.isNotEmpty)
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black12,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          address,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'OR',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              Form(
                key: _addressFormKey,
                child: Column(
                  children: [
                    CustomTextFields(
                      controller: flatBuildingController,
                      hintText: 'Flat, House No, Building',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextFields(
                      controller: areaController,
                      hintText: 'Area, Street ',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextFields(
                      controller: pincodeController,
                      hintText: 'PinCode',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextFields(
                      controller: cityController,
                      hintText: 'Town/City',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GooglePayButton(
                onPressed: () => payPressed(address, paymentMethod),
                onPaymentResult: onGooglePayResult,
                paymentItems: paymentItems,
                paymentConfigurationAsset: 'gpay.json',
                height: 50,
                width: double.infinity,
                type: GooglePayButtonType.buy,
                margin: const EdgeInsets.only(top: 15),
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              // cash on delievery
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(top: 18),
                child: CustomButton(
                  text: "Cash on Delievery",
                  onTap: () {
                    cashOnDelievery(address, paymentMethod);
                  },
                ),
              ),
              // Stripe button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(top: 18),
                child: CustomButton(
                  text: "Pay using Stripe",
                  onTap: () {
                    makePayment(address, paymentMethod);
                  },
                ),
              ),
              // paypal
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   margin: const EdgeInsets.only(top: 18),
              //   child: CustomButton(
              //     text: "Pay with PayPal",
              //     onTap: () {
              //       payWithPaypal();
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
