// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/widgets.dart';

enum AppPlatform { ios, android, web, linux, mac, windows }

abstract class OneAppStackPlatformApi {
  late AppPlatform platform;
  late bool isIos;
  late bool isAndroid;
  late bool isWeb;
  late bool isLinux;
  late bool isMac;
  late bool isWindows;
}

abstract class FileHelperApi {
  Future<Map<String, Uint8List>> chooseFile(BuildContext context);
}
