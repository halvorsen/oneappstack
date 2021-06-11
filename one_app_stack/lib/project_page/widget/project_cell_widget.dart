// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import '../../common_widget/decorated_container.dart';

import '../../common_model/utilities.dart';
import 'package:flutter/material.dart';

import 'project_cell_info.dart';

abstract class CellWidgetDelegate {
  void didSelect(String id, BuildContext context);
}

class ProjectCellWidget extends StatelessWidget {
  ProjectCellWidget(this.info, this.delegate, {Key? key}) : super(key: key);
  final ProjectCellInfo info;
  final CellWidgetDelegate delegate;

  Widget _textWidget(
      String title, String id, TextStyle titleStyle, BuildContext context) {
    final padding = varyForScreenWidth(20.0, 20.0, 10.0, 10.0, context);
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
        child: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: titleStyle,
              textAlign: TextAlign.left,
            ),
            Container(
              height: 2,
            ),
            Text('' /*id*/,
                style: varyForScreenWidth(
                    Theme.of(context).textTheme.bodyText1,
                    Theme.of(context).textTheme.bodyText2,
                    Theme.of(context).textTheme.bodyText2,
                    Theme.of(context).textTheme.bodyText2,
                    context),
                textAlign: TextAlign.left)
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
    final outerPadding = varyForScreenWidth(8.0, 8.0, 4.0, 4.0, context);
    final titleStyle = TextStyle(
        fontSize: varyForScreenWidth(30, 30, 20, 20, context),
        fontWeight: FontWeight.w200,
        color: Colors.black54);
    return GestureDetector(
        onTap: () {
          delegate.didSelect(info.id, context);
        },
        child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: outerPadding, vertical: outerPadding),
            child: DecoratedContainer(
                child: _textWidget(info.title, info.id, titleStyle, context))));
  }
}
