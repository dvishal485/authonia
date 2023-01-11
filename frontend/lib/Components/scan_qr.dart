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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          actions: [
            IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off, color: Colors.grey);
                    case TorchState.on:
                      return const Icon(Icons.flash_on, color: Colors.yellow);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () {
                cameraController.toggleTorch();
                setState(() {});
              },
            ),
          ],
        ),
        body: MobileScanner(
            allowDuplicates: false,
            onDetect: (barcode, args) {
              if (barcode.rawValue != null &&
                  barcode.rawValue!.startsWith('otpauth://totp/')) {
                final String url = barcode.rawValue!;
                debugPrint('Barcode found! $url');
                Navigator.pop(context);
                final uri = Uri.parse(url);
                if (uri.scheme == 'otpauth' && uri.host == 'totp') {
                  addManually(context,
                      defUser:
                          Uri.decodeQueryComponent(uri.path).split(':').last,
                      defIssuer: uri.queryParameters['issuer'],
                      defSecret: uri.queryParameters['secret']);
                }
              }
            }));
  }
}
