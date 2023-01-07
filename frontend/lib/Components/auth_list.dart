import 'package:authonia/APIs/get_auth_data.dart';
import 'package:authonia/Components/auth_card.dart';
import 'package:authonia/Components/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:authonia/Models/auth_data.dart';

class AuthScreen extends StatefulWidget {
  final List<AuthData> authData;

  const AuthScreen({super.key, required this.authData});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  refresh() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username')!;
    final password = prefs.getString('password')!;
    getAuthData(username, password).then((value) {
      if (value['error'] == 'false') {
        final authData = parseAuthData(value['content']!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AuthScreen(authData: authData),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed!'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
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
        title: const Text('Auth Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refresh,
          ),
          // logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.authData.length,
        itemBuilder: (context, index) {
          final data = widget.authData[index];
          return AuthCard(authData: data);
        },
      ),
    );
  }
}
