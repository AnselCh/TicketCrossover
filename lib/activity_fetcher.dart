// activity_fetcher.dart

import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class ActivityInfo {
  String imageUrl;
  String activityName;
  String activityUrl;

  ActivityInfo({
    required this.imageUrl,
    required this.activityName,
    required this.activityUrl,
  });
}

class ActivityFetcher {
  static const String tixUrl = "https://tixcraft.com/activity";

  static Future<List<ActivityInfo>> fetchActivityInfo() async {
    final response = await http.get(Uri.parse(tixUrl));
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
}
