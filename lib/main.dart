import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'product_details.dart';
import 'AddProduct/ProductForm.dart';

//get the list of products from woocommerce
Future<List<dynamic>> fetchProducts() async {
  Dio dio =
      Dio(BaseOptions(baseUrl: 'https://gsolutionapp.com/wp-json/wc/v3/'));

  final key =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2dzb2x1dGlvbmFwcC5jb20iLCJpYXQiOjE2ODQyMzY2MDIsIm5iZiI6MTY4NDIzNjYwMiwiZXhwIjoxNjg0ODQxNDAyLCJkYXRhIjp7InVzZXIiOnsiaWQiOiIxIn19fQ.NzF7ywC7ZdSZI4V2Bx7cV-UmsWKHbyb0npiMhylKW8Y';

  String basicAuth = 'Bearer $key';
  var headers = {'Authorization': basicAuth};
  dio.options.headers.addAll(headers);
  Response response = await dio.get('products');
  return response.data;
}

void main() {
  runApp(const MyApp());
}

// set the navigation structure and define the route of navigation and its the first widget
//to be display when the app start
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/addproduct': (context) => const ProductForm(),
      },
    );
  }
}

// responsible for defining the structure and behavior of app
//it set AppBar ,Body of the app and floating action button
//allow user to navigate to AddProductFormPage
class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: const ProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addproduct');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

//Statefulwidget that manage the state of list of products that will be displayed on the app home page
//create new instance of the ProductListState class to manage this state
//allow teh widgets to be rebuilt when the state change .
class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);
  @override
  ProductListState createState() => ProductListState();
}

//Manage the state of ProductList
//initState() getTheProduct(woocomerce) and
//update state of widget with setState()
class ProductListState extends State<ProductList> {
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts().then((products) {
      setState(() {
        _products = products;
        print("ok : $_products");
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
                style: const TextStyle(
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
