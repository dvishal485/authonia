import 'package:authonia/APIs/add_entry.dart';
import 'package:authonia/APIs/otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> addManually(BuildContext context,
    {String? defIssuer, String? defUser, String? defSecret}) async {
  final issuer = TextEditingController(text: defIssuer);
  final user = TextEditingController(text: defUser);
  final secret = TextEditingController(text: defSecret);
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
                  try {
                    OTP.generateTOTPCode(
                        value, DateTime.now().millisecondsSinceEpoch);
                  } catch (e) {
                    return (e.toString());
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close')),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final String issuerName = issuer.text;
                final String userName = user.text;
                final String secretValue = secret.text;
                handleAddAuth(context, issuerName, userName, secretValue);
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
