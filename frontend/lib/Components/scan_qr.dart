import 'dart:async';
import 'package:authonia/Components/add_manully.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({super.key});

  @override
  State<ScanQR> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanQR> {
  MobileScannerController cameraController = MobileScannerController();
  bool perms = false;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    perms = !cameraController.isStarting;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        perms = !cameraController.isStarting;
        if (perms) timer.cancel();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          actions: perms
              ? []
              : [
                  IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.refresh),
                    iconSize: 32.0,
                    onPressed: () {
                      setState(() {
                        perms = !cameraController.isStarting;
                      });
                    },
                  ),
                ],
        ),
        body: !perms
            ? const Center(
                child: Text("Please give permission to camera first!"),
              )
            : MobileScanner(
                allowDuplicates: false,
                onDetect: (barcode, args) {
                  if (barcode.rawValue != null &&
                      barcode.rawValue!.startsWith('otpauth://totp/')) {
                    final String url = barcode.rawValue!;
                    debugPrint('Barcode found! $url');
                    try {
                      final uri = Uri.parse(url);
                      if (uri.scheme == 'otpauth' && uri.host == 'totp') {
                        Navigator.pop(context);
                        addManually(context,
                            defUser: Uri.decodeQueryComponent(uri.path)
                                .split(':')
                                .last,
                            defIssuer: uri.queryParameters['issuer'],
                            defSecret: uri.queryParameters['secret']);
                      }
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  }
                }));
  }
}
