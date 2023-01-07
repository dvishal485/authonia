import 'dart:async';

import 'package:authonia/APIs/get_auth_data.dart';
import 'package:authonia/Screens/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../APIs/otp.dart';
import '../Models/auth_data.dart';

class AuthScreen extends StatefulWidget {
  final List<AuthData> authData;

  const AuthScreen({super.key, required this.authData});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 15),
      (timer) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  refresh() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('email')!;
    final password = prefs.getString('password')!;
    getAuthData(username, password).then((value) {
      if (value) {
        final authData = parseAuthData(prefs.getString('authdata')!);
        setState(() {
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
          var code = OTP.generateTOTPCode(
              data.secret, DateTime.now().millisecondsSinceEpoch);
          return ListTile(
            title: Text(data.issuer),
            subtitle: Text(data.user),
            trailing: Text("$code".padLeft(6, '0')),
          );
        },
      ),
    );
  }
}
