import 'package:flutter/material.dart';

import '../Models/auth_data.dart';

class AuthScreen extends StatelessWidget {
  final List<AuthData> authData;

  const AuthScreen({super.key, required this.authData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Data'),
      ),
      body: ListView.builder(
        itemCount: authData.length,
        itemBuilder: (context, index) {
          final data = authData[index];
          const code = 123456;
          return ListTile(
            title: Text(data.issuer),
            subtitle: Text(data.user),
            trailing: const Text("$code"),
          );
        },
      ),
    );
  }
}
