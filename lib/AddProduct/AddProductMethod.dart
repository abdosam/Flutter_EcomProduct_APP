import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void addProduct(String productName, String description, String price,
    String shortDescription, List<int> selectedIds, String? image) async {
  Dio dio = Dio();

  //shows detail eroor
  // dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  /*  await dotenv.load();
  final key = dotenv.env['KEY']!;
  print(
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$key'); */

  final key =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2dzb2x1dGlvbmFwcC5jb20iLCJpYXQiOjE2ODQyMzY2MDIsIm5iZiI6MTY4NDIzNjYwMiwiZXhwIjoxNjg0ODQxNDAyLCJkYXRhIjp7InVzZXIiOnsiaWQiOiIxIn19fQ.NzF7ywC7ZdSZI4V2Bx7cV-UmsWKHbyb0npiMhylKW8Y';

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
          'Authorization': 'Bearer $key',
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
