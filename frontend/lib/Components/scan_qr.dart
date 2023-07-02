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
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
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
          actions: !perms
              ? []
              : [
                  IconButton(
                    color: Colors.white,
                    icon: ValueListenableBuilder(
                      valueListenable: cameraController.torchState,
                      builder: (context, state, child) {
                        switch (state) {
                          case TorchState.off:
                            return const Icon(Icons.flash_off,
                                color: Colors.grey);
                          case TorchState.on:
                            return const Icon(Icons.flash_on,
                                color: Colors.yellow);
                        }
                      },
                    ),
                    iconSize: 32.0,
                    onPressed: () {
                      cameraController
                          .toggleTorch()
                          .then((_) => setState(() {}));
                    },
                  ),
                ],
        ),
        body: Column(
          children: [
            if (!perms)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: CircularProgressIndicator()),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Please allow camera access to continue'),
                    )
                  ],
                ),
              ),
            Expanded(
              child: MobileScanner(
                  fit: BoxFit.scaleDown,
                  controller: cameraController,
                  onDetect: (barcodes) {
                    for (final barcode in barcodes.barcodes) {
                      final String url = barcode.rawValue!;
                      debugPrint('Barcode found! $url');
                      try {
                        final uri = Uri.parse(url);
                        if (uri.scheme == 'otpauth' && uri.host == 'totp') {
                          cameraController.dispose();
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
                  }),
            ),
          ],
        ));
  }
}
