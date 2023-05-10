

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
//a set of tools for encoding and decoding data between different formats
import 'dart:convert';
//enable the user to select picture from their devices
//import 'package:file_picker/file_picker.dart';

//for the File error
//import 'dart:io';
//select the image from device
////import 'package:image_picker/image_picker.dart';

//Add product to woocommerce
void addProduct(String productName, String description, String price) async {
  Dio dio = Dio();

  // Set WooCommerce API credentials
  String consumerKey = 'ck_11ec393087f1614d8084e166f4f08d0873b52fb4';
  String consumerSecret = 'cs_f4bbdffae5fa55ef2b0e88a5773f092f74ace2ce';

  // Set up product data
  Map<String, dynamic> productData = {
    'name': productName,
    'type': 'simple',
    'regular_price': price,
    'description': description,
    'short_description': 'flutter product',
    'categories': [
      {'id': 9}
    ]
  };

  try {
    // Encode product data as JSON string
    String encodedData = jsonEncode(productData);

    // Make API request to create new product
    Response response =
        await dio.post('https://gsolutionapp.com/wp-json/wc/v3/products',
            data: encodedData,
            options: Options(headers: {
              'Authorization': 'Basic ' +
                  base64Encode(utf8.encode('$consumerKey:$consumerSecret')),
              'Content-Type': 'application/json'
            }));

    // Check response status and print response data
    if (response.statusCode == 201) {
      print('Product created successfully!');
      print(response.data);
    } else {
      print('Error creating product: ${response.statusCode}');
    }
  } catch (e) {
    print('Error creating product: $e');
  }
}

void main() {
  runApp(AddProductFormPage());
}

class AddProductFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: ProductForm(),
    );
  }
}

class ProductForm extends StatefulWidget {
  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final productNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  // final categoriesControler = TextEditingController();

//Picking an image
//  File? imageFile;
/*  
 Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: productNameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
              ),
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price',
              ),
            ),
            /* TextFormField(
              controller: categoriesControler,
              decoration: InputDecoration(
                labelText: 'Categories',
              ),
            ), */
            //SizedBox(height: 16.0),
            //selecting image input
            /*  ElevatedButton(
              child: Text('Pick Image'),
              onPressed: () {
                pickImage();
              }, 
            ),*/
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                String productName = productNameController.text;
                String description = descriptionController.text;
                String price = priceController.text;
                // String categories = categoriesControler.text;
                print('Product Name: $productName');
                print('Description: $description');
                print('Price: $price');
                addProduct(productName, description, price);

                // TODO: Save the product to the database or other storage
              },
            ),
          ],
        ),
      ),
    );
  }
}
