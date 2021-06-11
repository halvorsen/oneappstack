// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import '../../common_model/utilities.dart';
import '../../common_widget/rounded_button.dart';
import '../../common_widget/decorated_container.dart';

abstract class SchemaWidgetDelegate {
  void add(SchemaType type, String id);
  void subtract(SchemaType type, String id);
  void delete(SchemaType type, String id);
  void toggleIsBase(SchemaType type, String id, bool isBaseSchema);
  void showEditor(
      SchemaType type,
      String id,
      int index,
      String editString,
      String editorDisplayTitle,
      List<String> invalidStrings,
      BuildContext context);
  void validSchemaEdit(
      SchemaType type, String id, int? index, String validChange);
}

class SchemaWidget extends StatelessWidget {
  final String schemaId;
  final String name;
  final List<String> pathElements;
  final double columnSpacing;
  final double schemaWidgetRowHeight;
  final SchemaType type;
  final bool isEditing;
  final SchemaWidgetDelegate delegate;
  final bool isBaseSchema;
  final String? linkedDocumentName;
  final List<String> allDocumentNames;
  final List<String> allSchemaNames;
  final BuildContext parentContext;

  SchemaWidget(
      this.schemaId,
      this.name,
      this.isBaseSchema,
      this.pathElements,
      this.columnSpacing,
      this.schemaWidgetRowHeight,
      this.type,
      this.isEditing,
      this.delegate,
      this.linkedDocumentName,
      this.allDocumentNames,
      this.allSchemaNames,
      this.parentContext,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(Container(
      width: 20,
    ));
    var invalidNameStrings = List<String>.from(allSchemaNames);
    invalidNameStrings.remove(name);
    if (!isEditing) {
      children.add(Padding(
          padding: EdgeInsets.only(top: 3),
          child: Container(
              width: 40,
              height: 40,
              child: Checkbox(
                  value: isBaseSchema,
                  onChanged: (newValue) =>
                      delegate.toggleIsBase(type, schemaId, newValue!)))));
      children.add(Container(width: 10));
    }
    children.add(Center(
        child: Container(
            width: varyForScreenWidth(200, 200, 160, 160, context),
            child: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: isEditing
                    ? Container(
                        height: 40,
                        child: TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(
                                  fontSize: varyForScreenWidth(
                                      25, 25, 22, 22, context),
                                  fontWeight: FontWeight.w400,
                                  color: Colors.blue)),
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () => delegate.showEditor(
                              type,
                              schemaId,
                              -2,
                              name,
                              'Edit Path Name',
                              invalidNameStrings,
                              parentContext),
                        ))
                    : Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize:
                                varyForScreenWidth(25, 25, 22, 22, context),
                            fontWeight: FontWeight.w400,
                            color: black28))))));
    var isCollection = true;
    for (var i = 0; i < pathElements.length; i++) {
      children.add(Container(
        width: 30,
      ));
      children.add(Center(
          child: Column(children: [
        Container(height: 12),
        Text('/',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w100,
                color: Colors.black87))
      ])));
      children.add(Container(
        width: 30,
      ));
      children.add(Center(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            (type == SchemaType.firestore)
                ? Padding(
                    padding: EdgeInsets.fromLTRB(0, 2, 5, 0),
                    child: Icon(
                      isCollection ? Icons.list : Icons.description,
                      color: black28,
                      size: 15.0,
                    ))
                : Container(),
            Container(height: (type == SchemaType.firestore) ? 5 : 0),
            isEditing
                ? Container(
                    height: 40,
                    child: TransparentButton(
                      pathElements[i],
                      () => delegate.showEditor(type, schemaId, i,
                          pathElements[i], 'Edit Path', [], parentContext),
                    ))
                : Text(pathElements[i],
                    style: Theme.of(context).textTheme.headline3),
            Container(
              height: (type == SchemaType.firestore) ? 3 : 0,
            ),
          ])));
      isCollection = (!isCollection);
    }
    children.add(Container(
      width: 10,
    ));
    if (type != SchemaType.storage) {
      children.add(Center(
          child: Padding(
              padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
              child: Icon(
                Icons.arrow_right_alt,
                color: black28,
                size: 22.0,
              ))));
      children.add(Container(
        width: 20.0,
      ));
      children.add(Center(
        child: Container(
            height: 40.0,
            child: isEditing
                ? DropdownButton<String>(
                    hint: Text('link document',
                        style: TextStyle(color: Colors.blue)),
                    value: linkedDocumentName,
                    items: (['none'] + allDocumentNames).map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        delegate.validSchemaEdit(type, schemaId, -1, value!),
                  )
                : Center(
                    child: Text(linkedDocumentName ?? 'none',
                        style: Theme.of(context).textTheme.headline3),
                  )),
      ));
    }
    if (isEditing) {
      children.add(
        Container(width: 30.0),
      );
      children.add(Center(
        child: Container(
            width: 40.0,
            height: 40.0,
            child: RoundedIconButton(
                Icons.add, () => delegate.add(type, schemaId),
                insets: EdgeInsets.zero)),
      ));
      children.add(
        Container(width: 5.0),
      );
      children.add(Center(
        child: Container(
            width: 40.0,
            height: 40.0,
            child: RoundedIconButton(
                Icons.remove, () => delegate.subtract(type, schemaId),
                insets: EdgeInsets.zero)),
      ));
      children.add(
        Container(width: 50.0),
      );
      children.add(Center(
          child: Container(
              width: 100.0,
              height: 40.0,
              child: RoundedIconButton(
                  Icons.delete, () => delegate.delete(type, schemaId),
                  color: Colors.red))));
      children.add(
        Container(width: 50.0),
      );
    }

    return Padding(
        key: UniqueKey(),
        padding: EdgeInsets.symmetric(vertical: columnSpacing, horizontal: 0.0),
        child: DecoratedContainer(
            radius: 0.0,
            height: schemaWidgetRowHeight,
            child: Container(
                width: screenWidth(context),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: children,
                ))));
  }
}
