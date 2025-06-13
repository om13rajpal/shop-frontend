import 'dart:convert';

import 'package:admin/providers/url.dart';
import 'package:admin/providers/workers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class Workers extends ConsumerStatefulWidget {
  const Workers({super.key});

  @override
  ConsumerState<Workers> createState() => _WorkersState();
}

class _WorkersState extends ConsumerState<Workers> {
  Future<void> getUnverifiedWorker(String url) async {
    final response = await http.get(Uri.parse("$url/worker/unverified"));

    if (response.statusCode == 200) {
      final jsonRes = await jsonDecode(response.body);
      print(jsonRes);
      ref.read(workerProvider.notifier).setWorkers(jsonRes['workers']);
    }
  }

  Future<void> verifyWorker(String url, String id, String name) async {
    final response = await http.put(
      Uri.parse("$url/worker/verify/$id"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonRes = await jsonDecode(response.body);
      print(jsonRes);
      if (!context.mounted) return;
      final snackbar = SnackBar(content: Text(jsonRes['message']));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);

      ref.read(workerProvider.notifier).remove(id);
    } else {
      if (!context.mounted) return;
      const errorbar = SnackBar(content: Text('error verifying'));
      ScaffoldMessenger.of(context).showSnackBar(errorbar);
    }
  }

  @override
  void initState() {
    final url = ref.read(urlProvider);
    getUnverifiedWorker(url);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final workers = ref.watch(workerProvider);
    final url = ref.watch(urlProvider);
    print(workers);
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Text(
          'Unverified users',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      body:
          (workers.isEmpty)
              ? LinearProgressIndicator()
              : ListView.builder(
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(workers[index]['name']),
                    trailing: ElevatedButton(
                      onPressed:
                          () => verifyWorker(
                            url,
                            workers[index]['id'],
                            workers[index]['name'],
                          ),
                      child: Icon(Icons.verified),
                    ),
                  );
                },
              ),
    );
  }
}
