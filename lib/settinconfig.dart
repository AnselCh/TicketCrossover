// settinconfig.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'activity_fetcher.dart';

class AppConfig {
  static const String tixProviderKey = 'tixprovider';
  static const String selectProviderKey = 'selectprovider';
  //購買網址
  static const String selectedEventKey = 'selectedEvent';
  //活動日期
  static const String priorityDateKey = 'priorityDate';
  //數量
  static const String numberOfTicketsKey = 'numberOfTickets';
  //區域
  static const String selectedAreaKey = 'selectedArea';
  //問答題
  static const String defaultAnswerKey = 'defaultAnswer';
  //刷新秒數
  static const String autoRefreshIntervalKey = 'autoRefreshInterval';
  static var selectedEventName = ''; // 新增這一行

  static void updateSelectedEventName(String value) {
    selectedEventName = value;
  }

  static Future<void> loadAppConfig() async {
    try {
      await GlobalConfiguration().loadFromAsset("tixsettings.json");
    } catch (e) {
      print("Error loading config: $e");
    }
  }

  static List<String> get tixProviderOptions =>
      GlobalConfiguration().getValue(tixProviderKey)?.cast<String>();

  static String get selectProvider =>
      GlobalConfiguration().getValue(selectProviderKey);

  static set selectProvider(String value) {
    // 清空 selectedEvent 和 priorityDate
    selectedEventName = '';
    priorityDate = '';
    GlobalConfiguration().updateValue(selectProviderKey, value);
  }

  static set tixProviderOptions(List<String> value) {
    GlobalConfiguration().updateValue(tixProviderKey, value);
  }

  static String get selectedEvent =>
      GlobalConfiguration().getValue(selectedEventKey);

  static String get priorityDate =>
      GlobalConfiguration().getValue(priorityDateKey);

  static int get numberOfTickets =>
      GlobalConfiguration().getValue(numberOfTicketsKey);

  static String get selectedArea =>
      GlobalConfiguration().getValue(selectedAreaKey);

  static String get defaultAnswer =>
      GlobalConfiguration().getValue(defaultAnswerKey);

  static double get autoRefreshInterval =>
      GlobalConfiguration().getValue(autoRefreshIntervalKey);

  static set selectedEvent(String value) {
    GlobalConfiguration().updateValue(selectedEventKey, value);
  }

  static set priorityDate(String value) {
    GlobalConfiguration().updateValue(priorityDateKey, value);
  }

  static set numberOfTickets(int value) {
    GlobalConfiguration().updateValue(numberOfTicketsKey, value);
  }

  static set selectedArea(String value) {
    GlobalConfiguration().updateValue(selectedAreaKey, value);
  }

  static set defaultAnswer(String value) {
    GlobalConfiguration().updateValue(defaultAnswerKey, value);
  }

  static set autoRefreshInterval(double value) {
    GlobalConfiguration().updateValue(autoRefreshIntervalKey, value);
  }
}

class SettingConfig extends StatefulWidget {
  const SettingConfig({Key? key}) : super(key: key);

  @override
  _SettingConfigState createState() => _SettingConfigState();
}

class _SettingConfigState extends State<SettingConfig> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    AppConfig.loadAppConfig().then((_) {
      setState(() {});
    });
  }

  void _startTimer(Function callback) {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      callback();
    });
  }

  void _stopTimer() {
    _timer.cancel();
  }

  void _navigateToActivitySelect() async {
    // 判斷 App 選擇的提供者
    if (AppConfig.selectProvider != "tixcraft") {
      // 提示不支援的信息
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('目前不支援${AppConfig.selectProvider}'),
          content: Text('拜託抖內我'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('確定'),
            ),
          ],
        ),
      );
      return;
    }

    // 等待 fetchActivityInfo 完成
    List<ActivityInfo> activityList = await ActivityFetcher.fetchActivityInfo();

    // 導航到新的頁面，並將活動列表傳遞給該頁面
    final selectedActivity = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityListPage(activityList: activityList),
      ),
    );

    // 在這裡處理選擇的活動，例如更新相應的變數
    if (selectedActivity != null && selectedActivity is ActivityInfo) {
      setState(() {
        // 更新相應的變數，例如：
        AppConfig.selectedEvent = selectedActivity.activityUrl;
        AppConfig.updateSelectedEventName(
            selectedActivity.activityName); // 更新 selectedEventName
        AppConfig.priorityDate = selectedActivity.activityName;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // 調用 fetchActivityDate 獲取日期列表
    List<String> dateList = await ActivityDateFetcher.fetchActivityDateList();

    // 如果沒有日期，顯示提示信息
    if (dateList.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('沒有可用的活動日期'),
          content: Text('請稍後再試或選擇其他活動'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('確定'),
            ),
          ],
        ),
      );
      return;
    }

    // 讓使用者從日期列表中選擇日期
    String? selectedDate = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('選擇活動日期'),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: dateList.map((date) {
              return ListTile(
                title: Text(date),
                onTap: () {
                  Navigator.pop(context, date);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );

    // 如果使用者選擇了日期，更新 UI
    if (selectedDate != null) {
      setState(() {
        AppConfig.priorityDate = selectedDate;
      });
    }
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: '選擇售票平台:',
            child: Container(
              width: 200.0,
              child: DropdownButton<String>(
                value: AppConfig.selectProvider,
                items: AppConfig.tixProviderOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    AppConfig.selectProvider = value ?? '';
                  });
                },
              ),
            ),
          ),
          _buildSection(
            title: '選擇活動:(載入需要一點時間)',
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppConfig.selectedEventName ?? '未選擇',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.event_available),
                  onPressed: () {
                    _navigateToActivitySelect();
                  },
                ),
              ],
            ),
          ),
          _buildSection(
            title: '選擇場次',
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppConfig.priorityDate ?? '未選擇',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.schedule),
                    onPressed: () async {
                      await _selectDate(context);
                    }),
              ],
            ),
          ),
          _buildSection(
            title: '幾張票:',
            child: Row(
              children: [
                GestureDetector(
                  onLongPress: () {
                    _startTimer(() {
                      setState(() {
                        AppConfig.numberOfTickets =
                            (AppConfig.numberOfTickets > 0)
                                ? AppConfig.numberOfTickets - 1
                                : 0;
                      });
                    });
                  },
                  onLongPressUp: () {
                    _stopTimer();
                  },
                  child: IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        AppConfig.numberOfTickets =
                            (AppConfig.numberOfTickets > 0)
                                ? AppConfig.numberOfTickets - 1
                                : 1;
                      });
                    },
                  ),
                ),
                Text('${AppConfig.numberOfTickets}'),
                GestureDetector(
                  onLongPress: () {
                    _startTimer(() {
                      setState(() {
                        AppConfig.numberOfTickets =
                            (AppConfig.numberOfTickets < 5)
                                ? AppConfig.numberOfTickets + 1
                                : 5;
                      });
                    });
                  },
                  onLongPressUp: () {
                    _stopTimer();
                  },
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        AppConfig.numberOfTickets =
                            (AppConfig.numberOfTickets < 5)
                                ? AppConfig.numberOfTickets + 1
                                : 5;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          _buildSection(
            title: '優先區域選擇:',
            child: TextField(
              onChanged: (value) {
                setState(() {
                  AppConfig.selectedArea = value ?? '';
                });
              },
            ),
          ),
          _buildSection(
            title: '預設問答題的答案:',
            child: TextField(
              onChanged: (value) {
                setState(() {
                  AppConfig.defaultAnswer = value ?? '';
                });
              },
            ),
          ),
          _buildSection(
            title: '自動重新整理秒數:',
            child: Row(
              children: [
                GestureDetector(
                  onLongPress: () {
                    _startTimer(() {
                      setState(() {
                        AppConfig.autoRefreshInterval =
                            (AppConfig.autoRefreshInterval > 0)
                                ? (AppConfig.autoRefreshInterval - 0.1)
                                    .clamp(0.1, 5.0)
                                : 0.1;
                      });
                    });
                  },
                  onLongPressUp: () {
                    _stopTimer();
                  },
                  child: IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        AppConfig.autoRefreshInterval =
                            (AppConfig.autoRefreshInterval > 0)
                                ? (AppConfig.autoRefreshInterval - 0.1)
                                    .clamp(0.1, 5.0)
                                : 0.1;
                      });
                    },
                  ),
                ),
                Text('${AppConfig.autoRefreshInterval.toStringAsFixed(1)}'),
                GestureDetector(
                  onLongPress: () {
                    _startTimer(() {
                      setState(() {
                        AppConfig.autoRefreshInterval =
                            (AppConfig.autoRefreshInterval < 5)
                                ? (AppConfig.autoRefreshInterval + 0.1)
                                    .clamp(0.1, 5.0)
                                : 5.0;
                      });
                    });
                  },
                  onLongPressUp: () {
                    _stopTimer();
                  },
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        AppConfig.autoRefreshInterval =
                            (AppConfig.autoRefreshInterval < 5)
                                ? (AppConfig.autoRefreshInterval + 0.1)
                                    .clamp(0.1, 5.0)
                                : 5.0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0), // 調整區域之間的垂直間距
        child,
        SizedBox(height: 16.0), // 調整區域之間的垂直間距
      ],
    );
  }
}

class ActivityListPage extends StatelessWidget {
  final List<ActivityInfo> activityList;

  const ActivityListPage({Key? key, required this.activityList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('選擇活動'),
      ),
      body: ListView.builder(
        itemCount: activityList.length,
        itemBuilder: (context, index) {
          var activity = activityList[index];
          return ListTile(
            title: Text(activity.activityName),
            subtitle: Text(activity.activityUrl), // 顯示日期或其他相關信息
            leading: Image.network(
              activity.imageUrl,
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.width * 0.2,
              fit: BoxFit.cover,
            ),
            onTap: () {
              // 在這裡處理選擇活動的邏輯，例如將選擇的活動資訊存儲到全局變數中
              // 並返回到上一個設置頁面
              Navigator.pop(context, activity); // 將選擇的活動作為返回結果
            },
          );
        },
      ),
    );
  }
}
