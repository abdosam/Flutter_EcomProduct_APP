import 'package:flutter/material.dart';
import 'package:WooSeller/LoginScreen.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({Key? key}) : super(key: key);

  @override
  ProductFormState createState() => ProductFormState();
}

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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getAllCategories();
  }

  //handling product creation
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
          createProductAndShowDialog(true);
        } else {
          createProductAndShowDialog(false);
        }
      } catch (e) {
        if (e is DioError) {
          if (e.response != null) {
          } else {}
        } else {}
      }
    }
  }

  void createProductAndShowDialog(bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  isSuccess ? 'Success' : 'Error',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSuccess
                      ? 'Product added successfully.'
                      : 'Failed to add the product.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromRGBO(49, 39, 79, 1)),
                    foregroundColor:
                        MaterialStateProperty.all(Colors.purple[100]),
                  ),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        //print('Error retrieving categories: $e');
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
          //print('Image uploaded successfully. URL: $imageUrl');
        } else {
          //  print('Image upload failed. Status code: ${response.statusCode}');
        }
      } catch (e) {
        // print('Error uploading image: $e');
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
        body: Container(
            color: const Color.fromRGBO(240, 240, 240, 1),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'Add Product',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(49, 39, 79, 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: productNameController,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[400]!,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: descriptionController,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[400]!,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Price',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[400]!,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: shortDescriptionController,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Short Description',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[400]!,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    InkWell(
                      onTap: selectImageFromGallery,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[300],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.image, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Choose Image',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      height: 140,
                      width: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[300],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: buildCheckboxList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    Center(
                      child: ElevatedButton(
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
                          String shortDescription =
                              shortDescriptionController.text;

                          List<int> selectedIds = selectedCategoryIds.toList();
                          //  print('Selected Category IDs: $selectedIds');
                          addProduct(productName, description, price,
                              shortDescription, selectedIds, imageUrl);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(49, 39, 79, 1),
                          onPrimary: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 24.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 2.0,
                        ),
                        child: const Text(
                          'Add Product',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
