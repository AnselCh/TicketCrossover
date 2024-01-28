// main.dart

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'tixcraft.dart';
import 'settinconfig.dart';

void main() {
  setupWindow();
  runApp(
    MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      home: HomePage(),
    ),
  );
}

const double windowWidth = 1024;
const double windowHeight = 800;

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('搶票小精靈🧚');
    setWindowMinSize(const Size(windowWidth, windowHeight));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 依照分頁數調整
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.flash_on),
                text: '設定',
              ),
              Tab(
                icon: Icon(Icons.confirmation_number),
                text: '搶票',
              ),
              /*
              Tab(
                icon: Icon(Icons.storage),
                text: 'Data Transfer',
              ),
              */
            ],
          ),
          title: const Text('搶票小精靈🧚'),
        ),
        body: TabBarView(
          children: [
            SettingConfig(),
            TixcraftHomeWrapper(),
            // DataTransferPageStarter(),
          ],
        ),
      ),
    );
  }
}

class TixcraftHomeWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 在這裡重新創建 TixcraftHome widget
    return AppConfig.selectProvider == 'tixcraft'
        ? TixcraftHome()
        : Container(
            child: Center(
              child: Text('目前不支援 ${AppConfig.selectProvider}'),
            ),
          );
  }
}
