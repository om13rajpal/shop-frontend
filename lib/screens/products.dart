import 'dart:convert';

import 'package:admin/providers/products.dart';
import 'package:admin/providers/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Products extends ConsumerStatefulWidget {
  const Products({super.key});

  @override
  ConsumerState<Products> createState() => _ProductsState();
}

class _ProductsState extends ConsumerState<Products> {
  Future<void> getProducts(WidgetRef ref) async {
    final url = ref.read(urlProvider);
    final response = await http.get(Uri.parse("$url/product"));

    if (response.statusCode == 200) {
      final jsonRes = await jsonDecode(response.body);
      ref.read(productsProvider.notifier).list(jsonRes['data']);
    }
  }

  Future<void> deleteProduct(String sku, WidgetRef ref) async {
    final url = ref.read(urlProvider);
    final response = await http.delete(Uri.parse("$url/product/$sku"));

    if (response.statusCode == 200) {
      const snackbar = SnackBar(content: Text('Deleted the product'));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } else {
      if (!context.mounted) return;
      const snackbar = SnackBar(content: Text('Error deleting the product'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<void> generateQR(String sku, WidgetRef ref) async {
    final url = ref.read(urlProvider);
    final response = await http.post(Uri.parse("$url/product/qr/$sku"));
    if (response.statusCode == 200) {
      final snackbar = SnackBar(content: Text('QR generated successfully'));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Future.delayed(Duration(milliseconds: 400));
      final imageUrl = Uri.parse('$url/qrcode/$sku.png');
      print(imageUrl);
      if (await canLaunchUrl(imageUrl)) {
        await launchUrl(imageUrl, mode: LaunchMode.externalApplication);
      } else {
        final snackbar = SnackBar(content: Text('Error launching qr code'));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } else {
      final snackbar = SnackBar(content: Text('Error generating qr code'));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<void> updateStock(String sku, WidgetRef ref, int quantity) async {
    final url = ref.read(urlProvider);

    final body = {"quantity": quantity};

    final response = await http.put(
      Uri.parse("$url/product/$sku"),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final snackbar = SnackBar(content: Text('Quantity for $sku is updated'));
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } else {
      final snackbar = SnackBar(content: Text('Error updating $sku quantity'));
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  void initState() {
    getProducts(ref);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Products',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body:
          (products.isEmpty)
              ? LinearProgressIndicator()
              : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    background: Container(
                      color: Colors.red,
                      child: Icon(Icons.delete),
                    ),
                    secondaryBackground: Container(
                      color: Colors.green[200],
                      child: Icon(Icons.qr_code),
                    ),

                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        deleteProduct(products[index]['sku'], ref);
                      } else if (direction == DismissDirection.endToStart) {
                        generateQR(products[index]['sku'], ref);
                      }
                    },
                    key: Key(products[index].toString()),
                    child: InkWell(
                      onTap: () {
                        TextEditingController stock = TextEditingController(
                          text: '0',
                        );

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: SizedBox(
                                height: 200,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 10,
                                  children: [
                                    TextField(
                                      controller: stock,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        label: Text(
                                          'stock',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    ElevatedButton(
                                      onPressed:
                                          () => updateStock(
                                            products[index]['sku'],
                                            ref,
                                            int.parse(stock.text.trim()),
                                          ),
                                      child: Text('Update Stock'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: ListTile(
                        title: Text(
                          products[index]['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          products[index]['sku'],
                          style: TextStyle(fontSize: 13),
                        ),
                        trailing: Column(
                          children: [
                            Text(
                              products[index]['sellingPrice'].toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              products[index]['costPrice'].toString(),
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        leading: Text(
                          products[index]['stock'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
