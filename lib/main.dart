import 'package:flutter/material.dart';
import 'package:test1/ProductList.dart';
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
        '/homepage': (context) => MyHomePage(),
        '/addproduct': (context) => const ProductForm(),
        '/updateproduct': (context) => UpdatedProductForm()
      },
    );
  }
}
