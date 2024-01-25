import 'dart:async';
import 'dart:io'; // 需要引入 dart:io 以使用 File 類別
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:path_provider/path_provider.dart';

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
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> futureHtmlContent;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/output.html');
  }

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

              // 取得文件
              _localFile.then((file) {
                // 寫入 HTML 內容到文件
                file.writeAsStringSync(htmlDocument.outerHtml);

                // 顯示成功訊息
                return const Text(
                    'HTML Content Loaded and Dumped to output.html');
              });
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
