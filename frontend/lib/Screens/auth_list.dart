import 'dart:async';

import 'package:flutter/material.dart';

import '../Models/otp.dart';
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
      const Duration(seconds: 30),
      (timer) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Data'),
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
            trailing: Text("$code"),
          );
        },
      ),
    );
  }
}
