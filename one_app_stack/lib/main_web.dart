// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.
// @dart=2.9
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import 'package:one_app_stack_storage_web/one_app_stack_storage_web.dart';
import 'app_navigation.dart';
import 'main_common.dart';
import 'one_stack.dart';
import 'package:file_picker/file_picker.dart';

class CommonServicesWeb implements CommonServices {
  @override
  StorageApi storage = Storage1AppStackWeb();

  @override
  AppNavigation appNavigation;

  @override
  FirebaseSigninApi auth = FirebaseSignin();

  @override
  OneAppStackPlatformApi platform = OneAppStackPlatform();

  @override
  FileHelperApi fileHelper = FileHelper();
}

class OneStackWeb extends OneStack {
  @override
  final CommonServices services = CommonServicesWeb();
}

class OneAppStackPlatform extends OneAppStackPlatformApi {
  AppPlatform get platform {
    return AppPlatform.web;
  }

  bool isIos = false;
  bool isAndroid = false;
  bool isWeb = true;
  bool isLinux = false;
  bool isMac = false;
  bool isWindows = false;
}

class FileHelper extends FileHelperApi {
  Future<Map<String, Uint8List>> chooseFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      return {result.files.single.name: result.files.single.bytes};
    } else {
      return {};
    }
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final app = OneStackWeb();
  app.initializeNavigationObject();
  app.services.auth.initializeApp().then((_) {
    runApp(app);
  });
}
