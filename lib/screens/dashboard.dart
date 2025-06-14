import 'dart:convert';

import 'package:admin/providers/url.dart';
import 'package:admin/providers/username.dart';
import 'package:admin/screens/login.dart';
import 'package:admin/screens/product.dart';
import 'package:admin/screens/products.dart';
import 'package:admin/screens/qrcode.dart';
import 'package:admin/screens/workers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  Future<void> getSaleToday(String url) async {
    final response = await http.get(Uri.parse("$url/sale/today"));

    if (response.statusCode == 200) {
      final jsonRes = await jsonDecode(response.body);
      print(jsonRes);
    }
  }

  @override
  void initState() {
    final url = ref.read(urlProvider);
    getSaleToday(url);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void logout() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }

    final username = ref.watch(usernameProvider);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text(
          'Dashboard',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Workers()),
                ),
            icon: Icon(Icons.verified_user_outlined),
          ),
          IconButton(
            onPressed: () => logout(),
            icon: Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Text(
                'Hello $username,',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: InkWell(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QrCode()),
                    ),
                child: Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade400,
                  ),
                  child: Center(
                    child: Text(
                      'Scan a product',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: InkWell(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Product()),
                    ),
                child: Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade400,
                  ),
                  child: Center(
                    child: Text(
                      'Add a product',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: InkWell(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Products()),
                    ),
                child: Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade400,
                  ),
                  child: Center(
                    child: Text(
                      'View all Products',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
