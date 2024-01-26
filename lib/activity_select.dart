import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:path_provider/path_provider.dart';

var tix_url = "https://tixcraft.com/activity";

class ActivityInfo {
  String imageUrl;
  String activityName;
  String activityUrl; // 新增活動URL屬性

  ActivityInfo({
    required this.imageUrl,
    required this.activityName,
    required this.activityUrl,
  });
}

Future<List<ActivityInfo>> fetchActivityInfo() async {
  final response = await http.get(Uri.parse(tix_url));
  if (response.statusCode == 200) {
    var document = parse(response.body);

    // 使用 querySelector 找到第一個 'row display-card display-content' 元素
    var firstDisplayContent =
        document.querySelector('.row.display-card.display-content');

    // 檢查是否找到該元素
    if (firstDisplayContent != null) {
      // 從第一個 'row display-card display-content' 元素中獲取 'thumbnails'
      var thumbnailElements =
          firstDisplayContent.getElementsByClassName('thumbnails');

      List<ActivityInfo> activityList = [];

      for (var thumbnailElement in thumbnailElements) {
        // 以下保持不變
        var imageElement = thumbnailElement.querySelector('img');
        var dataElement = thumbnailElement.querySelector('.data');
        var dateElement = dataElement?.querySelector('.date');
        var nameElement = dataElement?.querySelector('.multi_ellipsis');
        var anchorElement = thumbnailElement.querySelector('a'); // 取得<a>元素

        if (imageElement != null &&
            dateElement != null &&
            nameElement != null &&
            anchorElement != null) {
          var imageUrl = imageElement.attributes['src'] ?? '';
          var activityName = nameElement.text.trim();
          var activityDate = dateElement.text.trim();
          var activityUrl = anchorElement.attributes['href'] ?? ''; // 取得活動URL

          activityList.add(ActivityInfo(
            imageUrl: imageUrl,
            activityName: '$activityDate $activityName',
            activityUrl: activityUrl,
          ));
        }
      }

      return activityList;
    } else {
      throw Exception('找不到 display-card display-content');
    }
  } else {
    throw Exception('取得活動失敗');
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<ActivityInfo>> futureActivityInfo;
  ActivityInfo? selectedActivity;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureActivityInfo = fetchActivityInfo();
  }

  // 進行關鍵字過濾
  List<ActivityInfo> filterActivities(
      String keyword, List<ActivityInfo> activities) {
    return activities
        .where((activity) =>
            activity.activityName.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '活動選擇',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 95, 92, 93)),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('請選擇活動'),
          backgroundColor: const Color.fromARGB(255, 123, 189, 242),
          actions: [
            // 搜尋框
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 200, // 設定搜尋框的寬度
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: '請輸入活動名稱',
                  ),
                  onChanged: (value) {
                    setState(() {
                      // 更新搜尋結果
                      futureActivityInfo = fetchActivityInfo().then(
                          (activities) => filterActivities(value, activities));
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        body: FutureBuilder<List<ActivityInfo>>(
          future: futureActivityInfo,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                // 建立選擇器
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var activity = snapshot.data![index];
                    return ListTile(
                      title: Row(
                        children: [
                          // 圖片
                          Image.network(
                            activity.imageUrl,
                            width: 150,
                            height: 75,
                            fit: BoxFit.cover,
                          ),
                          // 活動名稱
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                activity.activityName,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          selectedActivity = activity;

                          // 打印活動URL
                          print(
                              "Clicked on activity. URL: ${activity.activityUrl}");
                        });
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
