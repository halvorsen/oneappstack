// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:one_app_stack/common_model/utilities.dart';

import '../../one_stack.dart';
import '../../common_widget/header_widget.dart';
import '../../common_model/utilities.dart';
import 'package:flutter/material.dart';

import 'settings_row_widget.dart';

class SettingsPageWidget extends StatelessWidget {
  SettingsPageWidget(this.services, {Key? key}) : super(key: key);
  final CommonServices services;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: teal,
        child: Stack(
          children: [
            Padding(
                padding:
                    EdgeInsets.fromLTRB(0, headerWidgetHeight(context), 0, 0),
                child: Container(
                    height: screenHeight(context),
                    child: SettingsRowWidget(services))),
            Align(
                alignment: Alignment(0.0, -1.0),
                child: Container(
                    height: headerWidgetHeight(context),
                    child: HeaderWidget(services, currentProjectId != null,
                        HeaderWidget.settingsTitle))),
          ],
        ));
  }
}
