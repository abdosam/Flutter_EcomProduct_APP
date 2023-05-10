import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'product_details.dart';

import 'AddProductFormPage.dart';

Future<List<dynamic>> fetchProducts() async {
  Dio dio =
      Dio(BaseOptions(baseUrl: 'https://gsolutionapp.com/wp-json/wc/v3/'));

  final key = 'ck_11ec393087f1614d8084e166f4f08d0873b52fb4';
  final password = 'cs_f4bbdffae5fa55ef2b0e88a5773f092f74ace2ce';
  dio.options.headers['Authorization'] =
      'Basic ' + base64Encode(utf8.encode('$key:$password'));
  Response response = await dio.get('products');
  // print(response.statusCode);
  // print(response.data);
  return response.data;
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      //home: MyHomePage(),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/addproduct': (context) => AddProductFormPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
      ),
      body: ProductListWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addproduct');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ProductListWidget extends StatefulWidget {
  @override
  _ProductListWidgetState createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts().then((products) {
      setState(() {
        _products = products;
        // print(_products);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(_products[index]['name']),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Html(
                  data: _products[index]['description'],
                ),
              ),
              Text(
                _products[index]['price'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailsPage(product: _products[index]),
              ),
            );
          },
        );
      },
    );
  }
}
