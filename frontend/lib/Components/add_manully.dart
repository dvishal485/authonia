import 'dart:convert';

import 'package:authonia/APIs/get_auth_data.dart';
import 'package:authonia/Components/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> addManually(BuildContext context) async {
  final issuer = TextEditingController();
  final user = TextEditingController();
  final secret = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  return showCupertinoDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (context) {
      return AlertDialog(
        title: const Text('Add New Entry'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: issuer,
                decoration:
                    const InputDecoration(labelText: 'Issuer (optional)'),
              ),
              TextFormField(
                controller: user,
                decoration: const InputDecoration(labelText: 'User (optional)'),
              ),
              TextFormField(
                controller: secret,
                decoration:
                    const InputDecoration(labelText: 'Secret (required)'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a secret';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              final String issuerName = issuer.text;
              final String userName = user.text;
              final String secretValue = secret.text;
              if (formKey.currentState!.validate()) {
                const uri = String.fromEnvironment('API_URL',
                    defaultValue: "https://s8a7ie.deta.dev");
                final url = Uri.parse('$uri/add_entry');
                final prefs = await SharedPreferences.getInstance();
                final response = await http.post(url,
                    headers: {
                      'Content-Type': 'application/json',
                    },
                    body: json.encode({
                      'username': prefs.getString('username')!,
                      'password': prefs.getString('password')!,
                      'issuer': issuerName,
                      'user': userName,
                      'secret': secretValue,
                    }));
                if (response.statusCode == 200) {
                  getAuthData(prefs.getString('username')!,
                      prefs.getString('password')!);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const LoginScreen()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Something went wrong'),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
