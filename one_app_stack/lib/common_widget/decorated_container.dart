// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// does the rounded, shadow decoration on widgets
class DecoratedContainer extends StatelessWidget {
  DecoratedContainer(
      {this.width,
      this.height,
      this.child,
      this.radius,
      this.offset,
      this.blurRadius,
      this.shadowColor,
      this.spreadRadius,
      this.color});
  final double? width;
  final double? height;
  final Widget? child;
  final double? radius;
  final Offset? offset;
  final double? blurRadius;
  final Color? shadowColor;
  final Color? color;
  final spreadRadius;
  @override
  Widget build(BuildContext context) {
    var rad = (radius ?? 15.0) - 5.0;
    if (rad < 0.0) {
      rad = 0.0;
    }
    return Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: shadowColor ?? Colors.black,
              blurRadius: blurRadius ?? 8.0,
              spreadRadius: spreadRadius ?? -5.0,
              offset: offset ?? Offset(3.0, 3.0))
        ], borderRadius: BorderRadius.circular(rad)),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(radius ?? 15.0),
            child: Container(
                color: color ?? Colors.white,
                height: height,
                width: width,
                child: child)));
  }
}

class SmallDecoratedContainer extends DecoratedContainer {
  SmallDecoratedContainer({Widget? child, double? width, double? height})
      : super(
            child: child,
            width: width,
            height: height,
            radius: 6,
            spreadRadius: -3.0,
            offset: Offset(3.0, 3.0),
            shadowColor: Colors.black54);
}
