// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import '../../common_model/utilities.dart';
import '../../common_widget/decorated_container.dart';
import 'navigation_widget.dart';

abstract class InstanceWidgetDelegate {
  void didSelect(NavigationElement navigationElement);
}

class InstanceWidget extends StatelessWidget {
  final String id;
  final List<DocumentProperty> properties;
  final double schemaWidgetRowHeight;
  final InstanceWidgetDelegate? delegate;
  final List<String> items;

  InstanceWidget(
      this.id, this.properties, this.schemaWidgetRowHeight, this.delegate,
      {Key? key})
      : items = properties.map((e) => e.value.toString()).toList(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (var i = 0; i < items.length; i++) {
      children.add(Container(
        width: 30,
      ));
      children.add(Center(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Text(items[i], style: Theme.of(context).textTheme.headline3),
          ])));
    }
    return Padding(
        key: UniqueKey(),
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
        child: GestureDetector(
            onTap: () {
              delegate?.didSelect(NavigationElement(
                  id,
                  properties
                      .firstWhere((element) => element.name == docName,
                          orElse: () => DocumentProperty(id, 'Files',
                              PropertyType.DocumentFileList, 'Files'))
                      .value,
                  false,
                  false));
            },
            child: DecoratedContainer(
                radius: 0.0,
                height: schemaWidgetRowHeight,
                child: Container(
                    width: screenWidth(context),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: children,
                    )))));
  }
}
