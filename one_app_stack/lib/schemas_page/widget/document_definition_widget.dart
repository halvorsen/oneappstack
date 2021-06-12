// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import '../../common_model/utilities.dart';
import '../../common_widget/rounded_button.dart';
import '../../common_widget/decorated_container.dart';

abstract class DocumentDefinitionDelegate {
  void add(SchemaType type, String id);
  void deleteDocumentProperty(String documentId, String propertyId);
  void delete(SchemaType type, String id);
  void showDocumentPropertyNameEditor(
      String documentId,
      DocumentProperty documentProperty,
      String editorDisplayTitle,
      BuildContext context);
  void validDocumentEdit(String documentId, String propertyId,
      DocumentProperty newDocumentProperty);
}

class DocumentDefinitionWidget extends StatelessWidget {
  final String id;
  final String documentName;
  final List<DocumentProperty> properties;
  final bool isEditing;
  final DocumentDefinitionDelegate delegate;
  final List<SchemaInfo> allSchemaInfos;
  final propertyFieldHeight = 60.0;
  final BuildContext parentContext;

  DocumentDefinitionWidget(this.id, this.documentName, this.properties,
      this.isEditing, this.delegate, this.allSchemaInfos, this.parentContext,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> column1 = [];
    List<Widget> column2 = [];
    List<Widget> column3 = [];
    List<Widget> column4 = [];
    final styleHeader = TextStyle(
        fontSize: varyForScreenWidth(25, 25, 22, 22, context),
        fontWeight: FontWeight.w400,
        color: black28);
    final style = Theme.of(context).textTheme.headline3;
    column1.add(Container(
        height: propertyFieldHeight,
        child: Center(child: Text('name', style: styleHeader))));
    column2.add(Container(
        height: propertyFieldHeight,
        child: Center(child: Text('type', style: styleHeader))));
    column3.add(Container(
        height: propertyFieldHeight,
        child: Center(child: Text('', style: styleHeader))));
    column4.add(Container(height: propertyFieldHeight));
    properties.forEach((property) {
      column1.add(Padding(
          padding: EdgeInsets.fromLTRB(0, (propertyFieldHeight - 40) * 0.5, 0,
              (propertyFieldHeight - 40) * 0.5),
          child: Container(
              height: 40,
              child: isEditing
                  ? TransparentButton(
                      property.name,
                      () => delegate.showDocumentPropertyNameEditor(
                          id, property, 'Edit Property Name', context),
                    )
                  : Center(child: Text(property.name, style: style)))));
      column2.add(Container(
          height: propertyFieldHeight,
          child: Center(
              child: isEditing
                  ? SmallDecoratedContainer(
                      child: Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                  value:
                                      PropertyTypeHelper.string(property.type),
                                  items: PropertyTypeHelper.list(style),
                                  onChanged: (dynamic value) =>
                                      delegate.validDocumentEdit(
                                          id,
                                          property.id,
                                          DocumentProperty(
                                              property.id,
                                              property.name,
                                              PropertyTypeHelper.fromString(
                                                  value),
                                              property.value))))))
                  : Text(PropertyTypeHelper.string(property.type),
                      style: style))));
      final propertyValueName = (property.value != null)
          ? allSchemaInfos
              .firstWhere((element) => element.id == property.value)
              .namePrimary!
          : null;
      column3.add((property.type == PropertyType.Branch)
          ? Container(
              height: propertyFieldHeight,
              child: Center(
                  child: (isEditing && allSchemaInfos.isNotEmpty)
                      ? SmallDecoratedContainer(
                          child: Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                      hint: Text('link schema',
                                          style: TextStyle(color: Colors.blue)),
                                      value: propertyValueName,
                                      items: (['none'] +
                                              allSchemaInfos
                                                  .map((e) => e.namePrimary!)
                                                  .toList())
                                          .map((String value) {
                                        return new DropdownMenuItem<String>(
                                          value: value,
                                          child: new Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (dynamic value) =>
                                          delegate.validDocumentEdit(
                                              id,
                                              property.id,
                                              DocumentProperty(
                                                  property.id,
                                                  property.name,
                                                  property.type,
                                                  allSchemaInfos
                                                      .firstWhere((element) =>
                                                          element.namePrimary ==
                                                          value)
                                                      .id))))))
                      : allSchemaInfos.isNotEmpty
                          ? Text(propertyValueName ?? 'none', style: style)
                          : Text('none')))
          : Container(
              height: propertyFieldHeight,
            ));
      column4.add(Container(
          height: propertyFieldHeight,
          child: Center(
              child: isEditing
                  ? Container(
                      height: 40,
                      width: 40,
                      child: RoundedIconButton(
                          Icons.delete,
                          () =>
                              delegate.deleteDocumentProperty(id, property.id),
                          color: Colors.red,
                          insets: EdgeInsets.zero))
                  : Container())));
    });
    final nameStyle = TextStyle(
        fontSize: varyForScreenWidth(25, 25, 22, 22, context),
        fontWeight: FontWeight.w400,
        color: black28);
    return Padding(
        key: UniqueKey(),
        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
        child: DecoratedContainer(
            radius: 0.0,
            child: Stack(children: [
              Padding(
                  padding: EdgeInsets.only(top: 10, left: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 10),
                        isEditing
                            ? TransparentButton(documentName, () {
                                var invalidNameStrings = List<String>.from(
                                    allSchemaInfos
                                        .map((e) => e.namePrimary!)
                                        .toList());
                                invalidNameStrings.remove(documentName);
                                delegate.showDocumentPropertyNameEditor(
                                    id,
                                    DocumentProperty(
                                        'name',
                                        documentName,
                                        PropertyType.DocumentString,
                                        documentName),
                                    'Edit Document Name',
                                    parentContext);
                              },
                                fontSize: nameStyle.fontSize,
                                insets: EdgeInsets.zero)
                            : Text(documentName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: nameStyle),
                        Container(height: 40),
                        Row(children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text('properties', style: styleHeader)),
                          Container(
                              width: varyForScreenWidth(10, 10, 5, 5, context)),
                          isEditing
                              ? Container(
                                  height: 40,
                                  width: 40,
                                  child: RoundedIconButton(
                                    Icons.add,
                                    () => delegate.add(SchemaType.document, id),
                                    insets: EdgeInsets.zero,
                                    color: Colors.blue,
                                  ))
                              : Container(),
                        ]),
                        Row(children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: column1),
                          Container(
                              width:
                                  varyForScreenWidth(70, 70, 10, 10, context)),
                          Column(children: column2),
                          Container(
                              width: varyForScreenWidth(70, 70, 5, 5, context)),
                          Column(children: column3),
                          Container(
                              width: varyForScreenWidth(70, 70, 5, 5, context)),
                          Column(children: column4),
                        ]),
                        Container(height: 50),
                        isEditing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                    Container(
                                        height: 40,
                                        width: 200,
                                        child: RoundedIconButton(
                                            Icons.delete,
                                            () => delegate.delete(
                                                SchemaType.document, id),
                                            color: Colors.red)),
                                    Container(width: 20)
                                  ])
                            : Container(),
                        Container(height: 20),
                      ])),
            ])));
  }
}
