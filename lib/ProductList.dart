import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'product_details.dart';
import 'package:test1/LoginScreen.dart';
import 'UpdatedProductForm.dart';

Future<List<dynamic>> fetchProducts() async {
  if (globalToken != null) {
    Dio dio =
        Dio(BaseOptions(baseUrl: 'https://gsolutionapp.com/wp-json/wc/v3/'));

    String basicAuth = 'Bearer $globalToken';
    var headers = {'Authorization': basicAuth};
    dio.options.headers.addAll(headers);
    List<dynamic> allProducts = [];
    int pageNumber = 1;
    bool hasMoreProducts = true;
    while (hasMoreProducts) {
      Response response = await dio.get('products', queryParameters: {
        'per_page': 10,
        'page': pageNumber,
      });
      List<dynamic> products = response.data;
      allProducts.addAll(products);

      if (products.length < 10) {
        hasMoreProducts = false;
      } else {
        pageNumber++;
      }
    }
    print(allProducts);
    return allProducts;
  } else {
    return [];
  }
}

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

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);
  @override
  ProductListState createState() => ProductListState();
}

class ProductListState extends State<ProductList> {
  List<dynamic> _products = [];
  @override
  void initState() {
    super.initState();
    updateProductList();
  }

  Future<void> updateProductList() async {
    List<dynamic> updatedProducts = await fetchProducts();
    setState(() {
      _products = updatedProducts;
    });
  }

  Future<void> deleteProduct(int productId) async {
    if (globalToken != null) {
      Dio dio =
          Dio(BaseOptions(baseUrl: 'https://gsolutionapp.com/wp-json/wc/v3/'));

      String basicAuth = 'Bearer $globalToken';
      var headers = {'Authorization': basicAuth};
      dio.options.headers.addAll(headers);

      try {
        Response response = await dio.delete('products/$productId');
        print('Product deleted successfully');
      } catch (error) {
        print('Failed to delete product: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        updateProductList();
      },
      child: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Image.network(
              _products[index]['images'][0]['src'],
              width: 50,
              height: 50,
            ),
            title: Text(_products[index]['name']),
            subtitle: Text(
              _products[index]['price'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
            onLongPress: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Product Actions'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.delete),
                            title: const Text('Delete'),
                            onTap: () {
                              int productId = _products[index]['id'];
                              print("in design : $productId");
                              deleteProduct(productId);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text('Update'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdatedProductForm(
                                    product: _products[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
