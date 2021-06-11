// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:one_app_stack/common_widget/popover/textfield_popover_widget.dart';
import 'package:one_app_stack/common_widget/rounded_button.dart';

import '../../common_widget/popover/popover_notifications.dart';
import '../../main_common.dart';
import '../../project_page/widget/project_edit_form.dart';
import '../../settings/widget/privacy.dart';

import '../../common_model/utilities.dart';

import '../../common_widget/decorated_container.dart';
import 'package:flutter/material.dart';

import '../../one_stack.dart';

class SettingsRowWidget extends StatefulWidget {
  SettingsRowWidget(this.services, {Key? key}) : super(key: key);
  final CommonServices services;
  @override
  _SettingsRowWidgetState createState() => _SettingsRowWidgetState();
}

class _SettingsRowWidgetState extends State<SettingsRowWidget>
    with ProjectEditFormDelegate {
  final primaryPadding = 20.0;
  final secondaryPadding = 19.0;
  var showActivityIndicator = false;
  @override
  Widget build(BuildContext context) {
    final edgePadding = varyForScreenWidth(50.0, 50.0, 20.0, 20.0, context);
    if (authData == null) {
      if (currentProjectId != null) {
        widget.services.storage.observeAuthInfo(currentProjectId!, (authInfo) {
          authData = authInfo;
          showActivityIndicator = false;
          setState(() {});
        });
      }
    }
    return Stack(children: [
      ListView(
        children: [
          Padding(
              padding: EdgeInsets.symmetric(
                  vertical: primaryPadding, horizontal: edgePadding),
              child: Container()),
          (currentProjectId == null)
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: primaryPadding, horizontal: edgePadding),
                  child: Text('Users and Permissions',
                      style: Theme.of(context).textTheme.headline5)),
          (currentProjectId == null)
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: primaryPadding, horizontal: edgePadding),
                  child: (permissionLevel == UserPermissionLevel.Admin)
                      ? _adminUsersWidget()
                      : _usersWidget()),
          Container(height: 50),
          (currentProjectId == null)
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: primaryPadding, horizontal: edgePadding),
                  child: Text('Project Settings',
                      style: Theme.of(context).textTheme.headline5)),
          (currentProjectId == null)
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: primaryPadding, horizontal: edgePadding),
                  child: _currentProjectSettings()),
          (currentProjectId == null) ? Container() : Container(height: 50),
          Padding(
              padding: EdgeInsets.symmetric(
                  vertical: primaryPadding, horizontal: edgePadding),
              child: Text('Account Settings',
                  style: Theme.of(context).textTheme.headline5)),
          Padding(
              padding: EdgeInsets.symmetric(
                  vertical: primaryPadding, horizontal: edgePadding),
              child: _accountSettings()),
        ],
      ),
      (showActivityIndicator)
          ? IgnorePointer(
              child: Container(
                  color: Colors.transparent,
                  height: screenHeight(context),
                  width: screenWidth(context)))
          : Container(),
      (showActivityIndicator)
          ? Center(
              child: Container(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.black54))))
          : Container(),
    ]);
  }

  Widget _usersWidget() {
    if (currentProjectId != null) {
      final docs = authData ?? [];
      var children = <Widget>[];
      for (var doc in docs) {
        children.add(_userWidget(doc['email'], doc['permission']));
      }
      return Column(children: children);
    } else {
      return Container();
    }
  }

  List<Map<String, dynamic>>? authData;

  Widget _adminUsersWidget() {
    if (currentProjectId != null) {
      final docs = authData ?? [];
      var children = <Widget>[];
      children.addAll([
        Container(
            width: 40,
            height: 40,
            child: RoundedIconButton(Icons.add, () {
              _newUserEntry_Popup(context);
            }, insets: EdgeInsets.zero)),
        Container(height: 20)
      ]);
      for (var doc in docs) {
        children.add(_admin_UserWidget(doc['email'], doc['permission']));
      }
      children.add(Container(
        height: 20,
      ));
      children.add(
        Container(
            width: 200,
            height: 60,
            child: RoundedButton(
              'Delete Project',
              () {
                _removeProject();
              },
              textStyle: TextStyle(color: Colors.red),
            )),
      );
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children);
    } else {
      return Container();
    }
  }

  void _newUserEntry_Popup(BuildContext context) {
    ShowPopOverNotification(context, LayerLink(),
            popChild: Container(
                width: 500,
                height: 280,
                child: TextFieldPopoverWidget('New User, Email:', null, '', [],
                    (email) => _addNewUser(email), true,
                    requireValidation: false)),
            dismissOnBarrierClick: false)
        .dispatch(context);
  }

  Future<void> _addNewUser(String email) async {
    showActivityIndicator = true;
    setState(() {});
    await widget.services.storage.saveProjectAuth(currentProjectId!, email,
        UserPermissionHelper.levelString(UserPermissionLevel.Reader));
  }

  Widget _admin_UserWidget(String email, String permissionLevel) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: DecoratedContainer(
            height: 70,
            child: Row(
              children: [
                Container(
                  width: primaryPadding,
                ),
                Expanded(child: Text(email)),
                Container(
                  width: primaryPadding,
                ),
                DropdownButton<String>(
                    value: permissionLevel,
                    items: ([
                      UserPermissionHelper.levelString(
                          UserPermissionLevel.Admin),
                      UserPermissionHelper.levelString(
                          UserPermissionLevel.Developer),
                      UserPermissionHelper.levelString(
                          UserPermissionLevel.Editor),
                      UserPermissionHelper.levelString(
                          UserPermissionLevel.Reader),
                    ]).map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _changeAuth(email, value!);
                    }),
                Container(
                  width: primaryPadding,
                ),
                Container(
                    width: 40,
                    height: 40,
                    child: RoundedIconButton(Icons.delete, () {
                      _removeUser(email);
                    }, color: Colors.red, insets: EdgeInsets.zero)),
                Container(
                  width: primaryPadding,
                ),
              ],
            )));
  }

  Widget _userWidget(String email, String permissionLevel) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: DecoratedContainer(
            height: 70,
            child: Row(
              children: [
                Container(
                  width: primaryPadding,
                ),
                Expanded(child: Text(email)),
                Container(
                  width: primaryPadding,
                ),
                Text(permissionLevel.toString()),
                Container(
                  width: primaryPadding,
                ),
              ],
            )));
  }

  Future<List<dynamic>> _adminEmails() async {
    var permissions =
        await widget.services.storage.loadProjectAuth(currentProjectId!);
    permissions = permissions
        .where((element) =>
            element['permission'] ==
            UserPermissionHelper.levelString(UserPermissionLevel.Admin))
        .toList();

    return permissions.map((e) => e['email']).toList();
  }

  Future<bool> _canRemoveUserPermission(String email) async {
    final admins = await _adminEmails();
    if (email != widget.services.auth.currentUserEmail() &&
        (!admins.contains(email) || admins.length > 1)) {
      return true;
    }
    return false;
  }

  Future<bool> _canChangePermission(String email) async {
    final admins = await _adminEmails();
    if (email != widget.services.auth.currentUserEmail() &&
        (!admins.contains(email) || admins.length > 1)) {
      return true;
    }
    return false;
  }

  Future<void> _removeUser(String email) async {
    final canRemove = await _canRemoveUserPermission(email);
    if (canRemove) {
      showActivityIndicator = true;
      setState(() {});
      widget.services.storage.removeProjectAuth(currentProjectId!, email);
    }
  }

  void _removeProject() async {
    ShowPopOverNotification(context, LayerLink(),
            popChild: Container(
              width: 400,
              height: 200,
              child: Column(
                children: [
                  Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Irreversible Action: Delete Project',
                          style: Theme.of(context).textTheme.headline1)),
                  Container(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          height: 50,
                          width: 200,
                          child: BlueGrayButton('Cancel', () {
                            ClosePopoverNotification().dispatch(context);
                          })),
                      Container(width: 20),
                      Container(
                          height: 50,
                          width: 100,
                          child: RedGrayButton('Delete', () async {
                            await widget.services.storage
                                .removeProject(currentProjectId!);
                            currentProjectName = null;
                            currentProjectId = null;
                            currentProjectConfigString = null;
                            currentProjectConfigStringIos = null;
                            currentProjectConfigStringAndroid = null;
                            permissionLevel = null;
                            ClosePopoverNotification().dispatch(context);
                            widget.services.appNavigation
                                .navigateToLandingPage(context);
                          }, insets: EdgeInsets.zero)),
                    ],
                  )
                ],
              ),
            ),
            dismissOnBarrierClick: true)
        .dispatch(context);
  }

  Future<void> _changeAuth(String email, String permission) async {
    final canChange = await _canChangePermission(email);
    if (canChange) {
      showActivityIndicator = true;
      setState(() {});
      await widget.services.storage
          .saveProjectAuth(currentProjectId!, email, permission);
    }
  }

  Widget _currentProjectSettings() {
    final redStyle = TextStyle(
        fontSize: 18,
        height: 1.4,
        fontWeight: FontWeight.normal,
        color: Colors.red);
    final hasConfig = currentProjectConfigString != null;
    final hasAndroidConfig = currentProjectConfigStringAndroid != null;
    final hasIosConfig = currentProjectConfigStringIos != null;
    final correction =
        ((hasAndroidConfig) ? 0.0 : 1050.0) + ((hasIosConfig) ? 0.0 : 850.0);
    return DecoratedContainer(
      height: varyForScreenWidth(2800, 2800, 2800, 2800, context) - correction,
      child: Padding(
          padding: EdgeInsets.all(primaryPadding),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.all(primaryPadding),
                      child: Text('project name',
                          style: Theme.of(context).textTheme.headline2)),
                  (currentProjectConfig?['projectId'] == null)
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.all(primaryPadding),
                          child: Text('firebase id',
                              style: Theme.of(context).textTheme.headline2)),
                  Padding(
                      padding: EdgeInsets.all(primaryPadding),
                      child: Text('one app stack id',
                          style: Theme.of(context).textTheme.headline2)),
                  Padding(
                      padding: EdgeInsets.all(primaryPadding),
                      child: Container(
                          height: 300,
                          child: TextButton(
                              onPressed: () {
                                _configPopup();
                              },
                              child: Text('config',
                                  style:
                                      Theme.of(context).textTheme.headline2)))),
                  Padding(
                      padding: EdgeInsets.all(primaryPadding),
                      child: TextButton(
                          onPressed: () {
                            _configPopup();
                          },
                          child: Container(
                              height: hasIosConfig ? 900 : 50,
                              child: Text('ios plist',
                                  style:
                                      Theme.of(context).textTheme.headline2)))),
                  Padding(
                      padding: EdgeInsets.all(primaryPadding),
                      child: TextButton(
                          onPressed: () {
                            _configPopup();
                          },
                          child: Container(
                              height: hasAndroidConfig ? 1100 : 50,
                              child: Text('android json',
                                  style:
                                      Theme.of(context).textTheme.headline2)))),
                  Expanded(child: Container())
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (currentProjectId == null)
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.all(primaryPadding),
                          child: Text(currentProjectName!,
                              style: Theme.of(context).textTheme.headline2)),
                  (currentProjectConfig?['projectId'] == null)
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.all(primaryPadding),
                          child: Text(currentProjectConfig?['projectId']!,
                              style: Theme.of(context).textTheme.headline2,
                              softWrap: true)),
                  (currentProjectId == null)
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.all(primaryPadding),
                          child: Text(currentProjectId!,
                              style: Theme.of(context).textTheme.headline2)),
                  Padding(
                      padding: EdgeInsets.all(primaryPadding),
                      child: Container(
                          height: 300,
                          child: TextButton(
                              onPressed: () {
                                _configPopup();
                              },
                              child: Text(
                                varyForScreenWidth(
                                    currentProjectConfigString ?? exampleConfig,
                                    currentProjectConfigString ?? exampleConfig,
                                    'const firebaseConfig = {...}',
                                    'const firebaseConfig = {...}',
                                    context),
                                style: (hasConfig)
                                    ? Theme.of(context).textTheme.headline2
                                    : redStyle,
                                softWrap: true,
                              )))),
                  Padding(
                      padding: EdgeInsets.all(primaryPadding),
                      child: TextButton(
                          onPressed: () {
                            _configPopup();
                          },
                          child: Container(
                              height: hasIosConfig ? 900 : 50,
                              child: Text(
                                currentProjectConfigStringIos ?? exampleIosFile,
                                style: (hasIosConfig)
                                    ? Theme.of(context).textTheme.headline2
                                    : redStyle,
                                softWrap: true,
                              )))),
                  Padding(
                      padding: EdgeInsets.all(primaryPadding),
                      child: TextButton(
                          onPressed: () {
                            _configPopup();
                          },
                          child: Container(
                              height: hasAndroidConfig ? 1100 : 50,
                              child: Text(
                                currentProjectConfigStringAndroid ??
                                    exampleAndroidFile,
                                style: (hasAndroidConfig)
                                    ? Theme.of(context).textTheme.headline2
                                    : redStyle,
                                softWrap: true,
                              )))),
                ],
              )
            ],
          )),
    );
  }

  void _configPopup() {
    ShowPopOverNotification(context, LayerLink(),
            popChild: ProjectEditForm(
              currentProjectId,
              this,
              true,
              name: currentProjectName,
              config: currentProjectConfigString,
              configAndroid: currentProjectConfigStringAndroid,
              configIos: currentProjectConfigStringIos,
            ),
            dismissOnBarrierClick: true)
        .dispatch(context);
  }

  void _popup(String text) {
    ShowPopOverNotification(context, LayerLink(),
            popChild: Container(
              width: screenWidth(context) * 0.8,
              height: screenHeight(context) * 0.8,
              child: ListView(
                children: [
                  Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        text,
                        style: varyForScreenWidth(
                            Theme.of(context).textTheme.bodyText1,
                            Theme.of(context).textTheme.bodyText2,
                            Theme.of(context).textTheme.bodyText2,
                            Theme.of(context).textTheme.bodyText2,
                            context),
                      ))
                ],
              ),
            ),
            dismissOnBarrierClick: true)
        .dispatch(context);
  }

  Widget _accountSettings() {
    return DecoratedContainer(
      child: Padding(
          padding: EdgeInsets.all(primaryPadding),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (widget.services.auth.currentUserEmail() == null)
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.all(primaryPadding),
                          child: TextButton(
                              onPressed: () {},
                              child: Text('user info',
                                  style:
                                      Theme.of(context).textTheme.headline2))),
                  Padding(
                      padding: EdgeInsets.all(primaryPadding),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LicensePage(
                                        applicationName: 'One App Stack',
                                        applicationIcon: Image.asset(
                                            'assets/images/one_app_stack_icon.png'))));
                          },
                          child: Text('attribution',
                              style: Theme.of(context).textTheme.headline2))),
                  Padding(
                      padding: EdgeInsets.all(primaryPadding),
                      child: TextButton(
                          onPressed: () => _popup(PrivacyTerms.termsText),
                          child: Text('terms of service',
                              style: Theme.of(context).textTheme.headline2))),
                  Padding(
                      padding: EdgeInsets.all(primaryPadding),
                      child: TextButton(
                          onPressed: () => _popup(PrivacyTerms.privacyText),
                          child: Text('privacy policy',
                              style: Theme.of(context).textTheme.headline2)))
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (widget.services.auth.currentUserEmail() == null)
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.all(secondaryPadding),
                          child: TextButton(
                              onPressed: () {},
                              child: Text(
                                  widget.services.auth.currentUserEmail()!,
                                  style:
                                      Theme.of(context).textTheme.headline2))),
                  Padding(
                      padding: EdgeInsets.all(secondaryPadding),
                      child: RoundedIconButton(Icons.link, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LicensePage()));
                      }, backgroundColor: Colors.transparent)),
                  Padding(
                      padding: EdgeInsets.all(secondaryPadding),
                      child: RoundedIconButton(
                          Icons.link, () => _popup(PrivacyTerms.termsText),
                          backgroundColor: Colors.transparent)),
                  Padding(
                      padding: EdgeInsets.all(secondaryPadding),
                      child: RoundedIconButton(
                          Icons.link, () => _popup(PrivacyTerms.privacyText),
                          backgroundColor: Colors.transparent)),
                ],
              )
            ],
          )),
    );
  }

  @override
  void exitDocument(BuildContext context) {
    ClosePopoverNotification().dispatch(context);
    setState(() {});
  }

  @override
  void save(String? id, String name, String? config, String? configIos,
      String? configAndroid, BuildContext context) {
    //only overwrite the configs here, when changing configs should restart app

    void _setOtherApp(BuildContext context) {
      Map<String, dynamic>? configMap;
      switch (widget.services.platform.platform) {
        case AppPlatform.web:
          configMap = currentProjectConfig;
          break;
        case AppPlatform.ios:
        case AppPlatform.mac:
          configMap = currentProjectConfigIos;
          break;
        case AppPlatform.android:
          configMap = currentProjectConfigAndroid;
          break;
        default:
          configMap = currentProjectConfig;
      }
      if (configMap != null) {
        try {
          widget.services.storage.setOtherApp(configMap);
        } catch (error) {}
      }
    }

    widget.services.storage
        .loadProjectInfo(currentProjectId!)
        .then((projectInfo) {
      projectInfo.firebaseConfig = config;
      projectInfo.firebaseConfigIos = configIos;
      projectInfo.firebaseConfigAndroid = configAndroid;

      widget.services.storage
          .saveProjectInfo(currentProjectId!, projectInfo)
          .then((_) {
        currentProjectConfigString = config;
        currentProjectConfigStringIos = configIos;
        currentProjectConfigStringAndroid = configAndroid;
        setState(() {});
        try {
          _setOtherApp(context);
        } catch (error) {}
      });
    });
  }
}
