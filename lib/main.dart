// Copyright 2019-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'tixcraft.dart';
import 'settinconfig.dart';
import 'infinite_process_page.dart';

void main() {
  setupWindow();
  runApp(
    const MaterialApp(
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
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      home: DefaultTabController(
        length: 2, //依照分頁數調整
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
          body: const TabBarView(
            children: [
              SettingConfig(),
              InfiniteProcessPageStarter(),
              //DataTransferPageStarter(),
            ],
          ),
        ),
      ),
    );
  }
}
