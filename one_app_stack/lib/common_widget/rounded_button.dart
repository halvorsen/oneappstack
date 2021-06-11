// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final TextStyle? textStyle;
  final String title;
  final Function? action;
  final double? fontSize;
  final Color color = Colors.blue;
  final Color backgroundColor = Colors.black12;
  final EdgeInsets? insets;
  RoundedButton(this.title, this.action,
      {this.textStyle, this.fontSize, this.insets});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(0),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(constraints.maxHeight * 0.5)),
        ),
        child: Padding(
            padding: insets ?? EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Text(title,
                style: textStyle ??
                    TextStyle(
                        fontSize: fontSize ?? 16,
                        fontWeight: FontWeight.normal,
                        color: color))),
        onPressed: action as void Function()? ?? () {},
      );
    });
  }
}

class BlueGrayButton extends RoundedButton {
  BlueGrayButton(String title, Function? action,
      {TextStyle? textStyle, double? fontSize, EdgeInsets? insets})
      : super(title, action,
            textStyle: textStyle, fontSize: fontSize, insets: insets);
}

class RedGrayButton extends RoundedButton {
  @override
  final color = Colors.red;
  RedGrayButton(String title, Function? action,
      {TextStyle? textStyle, double? fontSize, EdgeInsets? insets})
      : super(title, action,
            textStyle: textStyle, fontSize: fontSize, insets: insets);
}

class GreenGrayButton extends RoundedButton {
  @override
  final color = Colors.green;
  GreenGrayButton(String title, Function? action,
      {TextStyle? textStyle, double? fontSize, EdgeInsets? insets})
      : super(title, action,
            textStyle: textStyle, fontSize: fontSize, insets: insets);
}

class TransparentButton extends RoundedButton {
  @override
  final backgroundColor = Colors.transparent;
  TransparentButton(String title, Function? action,
      {TextStyle? textStyle, double? fontSize, EdgeInsets? insets})
      : super(title, action,
            textStyle: textStyle, fontSize: fontSize, insets: insets);
}

class RoundedIconButton extends StatelessWidget {
  final TextStyle? textStyle;
  final IconData icon;
  final Function? action;
  final double? fontSize;
  final MaterialColor color;
  final Color backgroundColor;
  final EdgeInsets? insets;
  RoundedIconButton(this.icon, this.action,
      {this.textStyle,
      this.fontSize,
      this.insets,
      this.color = Colors.blue,
      this.backgroundColor = Colors.black12});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(0),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(constraints.maxHeight * 0.5)),
        ),
        child: Padding(
            padding: insets ?? EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Icon(icon, color: color, size: fontSize ?? 20)),
        onPressed: action as void Function()? ?? () {},
      );
    });
  }
}
