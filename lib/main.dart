import 'package:flutter/material.dart';
import 'ProductList.dart';
import 'AddProduct/ProductForm.dart';
import 'LoginScreen.dart';
import 'UpdatedProductForm.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WooSeller',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/homepage': (context) => const MyHomePage(),
        '/addproduct': (context) => const ProductForm(),
        '/updateproduct': (context) => const UpdatedProductForm()
      },
    );
  }
}
