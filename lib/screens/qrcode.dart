import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCode extends StatelessWidget {
  const QrCode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        onDetect: (barcode) {
          if (barcode.raw != null) {
            showDialog(
              context: context,
              builder: (context) {
                return Column(children: [Text(barcode.raw.toString())]);
              },
            );
          }
        },
      ),
    );
  }
}
