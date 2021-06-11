// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../../code_widget/generators/code_generator_dart.dart';
import '../../code_widget/widget/code_page_widget.dart';
import '../../common_model/utilities.dart';
import '../../schemas_page/bloc/schemas_diagram.dart';
import '../../common_widget/popover/popover_notifications.dart';
import '../../schemas_page/widget/schema_section_widget.dart';
import '../../schemas_page/widget/schema_widget.dart';
import '../../common_widget/popover/textfield_popover_widget.dart';
import '../../schemas_page/bloc/schemas_bloc.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';

import '../../one_stack.dart';
import 'document_definition_widget.dart';
import 'document_section_widget.dart';

//Try to keep widget state and communication with BLoC to the page controller

class SchemasPageController
    with
        SchemaWidgetDelegate,
        SchemaSectionDelegate,
        DocumentSectionDelegate,
        DocumentDefinitionDelegate {
  final SchemasBloc bloc;
  late void Function(VoidCallback) setState;
  final CommonServices services;

  Map<SchemaType, bool> isEditing = {
    SchemaType.firestore: false,
    SchemaType.realtime: false,
    SchemaType.storage: false,
    SchemaType.document: false,
  };

  SchemasPageController(this.bloc, this.services);

  void showSchemaHelp(BuildContext context) {
    ShowPopOverNotification(context, LayerLink(),
            popChild: Container(
                width: 500,
                height: 170,
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(
                            child: Text('''
            Data-Paths are paths to your data (e.g. /user/tweet) that point to a document of key/value pairs. Data-Paths are defined seperately from documents so that they can be used to build more complex data trees. Try creating the simplist starter structure: 1. create a data path 2. create a document 3. link the document to the path, 4. go into the manager to start entering instances.
            ''',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                )))))),
            dismissOnBarrierClick: true)
        .dispatch(context);
  }

  void showSchemaDiagram(ImmutableSchemasState state, BuildContext context) {
    ShowPopOverNotification(context, LayerLink(),
            popChild: Container(
                width: screenWidth(context) * 0.8,
                height: screenHeight(context) * 0.8,
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: ListView(
                          children: [
                            Container(
                              child: SchemasDiagram(state).widget(context),
                            )
                          ],
                        )))),
            dismissOnBarrierClick: true)
        .dispatch(context);
  }

  void showCodeSnippets(ImmutableSchemasState state, String currentLanguage,
      BuildContext context) {
    CodeGeneratorDart(SchemasDiagram(state));
    ShowPopOverNotification(context, LayerLink(),
            popChild: Container(
                width: screenWidth(context) * 0.8,
                height: screenHeight(context) * 0.8,
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: ListView(children: [
                          CodePageWidget(
                            services,
                            SchemasDiagram(state),
                            currentLanguage,
                          )
                        ])))),
            dismissOnBarrierClick: true)
        .dispatch(context);
  }

  void showEditor(
      SchemaType type,
      String id,
      int index,
      String editString,
      String editorDisplayTitle,
      List<String> invalidStrings,
      BuildContext context) {
    TextFieldPopoverWidget.showTextFieldPopoverWidget(
        context, editorDisplayTitle, editString, type, invalidStrings,
        (validChange) {
      validSchemaEdit(type, id, index, validChange);
    }, false);
  }

  void showDocumentPropertyNameEditor(
      String documentId,
      DocumentProperty documentProperty,
      String editorDisplayTitle,
      BuildContext context) {
    TextFieldPopoverWidget.showTextFieldPopoverWidget(
        context, editorDisplayTitle, documentProperty.name, null, [],
        (validChange) {
      validDocumentEdit(
          documentId,
          documentProperty.id,
          DocumentProperty(documentProperty.id, validChange,
              documentProperty.type, documentProperty.value));
    }, false);
  }

  void validSchemaEdit(
      SchemaType type, String id, int? index, String validChange) {
    bloc.add(ValidSchemaEdit(type, id, index, validChange));
  }

  void validDocumentEdit(String documentId, String propertyId,
      DocumentProperty newDocumentProperty) {
    bloc.add(ValidDocumentEditPropertyEvent(
        documentId, propertyId, newDocumentProperty));
  }

  void createSchema(SchemaType type) {
    if (type == SchemaType.document) {
      bloc.add(DocumentCreationEvent());
    } else {
      bloc.add(SchemaCreationEvent(type));
    }
  }

  void toggleIsBase(SchemaType type, String id, bool isBaseSchema) {
    bloc.add(ToggleIsBaseEvent(type, id, isBaseSchema));
  }

  void edit(SchemaType type) {
    switch (type) {
      case SchemaType.firestore:
        isEditing[SchemaType.firestore] = true;
        break;
      case SchemaType.realtime:
        isEditing[SchemaType.realtime] = true;
        break;
      case SchemaType.storage:
        isEditing[SchemaType.storage] = true;
        break;
      case SchemaType.document:
        isEditing[SchemaType.document] = true;
        break;
    }
    setState(() {});
  }

  void doneEditing(SchemaType type) {
    switch (type) {
      case SchemaType.firestore:
        isEditing[SchemaType.firestore] = false;
        break;
      case SchemaType.realtime:
        isEditing[SchemaType.realtime] = false;
        break;
      case SchemaType.storage:
        isEditing[SchemaType.storage] = false;
        break;
      case SchemaType.document:
        isEditing[SchemaType.document] = false;
        break;
    }
    setState(() {});
  }

  void onReorder(SchemaType type, int oldIndex, int newIndex) {
    (type == SchemaType.document)
        ? bloc.add(DocumentMoveEvent(oldIndex, newIndex))
        : bloc.add(SchemaMoveEvent(type, oldIndex, newIndex));
  }

  bool isEditingSection(SchemaType type) {
    return isEditing[type]!;
  }

  void add(SchemaType type, String id) {
    (type == SchemaType.document)
        ? bloc.add(DocumentAddPropertyEvent(id))
        : bloc.add(SchemaAddPathEvent(id, type));
  }

  void subtract(SchemaType type, String id) {
    bloc.add(SchemaRemovePathEvent(id, type));
  }

  void deleteDocumentProperty(String documentId, String propertyId) {
    bloc.add(DocumentRemovePropertyEvent(documentId, propertyId));
  }

  void delete(SchemaType type, String id) {
    (type == SchemaType.document)
        ? bloc.add(DocumentDeleteEvent(id))
        : bloc.add(SchemaDeleteEvent(id, type));
  }
}
