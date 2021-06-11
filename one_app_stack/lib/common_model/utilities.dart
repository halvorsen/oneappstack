// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:one_app_stack/project_page/bloc/project_config_helper.dart';

//screen

T varyForScreenWidth<T>(
    T large, T normal, T small, T compact, BuildContext context) {
  if (MediaQuery.of(context).size.width > 1050) {
    return large;
  } else if (MediaQuery.of(context).size.width < 450) {
    return compact;
  } else if (MediaQuery.of(context).size.width < 700) {
    return small;
  }
  return normal;
}

T varyForOneScreenWidth<T>(T value, BuildContext context,
    {T? large, T? normal, T? small, T? compact}) {
  if (MediaQuery.of(context).size.width > 1050 && large != null) {
    return large;
  } else if (MediaQuery.of(context).size.width < 450 && compact != null) {
    return compact;
  } else if (MediaQuery.of(context).size.width < 700 && small != null) {
    return small;
  } else if (MediaQuery.of(context).size.width >= 700 && normal != null) {
    return normal;
  }
  return value;
}

GlobalKey textfieldKey = GlobalKey();
double keyboardVerticalWidgetShift(GlobalKey widgetKey, BuildContext context) {
  final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
  final screenHeight = MediaQuery.of(context).size.height;
  final RenderBox renderObject =
      widgetKey.currentContext?.findRenderObject() as RenderBox;
  final offset = renderObject.localToGlobal(Offset.zero);
  final size = renderObject.paintBounds.size;
  final keyboardTop = screenHeight - keyboardHeight;
  final widgetBottom = offset.dy + size.height;
  final diff = keyboardTop - widgetBottom;
  return diff.sign < 0 ? diff.abs() : 0;
}

double screenWidth(context) => MediaQuery.of(context).size.width;
double screenHeight(context) => MediaQuery.of(context).size.height;
double screenAspect(context) => screenWidth(context) / screenHeight(context);

double headerWidgetHeight(context) =>
    varyForScreenWidth(60.0, 60.0, 50.0, 50.0, context);

//global variables

String? currentProjectName;
String? currentProjectId;
String? currentProjectConfigString;
String? currentProjectConfigStringIos;
String? currentProjectConfigStringAndroid;
UserPermissionLevel? permissionLevel;

Map<String, dynamic>? get currentProjectConfig {
  return ProjectConfigHelper.parseConfig(
      currentProjectName ?? '', currentProjectConfigString ?? '');
}

Map<String, dynamic>? get currentProjectConfigIos {
  return ProjectConfigHelper.parseConfigIos(
      currentProjectName ?? '', currentProjectConfigStringIos ?? '');
}

Map<String, dynamic>? get currentProjectConfigAndroid {
  return ProjectConfigHelper.parseConfigAndroid(
      currentProjectName ?? '', currentProjectConfigStringAndroid ?? '');
}

String currentFirebaseProjectId() {
  if (currentProjectConfig != null) {
    return currentProjectConfig!['projectId']!;
  } else if (currentProjectConfigIos != null) {
    return currentProjectConfigIos!['projectId']!;
  } else if (currentProjectConfigAndroid != null) {
    return currentProjectConfigAndroid!['projectId']!;
  }
  return '';
}

enum UserPermissionLevel {
  Admin, //first admin is creator of the project, admins can add other users and access everything. never allowed to reduce below one admin. can delete the project.
  Developer, //developer can access everything but cant control deletion of project and can't change user access
  Editor, //editor cannot see the data-path page, they primarily have access to reading, writing, and deleting app content
  Reader //reader cannot see the data-path page, they primarily can read app content
}

class UserPermissionHelper {
  static String levelString(UserPermissionLevel level) {
    switch (level) {
      case UserPermissionLevel.Admin:
        return 'admin';
      case UserPermissionLevel.Developer:
        return 'developer';
      case UserPermissionLevel.Editor:
        return 'editor';
      case UserPermissionLevel.Reader:
        return 'reader';
    }
  }

  static UserPermissionLevel levelEnum(String level) {
    switch (level) {
      case 'admin':
        return UserPermissionLevel.Admin;
      case 'developer':
        return UserPermissionLevel.Developer;
      case 'editor':
        return UserPermissionLevel.Editor;
      case 'reader':
        return UserPermissionLevel.Reader;
      default:
        return UserPermissionLevel.Reader;
    }
  }
}

//colors
final black28 = Color(0xff282828);
final grayda = Color(0xffdadada);
final teal = Color(0xffE8FFFC);

final exampleConfig = '''
COPY/PASTE const firebaseConfig = {
    apiKey: "CexampleA-FmWikEXAMPLEBepUfBUwccH_qrEc",
    authDomain: "example.firebaseapp.com",
    databaseURL: "https://example-rtdb.firebaseio.com",
    projectId: "example",
    storageBucket: "example.appspot.com",
    messagingSenderId: "4363248682",
    appId: "1:5143574245682:web:6ad352345623examplef18683",
    measurementId: "G-EXAMPLE"
};
                    ''';

final exampleIosFile = '+ GoogleService-Info.plist';
final exampleAndroidFile = '+ google-services.json';

// Extensions

extension StringExtension on String {
  String capitalize() {
    if (this.length == 0) {
      return '';
    }
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }

  String lowerCaseFirst() {
    if (this.length == 0) {
      return '';
    }
    return '${this[0].toLowerCase()}${this.substring(1)}';
  }
}

String upper(String name) {
  return name.capitalize();
}

String lower(String name) {
  return name.lowerCaseFirst();
}
