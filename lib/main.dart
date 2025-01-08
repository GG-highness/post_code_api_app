import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller = TextEditingController();
  List<String> items = [];
  String errorMassage = '';

  Future<void> loadZipCode(String zipCode) async {
    setState(() {
      errorMassage = 'APIレスポンス待ち';
    });

    final response = await http.get(
        Uri.parse('https://zipcloud.ibsnet.co.jp/api/search?zipcode=$zipCode'));

    if (response.statusCode != 200) {
      return;
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    final results = (body['results'] ?? []) as List<dynamic>;

    if (results.isEmpty) {
      setState(() {
        errorMassage = '該当する郵便番号はありません';
      });
    } else {
      setState(() {
        errorMassage = '';
        items = results
            .map((result) =>
                "${result['address1']}${result['address2']}${result['address3']}")
            .toList(growable: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              loadZipCode(value);
            },
          ),
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            if (errorMassage.isNotEmpty) {
              return ListTile(
                title: Text(errorMassage),
              );
            } else {
              return ListTile(
                title: Text(items[index]),
              );
            }
          },
        ));
  }
}
