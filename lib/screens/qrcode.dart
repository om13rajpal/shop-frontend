import 'dart:convert';

import 'package:admin/providers/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCode extends ConsumerWidget {
  const QrCode({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.read(urlProvider);
    Future<void> saveSale(String sku, int quantity, int price) async {
      final body = {
        "sku": sku,
        "quantity": quantity,
        "productPrice": price,
        "workerId": '684831d1f7bb69d6d4f42e78',
      };

      final response = await http.post(
        Uri.parse("$url/sale"),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        final body = {"quantity": quantity};
        final response = await http.put(
          (Uri.parse("$url/product/sale/$sku")),
          body: jsonEncode(body),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          const snackbar = SnackBar(content: Text('sale saved'));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
          Navigator.pop(context);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: MobileScanner(
        onDetect: (barcode) {
          if (barcode.raw != null) {
            final json = jsonDecode(barcode.barcodes.first.rawValue.toString());
            TextEditingController price = TextEditingController(
              text: json['sellingPrice'].toString(),
            );
            TextEditingController quantity = TextEditingController();
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: SizedBox(
                    height: 300,
                    child: Column(
                      spacing: 5,
                      children: [
                        Text(json['name']),
                        Text(json['sku']),
                        TextField(
                          controller: price,
                          decoration: InputDecoration(
                            label: Text('Selling at ₹'),
                          ),
                        ),
                        TextField(
                          controller: quantity,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(label: Text('quantity')),
                        ),
                        ElevatedButton(
                          onPressed:
                              () => saveSale(
                                json['sku'],
                                int.parse(quantity.text.trim()),
                                int.parse(price.text.trim()),
                              ),
                          child: Text('Sell'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
