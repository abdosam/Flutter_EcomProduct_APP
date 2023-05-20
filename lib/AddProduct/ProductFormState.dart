import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:test1/AddProduct/ProductForm.dart';
import 'AddProductMethod.dart';
import 'package:test1/LoginScreen.dart';

class ProductFormState extends State<ProductForm> {
  final productNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final shortDescriptionController = TextEditingController();
  File? image;
  String? imageUrl;
  List<dynamic> categories = [];
  Map<String, int> categoriesIwant = {};
  Set<int> selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    getAllCategories();
  }

  Future<void> getAllCategories() async {
    if (globalToken != null) {
      try {
        Dio dio = Dio(
            BaseOptions(baseUrl: 'https://gsolutionapp.com/wp-json/wc/v3/'));

        String basicAuth = 'Bearer $globalToken';
        var headers = {'Authorization': basicAuth};
        dio.options.headers.addAll(headers);

        Response response = await dio.get('products/categories');
        if (response.statusCode == 200) {
          setState(() {
            categories = response.data;
            categoriesIwant = extractCategories(response.data);
          });
        }
      } catch (e) {
        print('Error retrieving categories: $e');
      }
    }
  }

  Map<String, int> extractCategories(List<dynamic> categories) {
    Map<String, int> extractedCategories = {};

    for (var category in categories) {
      String categoryName = category['name'];
      int categoryId = category['id'];

      extractedCategories[categoryName] = categoryId;
    }

    return extractedCategories;
  }

  //uplad image to Wordpress to get url for dio
  Future<String?> uploadImageToWordpress(File image) async {
    if (globalToken != null) {
      Dio dio = Dio();
      dio.interceptors
          .add(LogInterceptor(requestBody: true, responseBody: true));

      String imageUrl = '';

      try {
        String url = 'https://gsolutionapp.com/wp-json/wp/v2/media';

        List<int> imageBytes = await image.readAsBytes();

        FormData formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(imageBytes, filename: 'image.jpg'),
        });

        Response response = await dio.post(
          url,
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $globalToken',
            },
          ),
        );

        if (response.statusCode == 201) {
          imageUrl = response.data['source_url'];
          print('Image uploaded successfully. URL: $imageUrl');
        } else {
          print('Image upload failed. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading image: $e');
      }

      return imageUrl;
    }
  }

  List<Widget> buildCheckboxList() {
    List<Widget> checkboxes = [];
    for (String categoryName in categoriesIwant.keys) {
      int categoryId = categoriesIwant[categoryName]!;

      checkboxes.add(
        CheckboxListTile(
          title: Text(categoryName),
          value: selectedCategoryIds.contains(categoryId),
          onChanged: (value) {
            setState(() {
              if (value!) {
                selectedCategoryIds.add(categoryId);
              } else {
                selectedCategoryIds.remove(categoryId);
              }
            });
          },
        ),
      );
    }
    return checkboxes;
  }

  Future<void> selectImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: productNameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
              ),
            ),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
              ),
            ),
            TextFormField(
              controller: shortDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Short Description',
              ),
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: selectImageFromGallery,
              child: const Text('Choose Image'),
            ),
            const SizedBox(height: 16.0),
            Container(
              height: 140,
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: buildCheckboxList(),
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () async {
                if (image != null) {
                  String? imageUrlRecieved =
                      await uploadImageToWordpress(image!);
                  setState(() {
                    imageUrl = imageUrlRecieved;
                  });
                }

                String productName = productNameController.text;
                String description = descriptionController.text;
                String price = priceController.text;
                String shortDescription = shortDescriptionController.text;

                List<int> selectedIds = selectedCategoryIds.toList();
                print('Selected Category IDs: $selectedIds');
                addProduct(productName, description, price, shortDescription,
                    selectedIds, imageUrl);
              },
            ),
          ],
        ),
      ),
    );
  }
}
