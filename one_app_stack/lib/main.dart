// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.
// @dart=2.9
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_app_stack_storage/one_app_stack_storage.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'app_navigation.dart';
import 'main_common.dart';
import 'one_stack.dart';
import 'dart:io';

class CommonServicesMobile implements CommonServices {
  @override
  StorageApi storage = Storage1AppStack();

  @override
  AppNavigation appNavigation;

  @override
  FirebaseSigninApi auth = FirebaseSignin();

  @override
  OneAppStackPlatformApi platform = OneAppStackPlatform();

  @override
  FileHelperApi fileHelper = FileHelper();
}

class OneStackMobile extends OneStack {
  @override
  final CommonServices services = CommonServicesMobile();
}

class OneAppStackPlatform extends OneAppStackPlatformApi {
  AppPlatform get platform {
    if (Platform.isAndroid) {
      return AppPlatform.android;
    } else if (Platform.isIOS) {
      return AppPlatform.ios;
    } else if (Platform.isLinux) {
      return AppPlatform.linux;
    } else if (Platform.isMacOS) {
      return AppPlatform.mac;
    } else if (Platform.isWindows) {
      return AppPlatform.windows;
    } else {
      assert(false);
      return AppPlatform.ios;
    }
  }

  bool isIos = Platform.isIOS;
  bool isAndroid = Platform.isAndroid;
  bool isWeb = false;
  bool isLinux = Platform.isLinux;
  bool isMac = Platform.isMacOS;
  bool isWindows = Platform.isWindows;
}

class FileHelper extends FileHelperApi {
  Future<Map<String, Uint8List>> chooseFile(BuildContext context) async {
    if (Platform.isIOS || Platform.isAndroid) {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        return {result.files.single.name: result.files.single.bytes};
      } else {
        return {};
      }
    } else {
      final directory = await getExternalStorageDirectory();
      String path = await FilesystemPicker.open(
        title: 'Select File',
        context: context,
        rootDirectory: directory,
        fsType: FilesystemType.file,
      );
      final filename = path.split('/').last;
      if (path != null) {
        File file = File('$path');
        final data = await file.readAsBytes();
        return {filename: data};
      } else {
        return {};
      }
    }
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final app = OneStackMobile();
  app.initializeNavigationObject();
  app.services.auth.initializeApp().then((_) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    runApp(app);
  });
}
