import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ProductDetailsPage extends StatelessWidget {
  final dynamic product;

  ProductDetailsPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product['name'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Price: ${product['price']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Html(
                  data: product['description'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
