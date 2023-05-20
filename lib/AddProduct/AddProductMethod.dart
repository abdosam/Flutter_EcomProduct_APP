import 'package:flutter/material.dart';
import 'package:test1/LoginScreen.dart';
import 'package:dio/dio.dart';

void addProduct(String productName, String description, String price,
    String shortDescription, List<int> selectedIds, String? image) async {
  if (globalToken != null) {
    Dio dio = Dio();

    List<Map<String, dynamic>> categoryList = [];
    for (int categoryId in selectedIds) {
      categoryList.add({'id': categoryId});
    }
    List<Map<String, dynamic>> imageList = [];
    imageList.add({
      'src': image,
    });

    FormData formData = FormData.fromMap({
      'name': productName,
      'type': 'simple',
      'regular_price': price,
      'description': description,
      'short_description': shortDescription,
      'categories': categoryList,
      'images': imageList,
    });
    try {
      Response response = await dio.post(
          'https://gsolutionapp.com/wp-json/wc/v3/products',
          data: formData,
          options: Options(headers: {
            'Authorization': 'Bearer $globalToken',
            'Content-Type': 'application/json'
          }));

      if (response.statusCode == 201) {
        print("Product created successfuly ");
      } else {
        print('Error creating product: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioError) {
        if (e.response != null) {
          print('DioError: ${e.response!.statusCode}');
        } else {
          print('DioError: $e');
        }
      } else {
        print('Exception: $e');
      }
    }
  }
}
