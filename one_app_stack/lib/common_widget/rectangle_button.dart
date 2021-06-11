// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import '../common_widget/decorated_container.dart';

import '../common_model/utilities.dart';
import 'package:flutter/material.dart';

class RectangleButton extends StatelessWidget {
  RectangleButton(this.title, this.action, this.color, {Key? key})
      : super(key: key);
  final String title;
  final Function action;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SmallDecoratedContainer(
        width: varyForScreenWidth(150, 150, 100, 100, context),
        height: varyForScreenWidth(40, 40, 30, 30, context),
        child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: color, padding: EdgeInsets.all(0.0)),
            onPressed: action as void Function()?,
            child: Text(title,
                style: varyForScreenWidth(
                    Theme.of(context).textTheme.headline6,
                    Theme.of(context).textTheme.headline6,
                    Theme.of(context).textTheme.headline6,
                    Theme.of(context).textTheme.headline6,
                    context))));
  }
}
