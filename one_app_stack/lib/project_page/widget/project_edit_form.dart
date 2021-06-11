// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:one_app_stack/common_widget/rounded_button.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import '../../project_page/bloc/project_config_helper.dart';
import '../../common_model/utilities.dart';

abstract class ProjectEditFormDelegate {
  void exitDocument(BuildContext context);
  void save(String? id, String name, String? config, String? configIos,
      String? configAndroid, BuildContext context);
}

class ProjectEditForm extends StatefulWidget {
  final ProjectEditFormDelegate delegate;
  final bool isOnlyEditingConfig;
  final String? config;
  final String? configIos;
  final String? configAndroid;
  final String? name;
  final String? id;
  ProjectEditForm(this.id, this.delegate, this.isOnlyEditingConfig,
      {this.name, this.config, this.configIos, this.configAndroid});
  @override
  _ProjectEditFormState createState() {
    return _ProjectEditFormState();
  }
}

class _ProjectEditFormState extends State<ProjectEditForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    name = widget.name;
    config = widget.config;
    configIos = widget.configIos;
    configAndroid = widget.configAndroid;
    super.initState();
  }

  List<Widget> _formTitle(String title, BuildContext context) {
    final gapWidth = 0.01 * screenWidth(context);
    return [
      Container(width: _standardPadding(context)),
      Container(
          width: _standardPadding(context),
          height: _standardSize,
          child: Text(title, style: Theme.of(context).textTheme.headline1)),
      Container(width: gapWidth),
    ];
  }

  Row _nameEntryRow(BuildContext context) {
    return Row(
      children: _formTitle('name', context) +
          [
            Container(
                height: _standardSize,
                width: _columnTwoWidth(context),
                decoration: BoxDecoration(
                  color: grayda,
                  borderRadius: BorderRadius.circular(_standardSize * 0.5),
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        bottom: _standardSpacing,
                        left: _standardSpacing,
                        right: _standardSpacing),
                    hintText: 'firebase-project-name',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  initialValue: null,
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  validator: _nameValidator,
                )),
            Container(width: _standardPadding(context)),
          ],
    );
  }

  Row _configEntryRow(BuildContext context) {
    return Row(
      children: _formTitle('config', context) +
          [
            Container(
                height: _standardSize * 7,
                width: _columnTwoWidth(context),
                decoration: BoxDecoration(
                  color: grayda,
                  borderRadius: BorderRadius.circular(_standardSize * 0.25),
                ),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: TextStyle(letterSpacing: 2.0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                        top: _standardSpacing * 2,
                        left: _standardSpacing,
                        right: _standardSpacing,
                        bottom: _standardSpacing * 2),
                    hintText: exampleConfig,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  initialValue: config,
                  onChanged: (value) => config = value,
                  validator: _configValidator,
                )),
            Container(width: _standardPadding(context)),
          ],
    );
  }

  String? name;
  String? config;
  String? configIos;
  String? configAndroid;

  String? _nameValidator(String? value) {
    final invalidCharacters = ['.', '\$', '[', ']', '#', '/', '%'];
    var hasInvalidCharacters = false;
    invalidCharacters.forEach((element) {
      if (value?.contains(element) ?? false) {
        hasInvalidCharacters = true;
      }
    });
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    } else if (hasInvalidCharacters) {
      return 'invalid characters, \"\$ [ ] # . / %\"';
    } else if (value.contains(' ')) {
      return 'cannot contain spaces';
    } else if (value == 'none' || value == 'null') {
      return 'invalid name';
    }
    return null;
  }

  String? _configValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'no config, can add later in Settings';
    }
    final map = ProjectConfigHelper.parseConfig('', value);
    if (map == null) {
      return 'invalid config';
    }
    if (map['apiKey'] == null) {
      return 'missing apiKey';
    }
    if (map['databaseURL'] == null) {
      return 'missing databaseURL';
    }
    if (map['projectId'] == null) {
      return 'missing projectId';
    }
    if (map['storageBucket'] == null) {
      return 'missing storageBucket';
    }
    if (map['messagingSenderId'] == null) {
      return 'missing messagingSenderId';
    }
    if (map['measurementId'] == null) {
      return 'missing measurementId';
    }
    return null;
  }

  double _columnTwoWidth(BuildContext context) => 0.45 * screenWidth(context);
  double _standardPadding(BuildContext context) => 0.1 * screenWidth(context);
  double _standardSize = 40.0;
  double _standardSpacing = 10.0;

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      widget.isOnlyEditingConfig ? Container() : _nameEntryRow(context),
      widget.isOnlyEditingConfig ? Container() : Container(height: 20),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: _standardPadding(context)),
          child: Text(
              'Add Firebase Web App to your project then go to: console > project > project settings.\ncopy and paste your project\'s configuration\nFor Example:',
              style: Theme.of(context).textTheme.headline1)),
      Container(height: 20),
      Container(
          height: 400,
          width: _columnTwoWidth(context),
          child: Image.asset(
            'assets/images/config_screenshot.png',
            fit: BoxFit.contain,
          )),
      Container(height: 20),
      _configEntryRow(context),
      Container(height: 20),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: _standardPadding(context)),
          child: Text(
              (configIos == null)
                  ? 'To use One App Stack on iOS, add Firebase iOS App to your project then go to: console > project > project settings. Download Google-Service-Info.plist'
                  : 'iOS plist:',
              style: Theme.of(context).textTheme.headline1)),
      Container(height: 20),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: _standardPadding(context)),
          child: (configIos == null)
              ? Container(
                  width: 200,
                  height: 60,
                  child: RoundedButton(exampleIosFile, () => filePopup(false)))
              : GestureDetector(
                  onTap: () => filePopup(false),
                  child: Text(configIos ?? '',
                      style: Theme.of(context).textTheme.bodyText1))),
      Container(height: 40),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: _standardPadding(context)),
          child: Text(
              (configAndroid == null)
                  ? 'To use One App Stack on Android, add Firebase Android App to your project then go to: console > project > project settings. Download Google-Services.json'
                  : 'Android JSON:',
              style: Theme.of(context).textTheme.headline1)),
      Container(height: 20),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: _standardPadding(context)),
          child: (configAndroid == null)
              ? Container(
                  width: 200,
                  height: 60,
                  child:
                      RoundedButton(exampleAndroidFile, () => filePopup(true)))
              : GestureDetector(
                  onTap: () => filePopup(true),
                  child: Text(configAndroid ?? '',
                      style: Theme.of(context).textTheme.bodyText1))),
      Container(height: 40),
    ];
    return Container(
        width: screenWidth(context) * 0.8,
        height: screenHeight(context) * 0.8,
        child: Center(
            child: Form(
                key: _formKey,
                child: Column(children: [
                  Container(
                    height: _standardSpacing,
                  ),
                  Container(
                      height: 50,
                      child: Row(
                        children: [
                          Container(width: 20),
                          Container(
                              width: 80,
                              height: _standardSize,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        (name != null)
                                            ? Colors.blue
                                            : Colors.blue.withAlpha(20))),
                                onPressed: (name != null)
                                    ? () {
                                        if (_formKey.currentState!.validate()) {
                                          widget.delegate.save(
                                              widget.id,
                                              name!,
                                              config,
                                              configIos,
                                              configAndroid,
                                              context);
                                          widget.delegate.exitDocument(context);
                                          snackBar(
                                            content: 'Success',
                                            context: context,
                                          );
                                        } else {
                                          if (name == null ||
                                              _nameValidator(name) != null) {
                                            snackBar(
                                                content:
                                                    'Must create a project name',
                                                context: context,
                                                warningColor: true);
                                          } else {
                                            widget.delegate.save(
                                                widget.id,
                                                name!,
                                                config,
                                                configIos,
                                                configAndroid,
                                                context);
                                            widget.delegate
                                                .exitDocument(context);
                                            snackBar(
                                                content:
                                                    'Invalid config, can add later in Settings',
                                                context: context,
                                                warningColor: true);
                                          }
                                        }
                                      }
                                    : null,
                                child: Text('Submit',
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                              )),
                          Container(width: 20),
                        ],
                      )),
                  Container(height: _standardSize),
                  Expanded(child: ListView(children: children)),
                ]))));
  }

  Future<void> filePopup(bool isAndroid) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final data = result.files.single.bytes;
      if (data != null) {
        final string = utf8.decode(data, allowMalformed: true);
        if (isAndroid) {
          configAndroid = string;
          currentProjectConfigStringAndroid = string;
        } else {
          configIos = string;
          currentProjectConfigStringIos = string;
        }
      }
      setState(() {});
    }
    /*                    final file = OpenFilePicker()
                      ..filterSpecification = {
                        'Word Document (*.doc)': '*.doc',
                        'Web Page (*.htm; *.html)': '*.htm;*.html',
                        'Text Document (*.txt)': '*.txt',
                        'All Files': '*.*'
                      }
                      ..defaultFilterIndex = 0
                      ..defaultExtension = 'doc'
                      ..title = 'Select a document';

                    final result = file.getFile();
                    if (result != null) {
                      print(result.path);
                    } */
  }
}
