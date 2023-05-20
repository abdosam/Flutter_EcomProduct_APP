import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:test1/ProductList.dart';

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailLogin,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Username/Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a valid username/email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: passwordLogin,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
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
              SizedBox(height: 16.0),
              ElevatedButton(
                child: Text('Sign In'),
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
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    } else {
                      setState(() {
                        isLoggedIn = false;
                      });
                      print("token is null ");
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Login Failed'),
                            content: Text('Invalid username or password.'),
                            actions: [
                              ElevatedButton(
                                child: Text('OK'),
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
