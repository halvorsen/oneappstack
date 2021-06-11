// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../../common_model/utilities.dart';
import '../../common_widget/decorated_container.dart';
import 'navigation_widget.dart';

abstract class InitialWidgetDelegate {
  void didSelect(NavigationElement navigationElement);
}

class InitialWidget extends StatelessWidget {
  final String id;
  final String name;
  final double schemaWidgetRowHeight;
  final InitialWidgetDelegate? delegate;

  InitialWidget(this.id, this.name, this.schemaWidgetRowHeight, this.delegate,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
        child: GestureDetector(
            onTap: () =>
                delegate?.didSelect(NavigationElement(id, name, true, false)),
            child: DecoratedContainer(
                radius: 0.0,
                height: schemaWidgetRowHeight,
                width: screenWidth(context),
                child: Center(
                    child: Text(name,
                        style: TextStyle(
                            fontSize:
                                varyForScreenWidth(25, 25, 22, 22, context),
                            fontWeight: FontWeight.w400,
                            color: black28))))));
  }
}
