import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom_parsing.dart';
import 'package:html/html_escape.dart';
import 'package:html/parser.dart';

var tix_url = "https://tixcraft.com/activity";

Future<String> fetchHtmlContent() async {
  final response = await http.get(Uri.parse(tix_url));

  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load HTML content');
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> futureHtmlContent;

  @override
  void initState() {
    super.initState();
    futureHtmlContent = fetchHtmlContent();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch HTML Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch HTML Example'),
        ),
        body: FutureBuilder<String>(
          future: futureHtmlContent,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final htmlDocument = parse(snapshot.data!);
              // 在這裡使用 htmlDocument 來獲取你需要的資料
              // 例如：htmlDocument.querySelector('body') 等等
              print(Text(htmlDocument.outerHtml));
              return Text(htmlDocument.outerHtml);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
