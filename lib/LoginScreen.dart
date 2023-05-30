import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'ProductList.dart';

String? globalToken;

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController emailLogin = TextEditingController();
  TextEditingController passwordLogin = TextEditingController();
  bool obscurePassword = true;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoggedIn = false;

  Future<String?> authenticateUser(String username, String password) async {
    try {
      final dio = Dio();

      final url = 'https://gsolutionapp.com/wp-json/jwt-auth/v1/token';
      final data = {'username': username, 'password': password};

      final response = await dio.post(url, data: data);

      if (response.statusCode == 200) {
        final token = response.data['token'];
        print("Authentication successful. Token: $token");
        return token;
      } else {
        print("Authentication failed. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print('Authentication Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(
            240, 240, 240, 1), // Set your desired background color here
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Login",
                style: TextStyle(
                  color: Color.fromRGBO(49, 39, 79, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 50),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailLogin,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Username/Email',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            labelStyle: const TextStyle(
                              color: Color.fromRGBO(49, 39, 79, 1),
                            ), //
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a valid username/email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: passwordLogin,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                            labelStyle: const TextStyle(
                              color: Color.fromRGBO(49, 39, 79, 1),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: obscurePassword
                                    ? const Color.fromRGBO(49, 39, 79, 1)
                                    : const Color.fromRGBO(49, 39, 79,
                                        1), // Set the desired color here
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a valid password';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  primary: Color.fromRGBO(49, 39, 79, 1),
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    String usernameEmail = emailLogin.text.trim();
                    String password = passwordLogin.text.trim();
                    String? tokengenerated =
                        await authenticateUser(usernameEmail, password);

                    if (tokengenerated != null) {
                      globalToken = tokengenerated;
                      setState(() {
                        isLoggedIn = true;
                      });

                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const MyHomePage(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var begin = const Offset(0.0, 1.0);
                            var end = Offset.zero;
                            var curve = Curves
                                .easeOutQuart; // Adjust the curve for smoother animation

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    } else {
                      setState(() {
                        isLoggedIn = false;
                      });
                      // print("token is null ");
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Login Failed'),
                            content:
                                const Text('Invalid username or password.'),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color.fromRGBO(49, 39, 79, 1),
                                ),
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
