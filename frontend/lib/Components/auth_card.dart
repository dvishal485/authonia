import 'dart:async';

import 'package:authonia/APIs/otp.dart';
import 'package:authonia/Components/login.dart';
import 'package:authonia/Models/auth_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class AuthCard extends StatefulWidget {
  final AuthData authData;
  const AuthCard({super.key, required this.authData});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
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

  void deleteEntry(AuthData authData) {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => Clipboard.setData(
        ClipboardData(text: widget.authData.secret),
      ),
      onLongPress: () {
        Share.share(
            'otpauth://totp/${widget.authData.issuer}?secret=${widget.authData.secret}&issuer=${widget.authData.issuer}');
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.authData.issuer,
                style: const TextStyle(fontSize: 20),
              ),
              GestureDetector(
                onDoubleTap: () {},
                onLongPress: () {},
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            widget.authData.user,
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            OTP.generateTOTPCode(widget.authData.secret,
                                DateTime.now().millisecondsSinceEpoch),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final resp = await widget.authData.removeEntry();
                        bool error = resp[0] as bool;
                        String message = resp[1] as String;
                        if (!error) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.content_copy),
                      onPressed: () {
                        setState(() {});
                        Clipboard.setData(
                          ClipboardData(
                              text: OTP.generateTOTPCode(widget.authData.secret,
                                  DateTime.now().millisecondsSinceEpoch)),
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
