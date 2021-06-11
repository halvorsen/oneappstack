// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import '../../common_model/utilities.dart';
import '../../common_widget/rounded_button.dart';
import '../../schemas_page/bloc/schemas_bloc.dart';
import '../../schemas_page/widget/schema_widget.dart';
import 'package:flutter/material.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';

abstract class SchemaSectionDelegate {
  void onReorder(SchemaType type, int oldIndex, int newIndex);
  void createSchema(SchemaType type);
  void doneEditing(SchemaType type);
  void edit(SchemaType type);
  bool isEditingSection(SchemaType type);
}

class SchemaSectionWidget extends StatefulWidget {
  SchemaSectionWidget(this.type, this.title, this.primaryPadding, this.delegate,
      this.schemaDelegate, this.state);
  final SchemaType type;
  final double primaryPadding;
  final String title;
  final ImmutableSchemasState state;
  final SchemaSectionDelegate delegate;
  final SchemaWidgetDelegate schemaDelegate;
  @override
  _SchemaSectionWidgetState createState() => _SchemaSectionWidgetState();
}

class _SchemaSectionWidgetState extends State<SchemaSectionWidget> {
  List<SchemaInfo>?
      _schemas; //need to do this because of the reordering of the schemas during editing
  var _reorder = false;
  void _onReorder(int oldIndex, int _newIndex) {
    //takes care of the visual refresh before the model and server gets updated, which is slow
    final newIndex = (_newIndex > oldIndex) ? _newIndex - 1 : _newIndex;
    final schema = _schemas!.removeAt(oldIndex);
    _schemas!.insert(newIndex, schema);
    for (var i = 0; i < _schemas!.length; i++) {
      _schemas![i].index = i;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_reorder) {
      _schemas = List<SchemaInfo>.from(widget.state.schemas(widget.type) ?? []);
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
                      widget.delegate.createSchema(widget.type);
                      widget.delegate.edit(widget.type);
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
                  child: ((_schemas?.length ?? 0) > 0)
                      ? widget.delegate.isEditingSection(widget.type)
                          ? RoundedIconButton(Icons.done,
                              () => widget.delegate.doneEditing(widget.type),
                              color: Colors.green, insets: EdgeInsets.zero)
                          : RoundedIconButton(Icons.edit,
                              () => widget.delegate.edit(widget.type),
                              insets: EdgeInsets.zero)
                      : Container()),
            ])
          ])),
      schemasWidgets(context)
    ]);
  }

  Widget schemasWidgets(BuildContext context) {
    final schemaWidgetRowHeight = 80.0;
    final columnSpacing = 2.0;
    final numberOfSchemas = _schemas?.length ?? 0;
    var containerHeight = schemaWidgetRowHeight * (numberOfSchemas + 0.5) +
        columnSpacing * numberOfSchemas * 2;
    if (numberOfSchemas > 4) {
      containerHeight =
          schemaWidgetRowHeight * (4 + 0.5) + columnSpacing * 4 * 2;
    }
    return Container(
        color: Colors.white,
        height: containerHeight,
        child: ReorderableListView(
            buildDefaultDragHandles:
                widget.delegate.isEditingSection(widget.type) &&
                    (_schemas?.length ?? 0) > 1,
            onReorder: (oldIndex, newIndex) {
              _reorder = true;
              _onReorder(oldIndex, newIndex);
              widget.delegate.onReorder(widget.type, oldIndex, newIndex);
            },
            children: _schemas
                    ?.map((e) => SchemaWidget(
                        e.id!,
                        e.namePrimary!,
                        e.isBaseSchema,
                        e.path!,
                        columnSpacing,
                        schemaWidgetRowHeight,
                        widget.type,
                        widget.delegate.isEditingSection(widget.type),
                        widget.schemaDelegate,
                        widget.state.documentDefinitions
                            ?.firstWhere(
                                (element) => (e.linkedDocument != null &&
                                    element.id == e.linkedDocument),
                                orElse: () => DocumentInfo(
                                    CommonInfo(namePrimary: null), null, 0))
                            .namePrimary,
                        widget.state.allDocumentNames,
                        widget.state.allSchemas
                            .map((e) => e.namePrimary!)
                            .toList(),
                        context,
                        key: ValueKey(e.id)))
                    .toList() ??
                []));
  }
}
