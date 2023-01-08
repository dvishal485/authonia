import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:authonia/Models/auth_data.dart';

Future<Map<String, String>> getAuthData(
    String username, String password) async {
  const uri = String.fromEnvironment('API_URL',
      defaultValue: "https://s8a7ie.deta.dev");
  final url = Uri.parse('$uri/get_entries');
  final response = await http.post(url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'password': password,
      }));

  if (response.statusCode == 200) {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('password', password);
    prefs.setString('authdata', response.body);
    prefs.setBool('hasLoggedIn', true);
    return {'error': 'false', 'content': response.body};
  }
  String message;
  try {
    message = jsonDecode(response.body)['detail'];
  } catch (e) {
    message = response.body;
  }
  return {'error': 'true', 'content': message};
}

List<AuthData> parseAuthData(String jsonString) {
  final jsonData = jsonDecode(jsonString);
  return List<AuthData>.from(jsonData.map((x) => AuthData.fromJson(x)));
}
