// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import '../../schemas_page/widget/document_definition_widget.dart';

import '../../common_model/utilities.dart';
import '../../common_widget/rounded_button.dart';
import '../bloc/schemas_bloc.dart';
import 'package:flutter/material.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';

abstract class DocumentSectionDelegate {
  void onReorder(SchemaType type, int oldIndex, int newIndex);
  void createSchema(SchemaType type);
  void doneEditing(SchemaType type);
  void edit(SchemaType type);
  bool isEditingSection(SchemaType type);
}

class DocumentSectionWidget extends StatefulWidget {
  DocumentSectionWidget(this.title, this.primaryPadding, this.delegate,
      this.documentDelegate, this.state);
  final double primaryPadding;
  final String title;
  final ImmutableSchemasState state;
  final DocumentSectionDelegate delegate;
  final DocumentDefinitionDelegate documentDelegate;
  @override
  _DocumentSectionWidgetState createState() => _DocumentSectionWidgetState();
}

class _DocumentSectionWidgetState extends State<DocumentSectionWidget> {
  List<DocumentInfo>?
      documents; //need to do this because of the reordering of the schemas during editing
  var _reorder = false;
  void onDocumentsReorder(int oldIndex, int _newIndex) {
    //takes care of the visual refresh before the model and server gets updated, which is slow
    final newIndex = (_newIndex > oldIndex) ? _newIndex - 1 : _newIndex;
    final document = documents!.removeAt(oldIndex);
    documents!.insert(newIndex, document);
    for (var i = 0; i < documents!.length; i++) {
      documents![i].index = i;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_reorder) {
      documents =
          List<DocumentInfo>.from(widget.state.documentDefinitions ?? []);
    }
    _reorder = false;
    final titleRowSpacing = 10.0;
    final edgePadding = varyForScreenWidth(20.0, 20.0, 10.0, 10.0, context);
    final titleStyle = Theme.of(context).textTheme.headline5;
    return Column(children: [
      Padding(
          padding: EdgeInsets.symmetric(
              vertical: widget.primaryPadding, horizontal: edgePadding),
          child: Row(children: [
            Text(widget.title, style: titleStyle),
            Container(width: titleRowSpacing),
            Column(children: [
              Container(height: 5),
              Container(
                  width: 40,
                  height: 40,
                  child: RoundedIconButton(
                    Icons.add,
                    () {
                      widget.delegate.createSchema(SchemaType.document);
                      widget.delegate.edit(SchemaType.document);
                    },
                    insets: EdgeInsets.zero,
                  )),
            ]),
            Container(width: 5),
            Column(children: [
              Container(height: 5),
              Container(
                  width: varyForScreenWidth(100, 100, 40, 40, context),
                  height: 40,
                  child: ((documents?.length ?? 0) > 0)
                      ? widget.delegate.isEditingSection(SchemaType.document)
                          ? RoundedIconButton(
                              Icons.done,
                              () => widget.delegate
                                  .doneEditing(SchemaType.document),
                              color: Colors.green)
                          : RoundedIconButton(Icons.edit,
                              () => widget.delegate.edit(SchemaType.document),
                              insets: EdgeInsets.zero)
                      : Container()),
            ])
          ])),
      documentWidgets(context, widget.state)
    ]);
  }

  Widget documentWidgets(BuildContext context, ImmutableSchemasState state) {
    var containerHeight =
        varyForScreenWidth(600.0, 600.0, 250.0, 250.0, context);
    return Container(
        color: Colors.white,
        height: containerHeight,
        child: ReorderableListView(
            buildDefaultDragHandles:
                widget.delegate.isEditingSection(SchemaType.document),
            onReorder: (oldIndex, newIndex) {
              _reorder = true;
              onDocumentsReorder(oldIndex, newIndex);
              widget.delegate
                  .onReorder(SchemaType.document, oldIndex, newIndex);
            },
            children: documents?.map((e) {
                  var schemaList =
                      state.allSchemas.map((f) => f.namePrimary!).toList();
                  return DocumentDefinitionWidget(
                      e.id!,
                      e.namePrimary ?? '',
                      e.properties ?? [],
                      widget.delegate.isEditingSection(SchemaType.document),
                      widget.documentDelegate,
                      schemaList,
                      context,
                      key: ValueKey(e.id));
                }).toList() ??
                []));
  }
}
