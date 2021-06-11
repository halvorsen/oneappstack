// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';

import 'app_navigation.dart';
import 'main_common.dart';

class CommonServices {
  late AppNavigation appNavigation;
  late StorageApi storage;
  late FirebaseSigninApi auth;
  late OneAppStackPlatformApi platform;
  late FileHelperApi fileHelper;
}

class OneStack extends StatelessWidget {
  // This widget is the root of your application.
  initializeNavigationObject() {
    services.appNavigation = AppNavigation(services);
  }

  final CommonServices services = CommonServices();

  @override
  Widget build(BuildContext context) {
    return services.appNavigation.materialApp();
  }
}
