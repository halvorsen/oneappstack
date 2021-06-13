// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'dart:convert';

class ProjectConfigHelper {
  static Map<String, dynamic>? parseConfig(String appName, String config) {
    int? start;
    int? end;
    for (var i = 0; i < config.length; i++) {
      if (config[i] == '{') {
        start = i;
      }
      if (start != null && config[i] == '}') {
        end = i + 1;
        break;
      }
    }
    if (start != null && end != null) {
      var parsingString = config.substring(start, end);
      parsingString = parsingString.replaceAll(' ', '');
      parsingString = parsingString.replaceAll('\n', '');
      parsingString = parsingString.replaceFirst('apiKey', '"apiKey"');
      parsingString = parsingString.replaceFirst('authDomain', '"authDomain"');
      parsingString = parsingString.replaceFirst('projectId', '"projectId"');
      parsingString =
          parsingString.replaceFirst('storageBucket', '"storageBucket"');
      parsingString = parsingString.replaceFirst(
          'messagingSenderId', '"messagingSenderId"');
      parsingString = parsingString.replaceFirst('appId', '"appId"');
      parsingString =
          parsingString.replaceFirst('measurementId', '"measurementId"');
      try {
        Map<String, dynamic> configMap = jsonDecode(parsingString);
        configMap['name'] = appName;
        String id = configMap['projectId'] ?? '';
        configMap['databaseURL'] = 'https://$id.firebaseio.com';
        if (configMap['apiKey'] != null &&
            configMap['authDomain'] != null &&
            configMap['projectId'] != null &&
            configMap['storageBucket'] != null &&
            configMap['messagingSenderId'] != null &&
            configMap['appId'] != null &&
            configMap['name'] != null) {
          return configMap;
        } else {
          return null;
        }
      } catch (e) {
        print(e);
      }
    } else {
      return null;
    }
  }

  static Map<String, dynamic>? parseConfigIos(String appName, String config) {
    //dart xml parsers dont work for this even though its in xml format

    if (!config.contains('<dict>') ||
        !config.contains('</dict>') ||
        !config.contains('API_KEY')) {
      return null;
    }
    final start = config.indexOf('<dict>');
    final end = config.indexOf('</dict>');
    final configSub = config.substring(start, end + 7);
    final configSub1 = configSub.replaceFirst('<dict>', '{');
    final configSub2 = configSub1.replaceFirst('</dict>', '}');
    final configSub3 = configSub2.replaceAll('<key>', '\"');
    final configSub4 = configSub3.replaceAll('</key>', '\":');
    final configSub5 = configSub4.replaceAll('<string>', '\"');
    final configSub6 = configSub5.replaceAll('</string>', '\",');
    final configSub7 = configSub6.replaceAll('<true/>', 'true,');
    final configSub8 = configSub7.replaceAll('<false/>', 'false,');
    final configSub9 = configSub8.replaceAll('\n', '');
    final configSub10 = configSub9.replaceFirst(',}', '}');
    final configSub11 = configSub10.replaceAll('<false></false>', 'false,');
    final configSub12 = configSub11.replaceAll('<true></true>', 'true,');

    Map<String, dynamic> _configMap = jsonDecode(configSub12);

    String apiKey = _configMap['API_KEY'];
    String projectId = _configMap['PROJECT_ID'];
    String authDomain = projectId + '.firebaseapp.com';
    String storageBucket = _configMap['STORAGE_BUCKET'];
    String messagingSenderId = _configMap['GCM_SENDER_ID'];
    String appId = _configMap['GOOGLE_APP_ID'];
    String databaseURL = _configMap['DATABASE_URL'];
    Map<String, dynamic> configMap = {
      'apiKey': apiKey,
      'authDomain': authDomain,
      'databaseURL': databaseURL,
      'projectId': projectId,
      'storageBucket': storageBucket,
      'messagingSenderId': messagingSenderId,
      'appId': appId,
      'name': appName
    };

    if (configMap['apiKey'] != null &&
        configMap['authDomain'] != null &&
        configMap['databaseURL'] != null &&
        configMap['projectId'] != null &&
        configMap['storageBucket'] != null &&
        configMap['messagingSenderId'] != null &&
        configMap['appId'] != null &&
        configMap['name'] != null) {
      return configMap;
    } else {
      return null;
    }
  }

  static Map<String, dynamic>? parseConfigAndroid(
      String appName, String config) {
    try {
      Map<String, dynamic> _configMap = jsonDecode(config);
      Map<String, dynamic> projectInfo =
          Map<String, dynamic>.from(_configMap['project_info']);
      final clientList = (_configMap['client'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      final _apiKey = (clientList.first['api_key'] as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      String apiKey = _apiKey.first['current_key'];
      String projectId = projectInfo['project_id'];
      String authDomain = projectId + '.firebaseapp.com';
      String storageBucket = projectInfo['storage_bucket'];
      String messagingSenderId = projectInfo['project_number'];
      Map<String, dynamic> clientInfo =
          Map<String, dynamic>.from(clientList.first['client_info']);
      String appId = clientInfo['mobilesdk_app_id'];
      String databaseURL = projectInfo['firebase_url'];
      Map<String, dynamic> configMap = {
        'apiKey': apiKey,
        'authDomain': authDomain,
        'databaseURL': databaseURL,
        'projectId': projectId,
        'storageBucket': storageBucket,
        'messagingSenderId': messagingSenderId,
        'appId': appId,
        'name': appName
      };
      if (configMap['apiKey'] != null &&
          configMap['authDomain'] != null &&
          configMap['databaseURL'] != null &&
          configMap['projectId'] != null &&
          configMap['storageBucket'] != null &&
          configMap['messagingSenderId'] != null &&
          configMap['appId'] != null &&
          configMap['name'] != null) {
        return configMap;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
