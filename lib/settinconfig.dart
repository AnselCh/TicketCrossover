import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

class AppConfig {
  static const String tixProviderKey = 'tixprovider';
  static const String selectedEventKey = 'selectedEvent';
  static const String priorityDateKey = 'priorityDate';
  static const String numberOfTicketsKey = 'numberOfTickets';
  static const String selectedAreaKey = 'selectedArea';
  static const String defaultAnswerKey = 'defaultAnswer';
  static const String autoRefreshIntervalKey = 'autoRefreshInterval';

  static Future<void> loadAppConfig() async {
    try {
      // 使用 loadFromAsset 加载配置文件
      await GlobalConfiguration().loadFromAsset("tixsettings.json");
      print("Config loaded successfully");
    } catch (e) {
      print("Error loading config: $e");
    }
  }

  static String get tixProvider =>
      GlobalConfiguration().getValue(tixProviderKey);

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

  static set tixProvider(String value) {
    GlobalConfiguration().updateValue(tixProviderKey, value);
  }

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
    GlobalConfiguration().updateValue(tixProviderKey, value);
  }

  static set defaultAnswer(String value) {
    GlobalConfiguration().updateValue(selectedAreaKey, value);
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
    _timer = Timer(Duration(milliseconds: 200), () {});

    // 加載配置文件
    AppConfig.loadAppConfig().then((_) {
      // 在配置文件加載完成後，刷新頁面
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('選擇售票平台:'),
          TextField(
            onChanged: (value) {
              setState(() {
                AppConfig.tixProvider = value ?? '';
              });
            },
            controller: TextEditingController(text: AppConfig.tixProvider),
          ),
          Text('選擇活動:'),
          TextField(
            onChanged: (value) {
              setState(() {
                AppConfig.selectedEvent = value ?? '';
              });
            },
          ),
          SizedBox(height: 16.0),
          Text('優先日期:'),
          TextField(
            onChanged: (value) {
              setState(() {
                AppConfig.priorityDate = value ?? '';
              });
            },
          ),
          SizedBox(height: 16.0),
          Text('幾張票:'),
          Row(
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
          SizedBox(height: 16.0),
          Text('優先區域選擇:'),
          TextField(
            onChanged: (value) {
              setState(() {
                AppConfig.selectedArea = value ?? '';
              });
            },
          ),
          SizedBox(height: 16.0),
          Text('預設問答題的答案:'),
          TextField(
            onChanged: (value) {
              setState(() {
                AppConfig.defaultAnswer = value ?? '';
              });
            },
          ),
          SizedBox(height: 16.0),
          Text('自動重新整理秒數:'),
          Row(
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
        ],
      ),
    );
  }
}
