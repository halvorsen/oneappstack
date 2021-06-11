// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../common_widget/popover/textfield_popover_widget.dart';
import '../../common_model/utilities.dart';
import '../../common_widget/decorated_container.dart';
import '../../common_widget/rounded_button.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';

import '../../one_stack.dart';
import 'navigation_widget.dart';

abstract class DocumentFormDelegate {
  void exitDocument();
  void saveValidValues(List<DocumentProperty> values,
      Map<String, Uint8List> filesToSave, List<String> filesToDelete);
  void remove(String id, int index);
  void add(String id);
  void deleteDocument(String documentId);
  void didSelect(NavigationElement navigationElement);
}

class DocumentForm extends StatefulWidget {
  static final documentNameForFiles = 'Add To Directory';
  final String documentId;
  final String name;
  final List<DocumentProperty> selectedDocument;
  final DocumentFormDelegate delegate;
  final Future<Uri> Function(String filename) getFileUri;
  final bool isFileStorageDocument;
  final CommonServices services;
  DocumentForm(
      this.documentId,
      this.name,
      this.selectedDocument,
      this.getFileUri,
      this.delegate,
      this.isFileStorageDocument,
      this.services);
  @override
  _DocumentFormState createState() {
    return _DocumentFormState();
  }
}

class _DocumentFormState extends State<DocumentForm> {
  // this is a little big and can get broken down a bit by seperating concerns
  final _formKey = GlobalKey<FormState>();
  late List<DocumentProperty> mutableSelectedDocument;
  final fileDatas = <String, Uint8List?>{};
  final fileUris = <String, Uri?>{};
  var pendingSaveFilenames = <String>[];
  var pendingDeleteFilenames = <String>[];
  @override
  void initState() {
    documentName = widget.name;
    mutableSelectedDocument =
        List<DocumentProperty>.from(widget.selectedDocument);
    super.initState();
  }

  @override
  void dispose() {
    nameStreamController.close();
    super.dispose();
  }

  Future<void> _fetchImageUri(String filename) async {
    final uri = await widget.getFileUri(filename);
    fileUris[filename] = uri;
  }

  Widget _rowWidget(DocumentProperty property, BuildContext context) {
    switch (property.type) {
      case PropertyType.DocumentString:
      case PropertyType.DocumentDouble:
      case PropertyType.DocumentInt:
        return _singleEntryRow(property, context);
      case PropertyType.DocumentFile:
        return _singleFileRow(property, context);
      case PropertyType.DocumentStringList:
      case PropertyType.DocumentDoubleList:
      case PropertyType.DocumentIntList:
        return _multiEntryRow(property, context);
      case PropertyType.DocumentFileList:
        return _multiFileRow(property, context);
      case PropertyType.Branch:
        return _schemaBranch(property, context);
      case PropertyType.RequiredProperty:
        return Container();
    }
  }

  Widget _textfieldFactory(
      PropertyType type, dynamic initialValue, String id, int index,
      {bool isNewListValue = false}) {
    switch (type) {
      case PropertyType.DocumentString:
        return _stringTextField(initialValue, 'enter text', id, index,
            isNewListValue: isNewListValue);
      case PropertyType.DocumentInt:
        return _intTextField(initialValue, 'enter integer', id, index,
            isNewListValue: isNewListValue);
      case PropertyType.DocumentDouble:
        return _doubleTextField(initialValue, 'enter double', id, index,
            isNewListValue: isNewListValue);
      case PropertyType.DocumentStringList:
        return _stringTextField(initialValue, 'new text', id, index,
            isNewListValue: isNewListValue);
      case PropertyType.DocumentIntList:
        return _intTextField(initialValue, 'new integer', id, index,
            isNewListValue: isNewListValue);
      case PropertyType.DocumentDoubleList:
        return _doubleTextField(initialValue, 'new double', id, index,
            isNewListValue: isNewListValue);
      default:
        return Container();
    }
  }

  Widget _schemaBranch(DocumentProperty property, BuildContext context) {
    final documentMap = Map<String, String>.from(property.value);
    final id = documentMap['id']!;
    final name = documentMap['name']!;
    return Row(
        children: _formTitle(property, context) +
            [
              Padding(
                  padding: EdgeInsets.symmetric(vertical: _standardSpacing),
                  child: Container(
                      width: 0.45 * screenWidth(context),
                      height: _standardSize * 1.5,
                      child: RoundedButton(
                          name,
                          () => widget.delegate.didSelect(
                              NavigationElement(id, name, true, false)),
                          fontSize: 30.0)))
            ]);
  }

  List<Widget> _formTitle(DocumentProperty property, BuildContext context) {
    final gapWidth = 0.01 * screenWidth(context);
    return [
      Container(width: _standardPadding(context)),
      Container(
          width: _standardPadding(context),
          height: _standardSize,
          child: Text(property.name, style: textStyle(context))),
      Container(width: gapWidth),
    ];
  }

  bool _isThumbnail(String filename) {
    final extensionName = filename.split('.').last;
    if (extensionName == 'png' || extensionName == 'jpg') {
      return true;
    } else {
      return false;
    }
  }

  Widget _addButton(Function action) {
    return Container(
        width: _columnTwoWidth(context),
        child: Row(children: [
          Container(
              height: _standardSize,
              width: _standardSize,
              child: (permissionLevel == UserPermissionLevel.Reader)
                  ? Container()
                  : RoundedIconButton(Icons.add, action,
                      insets: EdgeInsets.zero))
        ]));
  }

  Row _singleFileRow(DocumentProperty property, BuildContext context) {
    return Row(
      children: _formTitle(property, context) +
          [
            (property.value != null)
                ? _fileRow(property.value ?? '', () {
                    property.value = null;
                    recordValue(property.id, null, -1);
                  })
                : _addButton(() async {
                    final result =
                        await widget.services.fileHelper.chooseFile(context);
                    if (result.isNotEmpty) {
                      result.forEach((filename, data) {
                        property.value = filename;
                        recordValue(property.id, property.value, -1);
                        fileDatas[filename] = data;
                        pendingSaveFilenames.add(filename);
                      });
                      setState(() {});
                    } else {
                      // do nothing
                    }
                  })
          ],
    );
  }

  Row _multiFileRow(DocumentProperty property, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _formTitle(property, context) +
          [
            Container(
                width: 0.45 * screenWidth(context),
                child: _listFiles(property)),
            Container(width: _standardPadding(context)),
          ],
    );
  }

  Row _singleEntryRow(DocumentProperty property, BuildContext context) {
    return Row(
      children: _formTitle(property, context) +
          [
            Container(
                height: _standardSize,
                width: _columnTwoWidth(context),
                decoration: BoxDecoration(
                  color: grayda,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _textfieldFactory(
                    property.type, property.value, property.id, -1)),
            Container(width: _standardPadding(context)),
          ],
    );
  }

  Row _multiEntryRow(DocumentProperty property, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _formTitle(property, context) +
          [
            Container(
                width: 0.45 * screenWidth(context),
                child: _listFields(property)),
          ],
    );
  }

  Widget _fileRow(String filename, Function propertyRemoval) {
    return Container(
        width: _columnTwoWidth(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ((fileDatas[filename] ?? fileUris[filename]) != null &&
                  _isThumbnail(filename))
              ? Container(
                  height: 100,
                  child: (fileDatas[filename] != null)
                      ? Image.memory(fileDatas[filename]!)
                      : Image.network(fileUris[filename]!.toString()))
              : Container(),
          Row(children: [
            Container(
                width: varyForScreenWidth(null, null, 200, 200, context),
                child: Text(filename, style: textStyle(context))),
            Container(width: _standardSpacing),
            ((fileDatas[filename] ?? fileUris[filename]) != null)
                ? Container()
                : (_isThumbnail(filename))
                    ? Container(
                        height: _standardSize,
                        width: _standardSize,
                        child: RoundedIconButton(Icons.visibility, () async {
                          await _fetchImageUri(filename);
                          setState(() {});
                        }, insets: EdgeInsets.zero))
                    : Container(),
            Container(width: _standardSpacing),
            Container(
                height: _standardSize,
                width: _standardSize,
                child: RoundedIconButton(Icons.remove, () {
                  fileDatas[filename] = null;
                  fileUris[filename] = null;
                  if (pendingSaveFilenames.contains(filename)) {
                    pendingSaveFilenames.remove(filename);
                  } else {
                    pendingDeleteFilenames.add(filename);
                  }
                  propertyRemoval();
                  setState(() {});
                }, insets: EdgeInsets.zero))
          ]),
        ]));
  }

  Widget _listFiles(DocumentProperty property) {
    var children = <Widget>[];
    final values = List<String>.from(property.value ?? []);
    final length = values.length;
    final addFileAction = () async {
      final result = await widget.services.fileHelper.chooseFile(context);
      if (result.length > 0) {
        final data = result.values.first;
        var currentValue = <String>[];
        if (property.value != null) {
          currentValue = List<String>.from(property.value);
        }
        final filename = result.keys.first;
        currentValue.add(filename);
        property.value = currentValue;
        recordValue(property.id, currentValue, -1);
        fileDatas[filename] = data;
        pendingSaveFilenames.add(filename);
        setState(() {});
      } else {
        // do nothing
      }
    };
    if (length > 25) {
      children.addAll([_addButton(addFileAction), Container(height: 20)]);
    }

    for (var i = 0; i < length; i++) {
      children.add(_fileRow(values[i], () {
        values.removeAt(i);
        property.value = values;
        recordValue(property.id, values, -1);
      }));
    }
    children.add(_addButton(addFileAction));
    return Column(children: children);
  }

  Widget _listFields(DocumentProperty property) {
    Widget _fieldElement(DocumentProperty property, Widget textfield,
        int? index, String title, int length, double width) {
      return Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Container(
              width: width,
              height: _standardSize,
              child: Row(
                children: [
                  Text(title, style: textStyle(context)),
                  Container(width: _standardSpacing),
                  Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                            color: grayda,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: textfield)),
                  (index == null)
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.only(left: _standardSpacing),
                          child: Container(
                              height: _standardSize,
                              width: _standardSize,
                              child: RoundedIconButton(Icons.remove,
                                  () => recordRemoveAt(property.id, index),
                                  insets: EdgeInsets.zero)))
                ],
              )));
    }

    var children = <Widget>[];
    final values = List<String>.from(property.value ?? []);
    final length = values.length;
    if (length > 25) {
      children.add(_fieldElement(
          property,
          _textfieldFactory(property.type, null, property.id, length,
              isNewListValue: true),
          null,
          length.toString() + ':',
          length,
          _columnTwoWidth(context)));
      children.add(Container(height: 20));
    }

    for (var i = 0; i < length; i++) {
      children.add(_fieldElement(
          property,
          _textfieldFactory(property.type, values[i], property.id, i),
          i,
          i.toString() + ':',
          length,
          _columnTwoWidth(context)));
      children.add(Container(height: 20));
    }
    children.add(_fieldElement(
        property,
        _textfieldFactory(property.type, null, property.id, length,
            isNewListValue: true),
        null,
        length.toString() + ':',
        length,
        _columnTwoWidth(context)));
    return Column(children: children);
  }

  Widget _formTextfield(dynamic initialValue, String? hintText, String id,
      int index, String? Function(String?)? validator,
      {bool isNewListValue = false}) {
    return TextFormField(
      key: ValueKey(index.toString() + id + initialValue.toString()),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(
            bottom: _standardSpacing,
            left: _standardSpacing,
            right: _standardSpacing),
        hintText: hintText,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      initialValue: initialValue ?? ((isNewListValue ? null : '')),
      onChanged: (value) {
        recordValue(id, value, index);
        if (isNewListValue) {
          setState(() {});
        }
      },
      validator: validator,
    );
  }

  Widget _stringTextField(
      dynamic initialValue, String hintText, String id, int index,
      {bool isNewListValue = false}) {
    return _formTextfield(initialValue, hintText, id, index, (value) {
      return null;
    }, isNewListValue: isNewListValue);
  }

  Widget _doubleTextField(
      dynamic initialValue, String hintText, String id, int index,
      {bool isNewListValue = false}) {
    return _formTextfield(initialValue, hintText, id, index, (value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      final myDouble = double.tryParse(value);
      if (myDouble == null) {
        return 'invalid double value';
      }
      return null;
    }, isNewListValue: isNewListValue);
  }

  Widget _intTextField(
      dynamic initialValue, String? hintText, String id, int index,
      {bool isNewListValue = false}) {
    return _formTextfield(initialValue, hintText, id, index, (value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      final myDouble = int.tryParse(value);
      if (myDouble == null) {
        return 'invalid int value';
      }
      return null;
    }, isNewListValue: isNewListValue);
  }

  var didDocumentChange = false;
  void recordRemoveAt(String id, int index) {
    didDocumentChange = true;
    for (var i = 0; i < mutableSelectedDocument.length; i++) {
      if (mutableSelectedDocument[i].id == id) {
        var list = List<dynamic>.from(mutableSelectedDocument[i].value);
        list.removeAt(index);
        mutableSelectedDocument[i].value = list;
        setState(() {});
        return;
      }
    }
  }

  void recordValue(String id, dynamic value, int index) {
    didDocumentChange = true;
    for (var i = 0; i < mutableSelectedDocument.length; i++) {
      if (mutableSelectedDocument[i].id == id) {
        if (index == -1) {
          mutableSelectedDocument[i].value = value;
        } else {
          var list = <dynamic>[];
          if (mutableSelectedDocument[i].value != null) {
            list = List<dynamic>.from(mutableSelectedDocument[i].value);
          }
          if (list.length == index) {
            list.add(value);
          } else {
            list[index] = value;
          }
          mutableSelectedDocument[i].value = list;
        }
        return;
      }
    }
  }

  double _columnTwoWidth(BuildContext context) => 0.45 * screenWidth(context);
  double _standardPadding(BuildContext context) => 0.1 * screenWidth(context);
  double _standardSize = 40.0;
  double _standardSpacing = 10.0;
  TextStyle? textStyle(BuildContext context) => varyForScreenWidth(
      Theme.of(context).textTheme.headline1,
      Theme.of(context).textTheme.headline1,
      Theme.of(context).textTheme.bodyText1,
      Theme.of(context).textTheme.bodyText1,
      context);
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    final extendedPaths = mutableSelectedDocument
        .where((element) => element.type == PropertyType.Branch)
        .toList();
    final properties = mutableSelectedDocument
        .where((element) => element.type != PropertyType.Branch)
        .toList();
    if (extendedPaths.isNotEmpty) {
      children.addAll(extendedPaths
          .map((e) => Padding(
              padding: EdgeInsets.only(bottom: _standardSpacing),
              child: _rowWidget(e, context)))
          .toList());
    }
    if (properties.isNotEmpty) {
      children.addAll(properties
          .map((e) => Padding(
              padding: EdgeInsets.only(bottom: _standardSpacing),
              child: _rowWidget(e, context)))
          .toList());
    }
    return Stack(key: ValueKey(widget.name), children: [
      GestureDetector(
        onTap: widget.delegate.exitDocument,
      ),
      Center(
          child: DecoratedContainer(
              width: screenWidth(context) * 0.8,
              height: screenHeight(context) * 0.8,
              child: Stack(children: [
                Form(
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
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.blue)),
                                    onPressed: () {
                                      if (!didDocumentChange) {
                                        return;
                                      }
                                      didDocumentChange = false;
                                      setState(() {});
                                      if (_formKey.currentState!.validate()) {
                                        Map<String, Uint8List> filesToSave = {};
                                        pendingSaveFilenames.forEach((element) {
                                          if (fileDatas[element] != null) {
                                            filesToSave[element] =
                                                fileDatas[element]!;
                                          }
                                        });
                                        pendingSaveFilenames = [];
                                        widget.delegate.saveValidValues(
                                            mutableSelectedDocument,
                                            filesToSave,
                                            pendingDeleteFilenames);
                                        pendingDeleteFilenames = [];
                                        if (widget.isFileStorageDocument) {
                                          widget.delegate.exitDocument();
                                        }
                                        snackBar(
                                            content: 'Success',
                                            context: context);
                                        if (widget.documentId ==
                                            DocumentForm.documentNameForFiles) {
                                          widget.delegate.exitDocument();
                                        }
                                      } else {
                                        snackBar(
                                            content: 'Invalid Data',
                                            context: context,
                                            warningColor: true);
                                      }
                                    },
                                    child: Text('Save'),
                                  )),
                              Container(width: 20),
                              Row(children: [
                                Padding(
                                    padding: EdgeInsets.only(bottom: 7),
                                    child: Text('', style: textStyle(context))),
                                StreamBuilder<String>(
                                    stream: nameStreamController.stream,
                                    initialData: widget.name,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String> snapshot) {
                                      return TransparentButton(
                                        snapshot.data ?? 'Error',
                                        showNameEditor,
                                        fontSize: varyForScreenWidth(
                                            22, 22, 14, 14, context),
                                        insets:
                                            EdgeInsets.symmetric(horizontal: 5),
                                      );
                                    }),
                              ]),
                            ],
                          )),
                      Container(height: _standardSize),
                      Expanded(child: ListView(children: children)),
                    ])),
                widget.isFileStorageDocument
                    ? Container()
                    : Positioned(
                        right: 0,
                        bottom: 0,
                        child: Padding(
                            padding: EdgeInsets.all(_standardSpacing),
                            child: Container(
                                width: _standardSize * 2,
                                height: _standardSize * 2,
                                child: (permissionLevel ==
                                        UserPermissionLevel.Reader)
                                    ? Container()
                                    : RoundedIconButton(Icons.delete, () {
                                        widget.delegate
                                            .deleteDocument(widget.documentId);
                                        widget.delegate.exitDocument();
                                      },
                                        insets: EdgeInsets.zero,
                                        color: Colors.red,
                                        fontSize: 35,
                                        backgroundColor: Colors.transparent))))
              ])))
    ]);
  }

  final nameStreamController = StreamController<String>();
  var documentName = '';
  void showNameEditor() {
    TextFieldPopoverWidget.showTextFieldPopoverWidget(
        context, 'Change Document Name', documentName, null, [''],
        (validChange) {
      recordValue(docName, validChange, -1);
      documentName = validChange;
      nameStreamController.sink.add(validChange);
    }, false);
  }
}
