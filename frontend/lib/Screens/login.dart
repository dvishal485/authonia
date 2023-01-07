import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/auth_data.dart';
import 'auth_list.dart';

List<AuthData> parseAuthData(String jsonString) {
  final jsonData = jsonDecode(jsonString);
  if (kDebugMode) {
    print(jsonData);
  }
  return List<AuthData>.from(jsonData.map((x) => AuthData.fromJson(x)));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";

  Future<void> _login() async {
    const uri = String.fromEnvironment('API_URL',
        defaultValue: "https://s8a7ie.deta.dev");
    final url = Uri.parse('$uri/get_entries');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': _email,
          'password': _password,
        }));
    if (kDebugMode) {
      print(response.statusCode);
    }

    if (response.statusCode == 200) {
      final authData = parseAuthData(response.body);
      if (kDebugMode) {
        print(authData[0].issuer);
      }
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthScreen(authData: authData),
        ),
      );
    } else {
      // Login failed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
              onSaved: (value) => _email = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              onSaved: (value) => _password = value!,
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _login();
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
