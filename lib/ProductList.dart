import 'package:WooSeller/AddProduct/ProductForm.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'product_details.dart';
import 'LoginScreen.dart';
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
      body: const ProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 490),
              pageBuilder: (context, animation, secondaryAnimation) {
                return ProductForm();
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          );
        },
        backgroundColor: Colors.purple,
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
        updateProductList();
      } catch (error) {
        print('Failed to delete product: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(35),
            child: Text(
              'All Products',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.purple,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                updateProductList();
              },
              child: Container(
                color: Colors
                    .grey[200], // Set the background color for the whole list
                child: ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (BuildContext context, int index) {
                    List<dynamic>? images = _products[index]['images'];
                    String imageUrl =
                        'http://gsolutionapp.com/wp-content/uploads/woocommerce-placeholder.png';
                    if (images != null && images.isNotEmpty) {
                      imageUrl = images[0]['src'];
                    }
                    print('Image URL: $imageUrl');

                    return Padding(
                      padding: EdgeInsets.all(20),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 9.0),
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 135, 116, 116)
                                  .withOpacity(0.3),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                imageUrl,
                                width: 80,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            _products[index]['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              fontFamily: 'Lato',
                              color: Colors.black,
                              shadows: [
                                Shadow(
                                  color: Color.fromRGBO(240, 240, 240, 1)
                                      .withOpacity(0.3),
                                  offset: Offset(2, 2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '\$${_products[index]['price']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          contentPadding: EdgeInsets.all(0),
                          horizontalTitleGap: 8.0,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsPage(
                                    product: _products[index]),
                              ),
                            );
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor:
                                      Color.fromRGBO(240, 240, 240, 1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          title: Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          onTap: () {
                                            int productId =
                                                _products[index]['id'];
                                            print("in design: $productId");
                                            deleteProduct(productId);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        ListTile(
                                          leading: Icon(
                                            Icons.edit,
                                            color:
                                                Color.fromRGBO(49, 39, 79, 1),
                                          ),
                                          title: Text(
                                            'Update',
                                            style: TextStyle(
                                              color:
                                                  Color.fromRGBO(49, 39, 79, 1),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration:
                                                    Duration(milliseconds: 500),
                                                pageBuilder: (context,
                                                    animation,
                                                    secondaryAnimation) {
                                                  return UpdatedProductForm(
                                                      product:
                                                          _products[index]);
                                                },
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  return SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: const Offset(0, 1),
                                                      end: Offset.zero,
                                                    ).animate(animation),
                                                    child: child,
                                                  );
                                                },
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
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
