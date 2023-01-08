import 'package:authonia/Components/add_manully.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> addFromURI(BuildContext context) async {
  final uriHandler = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  return showCupertinoDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (context) {
      return AlertDialog(
        title: const Text('Add New Entry'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: uriHandler,
            decoration: const InputDecoration(labelText: 'otpauth URI'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the otpauth URI';
              }
              if (!value.startsWith('otpauth://totp/')) {
                return 'Please enter a valid otpauth URI';
              }
              try {
                Uri.parse(value);
              } catch (e) {
                return (e.toString());
              }
              return null;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final String authURI = uriHandler.text;
                final uri = Uri.parse(authURI);
                if (uri.scheme == 'otpauth' && uri.host == 'totp') {
                  if (kDebugMode) {
                    print(uri.path);
                    print(uri.queryParameters);
                  }
                  addManually(context,
                      defUser:
                          Uri.decodeQueryComponent(uri.path).split(':').last,
                      defIssuer: uri.queryParameters['issuer'],
                      defSecret: uri.queryParameters['secret']);
                }
                //handleAdd(context, issuerName, userName, secretValue);
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
