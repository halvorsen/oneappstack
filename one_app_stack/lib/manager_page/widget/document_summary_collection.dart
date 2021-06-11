// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../common_widget/header_widget.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import '../../common_model/utilities.dart';
import '../../manager_page/widget/initial_widget.dart';
import '../../manager_page/widget/instance_widget.dart';

import 'navigation_widget.dart';

class InstanceSummary {
  String id;
  List<DocumentProperty> items;
  InstanceSummary(this.id, this.items);
}

class DocumentSummaryCollection extends StatelessWidget {
  DocumentSummaryCollection(
      this.isBase,
      this.isFileStorage,
      this.rootSchemaElements,
      this.instanceSummaries,
      this.instanceWidgetDelegate,
      this.initialWidgetDelegate);
  final bool isBase;
  final bool isFileStorage;
  final List<NavigationElement> rootSchemaElements;
  final List<InstanceSummary>? instanceSummaries;
  final InstanceWidgetDelegate instanceWidgetDelegate;
  final InitialWidgetDelegate initialWidgetDelegate;
  final schemaWidgetRowHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    var height = 25.0;
    height += 90.0 *
        (instanceSummaries?.length ?? rootSchemaElements.length).toDouble();
    if (height > varyForScreenWidth(600.0, 600.0, 175.0, 175.0, context)) {
      height = varyForScreenWidth(600.0, 600.0, 175.0, 175.0, context) + 25.0;
    }
    var children = <Widget>[];
    children.add(Container(height: 2));
    final documentWidgets = instanceSummaries
            ?.map((e) => InstanceWidget(
                e.id, e.items, schemaWidgetRowHeight, instanceWidgetDelegate))
            .toList() ??
        [];
    final basePathWidgets = rootSchemaElements
        .map((e) => InitialWidget(
            e.id, e.name, schemaWidgetRowHeight, initialWidgetDelegate))
        .toList();
    if (documentWidgets.isNotEmpty && !isBase) {
      children.addAll(documentWidgets);
      return Container(
          color: grayda, height: height, child: ListView(children: children));
    } else if (basePathWidgets.isNotEmpty && isBase) {
      children.addAll(basePathWidgets);
      return Container(
          color: grayda, height: height, child: ListView(children: children));
    } else if (rootSchemaElements.isEmpty && isBase) {
      return Container(
          height: 200,
          child: Center(
              child: Text(
                  'No complete paths, go to ${HeaderWidget.schemasTitle}',
                  style: Theme.of(context).textTheme.headline1)));
    } else {
      return Container(
          height: 200,
          child: Center(
              child: Text(
                  isFileStorage
                      ? 'No files, click + to add'
                      : 'No documents, click + to add',
                  style: Theme.of(context).textTheme.headline1)));
    }
  }
}
