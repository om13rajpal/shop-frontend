import 'dart:convert';

import 'package:admin/providers/url.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Product extends ConsumerWidget {
  const Product({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(urlProvider);

    TextEditingController name = TextEditingController();
    TextEditingController costPrice = TextEditingController();
    TextEditingController sellingPrice = TextEditingController();
    TextEditingController sku = TextEditingController();
    TextEditingController stock = TextEditingController();

    Future<void> addProduct() async {
      if (name.text.isEmpty ||
          costPrice.text.isEmpty ||
          sellingPrice.text.isEmpty ||
          sku.text.isEmpty ||
          stock.text.isEmpty) {
        const snackbar = SnackBar(content: Text('every field is required'));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        return;
      }
      final body = {
        "name": name.text.trim(),
        "costPrice": int.parse(costPrice.text.trim()),
        "sellingPrice": int.parse(sellingPrice.text.trim()),
        "sku": sku.text.trim(),
        "stock": int.parse(stock.text.trim()),
      };

      final response = await http.post(
        Uri.parse("$url/product"),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      final jsonRes = await jsonDecode(response.body);
      if (response.statusCode == 201) {
        final snackbar = SnackBar(content: Text(jsonRes['message']));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        name.clear();
        costPrice.clear();
        sellingPrice.clear();
        sku.clear();
        stock.clear();
      } else {
        final snackbar = SnackBar(content: Text('error saving product'));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Product',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: TextField(
                controller: name,
                decoration: InputDecoration(label: Text('name')),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 5)),
            SliverToBoxAdapter(
              child: TextField(
                controller: costPrice,
                decoration: InputDecoration(label: Text('cost price')),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 5)),
            SliverToBoxAdapter(
              child: TextField(
                controller: sellingPrice,
                decoration: InputDecoration(label: Text('selling price')),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 5)),
            SliverToBoxAdapter(
              child: TextField(
                controller: sku,
                decoration: InputDecoration(label: Text('sku')),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 5)),
            SliverToBoxAdapter(
              child: TextField(
                controller: stock,
                decoration: InputDecoration(label: Text('stock')),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 5)),
            SliverToBoxAdapter(
              child: ElevatedButton(
                onPressed: () => addProduct(),
                child: Text('save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
