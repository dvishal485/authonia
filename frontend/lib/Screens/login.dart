import 'package:authonia/APIs/get_auth_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_list.dart';

const _kHasLoggedIn = 'hasLoggedIn';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";

  Future<void> _login() async {
    // get_auth_data
    getAuthData(_email, _password).then((value) {
      if (value) {
        final prefs = SharedPreferences.getInstance();
        prefs.then((value) {
          final authData = parseAuthData(value.getString('authdata')!);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AuthScreen(authData: authData),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
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
      ),
    );
  }

  void _checkIfLoggedIn() {
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool(_kHasLoggedIn) ?? false) {
        final authData = parseAuthData(prefs.getString('authdata')!);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AuthScreen(authData: authData),
          ),
        );
      }
    });
  }
}
