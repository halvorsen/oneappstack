// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../common_model/utilities.dart';
import '../../common_widget/rounded_button.dart';

class NavigationElement {
  String id;
  String name;
  bool isDocuments;
  bool isNavigationBarElement;
  NavigationElement(
      this.id, this.name, this.isDocuments, this.isNavigationBarElement);
  static final baseId = 'baseId';
}

abstract class NavigationWidgetDelegate {
  void didSelect(NavigationElement navigationElement);
}

class NavigationWidget extends StatelessWidget {
  final List<NavigationElement> elements;
  final NavigationWidgetDelegate delegate;
  NavigationWidget(this.elements, this.delegate);
  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    if (elements.isNotEmpty) {
      children.add(linkButton(
          NavigationElement(NavigationElement.baseId, 'Base', false, true)));
    }
    for (var element in elements) {
      children.add(Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          )));
      children.add(linkButton(NavigationElement(
          element.id, element.name, element.isDocuments, true)));
    }
    return Container(
        width: screenWidth(context) - 50.0,
        height: 60.0,
        child: ListView(scrollDirection: Axis.horizontal, children: children));
  }

  Widget linkButton(NavigationElement element) {
    return TransparentButton(element.name, () => delegate.didSelect(element),
        fontSize: 30);
  }
}
