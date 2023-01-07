import 'package:authonia/APIs/get_auth_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_list.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    loading = false;
    _checkIfLoggedIn();
  }

  final _formKey = GlobalKey<FormState>();
  String _username = "";
  String _password = "";
  bool loading = true;

  Future<void> _login() async {
    // get_auth_data
    getAuthData(_username, _password).then((value) {
      if (value['error'] == 'false') {
        final authData = parseAuthData(value['content']!);
        setState(() {
          loading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuthScreen(authData: authData),
          ),
        );
      } else {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value['content']!),
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
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  readOnly: loading,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      setState(() {
                        loading = false;
                      });
                      return 'Please enter your username';
                    }
                    return null;
                  },
                  onSaved: (value) => _username = value!,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  readOnly: loading,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      setState(() {
                        loading = false;
                      });
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value!,
                  obscureText: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: !loading
                      ? ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        )
                      : ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.grey,
                        ),
                  onPressed: () {
                    if (loading) {
                      return;
                    }
                    setState(() {
                      loading = true;
                    });
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _login();
                    }
                  },
                  child: const Text('Login'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: TextButton(
                  onPressed: null,
                  child: Text(
                    "New user? Register here",
                    style: TextStyle(color: Color.fromARGB(255, 120, 120, 170)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkIfLoggedIn() {
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getBool('hasLoggedIn') ?? false) {
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
