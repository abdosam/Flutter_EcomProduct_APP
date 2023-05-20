import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ProductDetailsPage extends StatelessWidget {
  final dynamic product;

  ProductDetailsPage({required this.product});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product['images'][0]['src'],
              width: screenWidth,
              height: 200,
              fit: BoxFit.cover,
            ),
            Text(
              product['name'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  ' Price : ',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  ' ${product['price']}\$',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Categories:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List<Widget>.generate(
                product['categories'].length,
                (index) => Text(
                  '- ${product['categories'][index]['name']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Short Description:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Html(
              data: product['short_description'],
              style: {
                'body': Style(fontSize: FontSize(16)),
              },
            ),
            const SizedBox(height: 16),
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
