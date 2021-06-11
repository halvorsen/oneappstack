// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:one_app_stack/main_common.dart';

import '../common_model/utilities.dart';
import '../common_widget/popover/sign_in_screen.dart';

import '../one_stack.dart';
import 'package:flutter/material.dart';

// header widget with some smarts. watches the global state and modifies the header accordingly
class HeaderWidget extends StatefulWidget {
  HeaderWidget(this.services, this.projectIsSelected, this.selected, {Key? key})
      : super(key: key);
  final CommonServices services;
  final bool projectIsSelected;
  final String selected;
  static final projectTitle = 'Projects';
  static final schemasTitle = 'Data-Paths';
  static final managerTitle = 'Manager';
  static final settingsTitle = 'Settings';
  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  bool _hasConfigurationSet() {
    switch (widget.services.platform.platform) {
      case AppPlatform.web:
        return currentProjectConfig != null;
      case AppPlatform.android:
        return currentProjectConfigAndroid != null;
      case AppPlatform.linux:
        return currentProjectConfig != null;
      case AppPlatform.ios:
      case AppPlatform.mac:
        return currentProjectConfigIos != null;
      case AppPlatform.windows:
        return currentProjectConfig != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStyle = TextStyle(
        fontSize: 22, fontWeight: FontWeight.w400, color: Colors.black);
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: varyForScreenWidth(20.0, 20.0, 10.0, 10.0,
                  context), // has the effect of softening the shadow
              spreadRadius: varyForScreenWidth(4.0, 3.0, 2.0, 2.0,
                  context), // has the effect of extending the shadow
              offset: Offset(0.0, -10.0),
            )
          ],
        ),
        child: Stack(
          children: [
            Row(children: [
              Container(
                width: 10,
              ),
              TextButton(
                  onPressed: () => widget.services.appNavigation
                      .navigateToLandingPage(context),
                  child: Row(children: [
                    Image.asset('assets/images/one_app_stack_icon.png'),
                    Text(
                        varyForScreenWidth(
                            'One App Stack', 'One App Stack', '', '', context),
                        style: TextStyle(fontSize: 22, color: Colors.black54)),
                  ])),
            ]),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(width: 10),
                TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(0),
                    ),
                    onPressed: () => widget.services.appNavigation
                        .navigateToProjectsPage(context),
                    child: Text(
                      HeaderWidget.projectTitle,
                      style: (widget.selected == HeaderWidget.projectTitle)
                          ? selectedStyle
                          : Theme.of(context).textTheme.button,
                    )),
                (widget.projectIsSelected &&
                        (permissionLevel == UserPermissionLevel.Admin ||
                            permissionLevel == UserPermissionLevel.Developer))
                    ? Container(width: 10)
                    : Container(),
                (widget.projectIsSelected &&
                        (permissionLevel == UserPermissionLevel.Admin ||
                            permissionLevel == UserPermissionLevel.Developer))
                    ? TextButton(
                        onPressed: () => widget.services.appNavigation
                            .navigateToSchemasPage(context),
                        child: Text(
                          HeaderWidget.schemasTitle,
                          style: (widget.selected == HeaderWidget.schemasTitle)
                              ? selectedStyle
                              : Theme.of(context).textTheme.button,
                        ))
                    : Container(),
                (widget.projectIsSelected && _hasConfigurationSet())
                    ? Container(width: 10)
                    : Container(),
                (widget.projectIsSelected && _hasConfigurationSet())
                    ? TextButton(
                        onPressed: () => widget.services.appNavigation
                            .navigateToManagerPage(context),
                        child: Text(
                          HeaderWidget.managerTitle,
                          style: (widget.selected == HeaderWidget.managerTitle)
                              ? selectedStyle
                              : Theme.of(context).textTheme.button,
                        ))
                    : Container(),
                Container(width: 10),
                TextButton(
                    onPressed: () => widget.services.appNavigation
                        .navigateToSettingsPage(context),
                    child: Text(
                      HeaderWidget.settingsTitle,
                      style: (widget.selected == HeaderWidget.settingsTitle)
                          ? selectedStyle
                          : Theme.of(context).textTheme.button,
                    )),
                Container(width: 5),
                TextButton(
                    onPressed: (widget.services.auth.currentUserEmail() != null)
                        ? () async {
                            await widget.services.auth.signOut(context);
                            currentProjectName = null;
                            currentProjectId = null;
                            currentProjectConfigString = null;
                            currentProjectConfigStringIos = null;
                            currentProjectConfigStringAndroid = null;
                            permissionLevel = null;
                            widget.services.appNavigation
                                .navigateToLandingPage(context);
                            setState(() {});
                          }
                        : () => SigninWidget.showSigninWidget(
                            widget.services, context),
                    child: Text(
                      (widget.services.auth.currentUserEmail() != null)
                          ? 'Sign Out'
                          : 'Sign In',
                      style: Theme.of(context).textTheme.button,
                    )),
                Container(width: 10),
              ],
            )
          ],
        ));
  }
}
