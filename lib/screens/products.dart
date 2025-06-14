import 'dart:convert';

import 'package:admin/providers/products.dart';
import 'package:admin/providers/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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
      print(jsonRes);
      ref.read(productsProvider.notifier).list(jsonRes['data']);
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
                  return ListTile(
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
                  );
                },
              ),
    );
  }
}
