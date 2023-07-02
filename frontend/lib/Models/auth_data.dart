import 'dart:convert';

import 'package:authonia/APIs/get_auth_data.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthData {
  static const uri = String.fromEnvironment('API_URL');

  final String id;
  final String issuer;
  final String secret;
  final bool totp;
  final String user;

  AuthData({
    required this.id,
    required this.issuer,
    required this.secret,
    required this.totp,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      id: json['_id'],
      issuer: json['issuer'],
      secret: json['secret'],
      totp: json['totp'],
      user: json['user'],
    );
  }

  Future<List<Object>> removeEntry() async {
    final url = Uri.parse('$uri/remove_entry');
    final prefs = await SharedPreferences.getInstance();
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'auth_id': id,
          'username': prefs.getString('username')!,
          'password': prefs.getString('password')!,
        }));
    var jsonResp = json.decode(response.body);
    bool error = jsonResp['error'];
    String content = jsonResp['message'];

    var authData = await getAuthData(
        prefs.getString('username')!, prefs.getString('password')!);
    if (authData['error'] == 'false') {
      prefs.setString('authdata', authData['content']!);
    }
    return [error, content, authData['content']!];
  }
}
