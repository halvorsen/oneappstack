// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common_widget/rounded_button.dart';
import '../../schemas_page/widget/document_section_widget.dart';
import '../../schemas_page/bloc/schemas_bloc.dart';
import '../../schemas_page/widget/schema_section_widget.dart';
import '../../schemas_page/widget/schemas_page_controller.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';

import '../../one_stack.dart';
import '../../common_widget/header_widget.dart';
import '../../common_model/utilities.dart';
import 'package:flutter/material.dart';

class SchemasPageWidget extends StatefulWidget {
  SchemasPageWidget(this.services, this.bloc, {Key? key})
      : pageController = SchemasPageController(bloc, services),
        super(key: key);
  final CommonServices services;
  final SchemasBloc bloc;
  final SchemasPageController pageController;
  @override
  _SchemasPageWidgetState createState() => _SchemasPageWidgetState();
}

class _SchemasPageWidgetState extends State<SchemasPageWidget> {
  @override
  void initState() {
    widget.pageController.setState = this.setState;
    super.initState();
  }

  var currentLanguage = 'dart';
  @override
  Widget build(BuildContext context) {
    final primaryPadding = 20.0;
    final edgePadding = varyForScreenWidth(0.0, 0.0, 0.0, 0.0, context);
    return Material(
        color: teal,
        child: Stack(
          children: [
            Padding(
                padding:
                    EdgeInsets.fromLTRB(0, headerWidgetHeight(context), 0, 0),
                child: Container(
                    height: screenHeight(context) - headerWidgetHeight(context),
                    child: BlocBuilder(
                        bloc: widget.bloc,
                        builder: (BuildContext context,
                            ImmutableSchemasState state) {
                          return ListView(
                            children: [
                              Row(children: [
                                (state.allSchemas.isNotEmpty)
                                    ? Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            20.0, 0.0, 10.0, 0.0),
                                        child: Checkbox(
                                            value: true,
                                            onChanged: (newValue) => null))
                                    : Container(),
                                (state.allSchemas.isNotEmpty)
                                    ? Text(
                                        varyForScreenWidth(
                                            'selected schemas available as root path in manager',
                                            'selected schemas available as root path in manager',
                                            'available as root path',
                                            'available as root path',
                                            context),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3)
                                    : Container(),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: primaryPadding,
                                            horizontal: edgePadding),
                                        child: Container())),
                                Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Container(
                                        width: 40,
                                        height: 40,
                                        child: RoundedIconButton(
                                          Icons.integration_instructions,
                                          () {
                                            widget.pageController
                                                .showCodeSnippets(state,
                                                    currentLanguage, context);
                                          },
                                          fontSize: 30,
                                          backgroundColor: Colors.transparent,
                                          insets: EdgeInsets.zero,
                                        ))),
                                DropdownButton<String>(
                                    value: currentLanguage,
                                    items: ([
                                      'dart',
                                      'c++',
                                      'java',
                                      'kotlin',
                                      'nodejs',
                                      'swift',
                                      'unity'
                                    ]).map((String value) {
                                      return new DropdownMenuItem<String>(
                                        value: value,
                                        child: new Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      currentLanguage = value ?? 'dart';
                                      setState(() {});
                                    }),
                                Container(width: 20),
                                Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Container(
                                        width: 40,
                                        height: 40,
                                        child: RoundedIconButton(
                                          Icons.visibility,
                                          () {
                                            widget.pageController
                                                .showSchemaDiagram(
                                                    state, context);
                                          },
                                          fontSize: 30,
                                          backgroundColor: Colors.transparent,
                                          insets: EdgeInsets.zero,
                                        ))),
                                Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Container(
                                        width: 40,
                                        height: 40,
                                        child: RoundedIconButton(
                                          Icons.help_outlined,
                                          () {
                                            widget.pageController
                                                .showSchemaHelp(context);
                                          },
                                          fontSize: 30,
                                          backgroundColor: Colors.transparent,
                                          insets: EdgeInsets.zero,
                                        ))),
                                Container(width: 20)
                              ]),
                              SchemaSectionWidget(
                                  SchemaType.firestore,
                                  varyForOneScreenWidth(
                                      'Firestore Paths', context,
                                      compact: 'Firestore'),
                                  primaryPadding,
                                  widget.pageController,
                                  widget.pageController,
                                  state),
                              Container(height: 50),
                              SchemaSectionWidget(
                                  SchemaType.realtime,
                                  varyForOneScreenWidth(
                                      'Realtime Paths', context,
                                      compact: 'Realtime'),
                                  primaryPadding,
                                  widget.pageController,
                                  widget.pageController,
                                  state),
                              Container(height: 50),
                              SchemaSectionWidget(
                                  SchemaType.storage,
                                  varyForOneScreenWidth(
                                      'File Storage Paths', context,
                                      compact: 'Storage'),
                                  primaryPadding,
                                  widget.pageController,
                                  widget.pageController,
                                  state),
                              Container(height: 50),
                              DocumentSectionWidget(
                                  varyForOneScreenWidth(
                                      'Document Definitions', context,
                                      compact: 'Docum...'),
                                  primaryPadding,
                                  widget.pageController,
                                  widget.pageController,
                                  state),
                            ],
                          );
                        }))),
            Align(
                alignment: Alignment(0.0, -1.0),
                child: Container(
                    height: headerWidgetHeight(context),
                    child: HeaderWidget(widget.services,
                        currentProjectId != null, HeaderWidget.schemasTitle)))
          ],
        ));
  }
}
