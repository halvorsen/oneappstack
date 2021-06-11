// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:statsfl/statsfl.dart';

import 'popover/popover_controller.dart';

/// Wraps the entire app, providing it with various helper classes and wrapper widgets.
class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold({Key? key, required this.child}) : super(key: key);
  final Widget Function() child;

  @override
  _MainAppScaffoldState createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext builderContext) {
        return PopOverController(
          // controls the overlay layer through notifications
          child: () => _WindowBorder(
            //adds a border for desktop applicaitons
            color: Colors.black87,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  verticalDirection: VerticalDirection.up,
                  children: [Expanded(child: widget.child())],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WindowBorder extends StatelessWidget {
  const _WindowBorder({Key? key, this.child, this.color}) : super(key: key);
  final Widget? child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child!,
      IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(.1), width: 1),
          ),
        ),
      ),
    ]);
  }
}
