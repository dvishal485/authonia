import 'dart:convert';
import 'package:authonia/APIs/get_auth_data.dart';
import 'package:authonia/Components/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void handleAddAuth(BuildContext context, String issuerName, String userName,
    String secretValue) async {
  const uri = String.fromEnvironment('API_URL',
      defaultValue: "https://authonia-backend.vercel.app");
  final url = Uri.parse('$uri/add_entry');
  await SharedPreferences.getInstance().then((prefs) async => {
        await http
            .post(url,
                headers: {
                  'Content-Type': 'application/json',
                },
                body: json.encode({
                  'username': prefs.getString('username')!,
                  'password': prefs.getString('password')!,
                  'issuer': issuerName,
                  'user': userName,
                  'secret': secretValue,
                }))
            .then((response) async => {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Adding new entry...'),
                    ),
                  ),
                  if (response.statusCode == 200)
                    {
                      await getAuthData(prefs.getString('username')!,
                              prefs.getString('password')!)
                          .then((_) {
                        Navigator.popUntil(
                            context, ModalRoute.withName('AuthScreen'));
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                      })
                    }
                  else
                    {
                      Navigator.popUntil(
                          context, ModalRoute.withName('AuthScreen')),
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Something went wrong'),
                        ),
                      ),
                    },
                })
      });
}
