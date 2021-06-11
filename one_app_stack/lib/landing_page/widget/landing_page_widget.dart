// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.
// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import '../../common_model/utilities.dart';
import '../../common_widget/header_widget.dart';
import '../../one_stack.dart';
import 'package:flutter/material.dart';

import 'landing_page_marketing_widget.dart';

class LandingPageWidget extends StatelessWidget {
  LandingPageWidget(this.services, {Key? key}) : super(key: key);
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
                    child: LandingPageMarketingWidget(services))),
            Align(
                alignment: Alignment(0.0, -1.0),
                child: Container(
                    height: headerWidgetHeight(context),
                    child:
                        HeaderWidget(services, currentProjectId != null, ''))),
          ],
        ));
  }
}
