import 'package:flutter/material.dart';
//a set of tools for encoding and decoding data between different formats

//upload image to wordpresss and get link
import 'ProductFormState.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  runApp(const addProductFormPage());
}

class addProductFormPage extends StatelessWidget {
  const addProductFormPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'My App',
      home: ProductForm(),
    );
  }
}

class ProductForm extends StatefulWidget {
  const ProductForm({Key? key}) : super(key: key);

  @override
  ProductFormState createState() => ProductFormState();
}
