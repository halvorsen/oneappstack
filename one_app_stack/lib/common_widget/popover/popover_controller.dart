// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../decorated_container.dart';
import 'popover_notifications.dart';

class PopOverController extends StatefulWidget {
  const PopOverController({Key? key, this.child}) : super(key: key);
  final Widget Function()? child;

  @override
  PopOverControllerState createState() => PopOverControllerState();
}

class PopOverControllerState extends State<PopOverController> {
  OverlayEntry? barrierOverlay;
  OverlayEntry? mainContentOverlay;
  ValueNotifier<Size?> _sizeNotifier = ValueNotifier(Size.zero);

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: _handleNotification,
      child: widget.child!(),
    );
  }

  bool get isBarrierOpen => barrierOverlay != null;
  Function? onCloseOverlay;
  void _closeOverlay() {
    _sizeNotifier.value = null;
    barrierOverlay?.remove();
    mainContentOverlay?.remove();
    barrierOverlay = mainContentOverlay = null;
    if (onCloseOverlay != null) {
      onCloseOverlay!();
    }
  }

  bool _handleNotification(Notification n) {
    if (n is RefreshScreenNotification) {
      setState(() {});
      return true;
    } else if (n is ClosePopoverNotification) {
      _closeOverlay();
      return true;
    } else if (n is ShowPopOverNotification) {
      onCloseOverlay = n.onCloseOverlay;
      //Close existing popOver if one is open
      _closeOverlay();

      if (n.useBarrier) {
        barrierOverlay = OverlayEntry(
          builder: (_) {
            return GestureDetector(
              onTap: n.dismissOnBarrierClick ? _closeOverlay : null,
              onPanStart:
                  n.dismissOnBarrierClick ? (_) => _closeOverlay() : null,
              child: Container(
                  color: n.barrierColor ?? Colors.black87.withAlpha(200)),
            );
          },
        );
        Overlay.of(n.context)?.insert(barrierOverlay!);
      }

      mainContentOverlay = OverlayEntry(builder: (_) {
        return NotificationListener(
          onNotification: _handleNotification,
          child: Material(
            type: MaterialType.transparency,
            child: ValueListenableBuilder<Size?>(
                valueListenable: _sizeNotifier,
                builder: (_, size, __) {
                  size ??= Size.zero;
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Opacity(
                      opacity: size != Size.zero ? 1 : 0,
                      child: MeasureSize(
                        onChange: _handlePopOverSized,
                        child: FocusScope(child: KeyboardVisibilityBuilder(
                            builder: (context, isKeyboardVisible) {
                          return isKeyboardVisible //isn't working on ios, flashing screen if using this.
                              ? Stack(children: [
                                  Align(
                                      alignment: Alignment(0.0, -0.5),
                                      child:
                                          DecoratedContainer(child: n.popChild))
                                ])
                              : Stack(children: [
                                  Align(
                                      alignment: Alignment(0.0, -0.5),
                                      child:
                                          DecoratedContainer(child: n.popChild))
                                ]);
                        })),
                      ),
                    ),
                  );
                }),
          ),
        );
      });
      Overlay.of(n.context)?.insert(mainContentOverlay!);
      return true;
    }
    return false;
  }

  void _handlePopOverSized(Size size) =>
      scheduleMicrotask(() => _sizeNotifier.value = size);
}

class MeasureSizeRenderObject extends RenderProxyBox {
  MeasureSizeRenderObject(this.onChange);
  void Function(Size size) onChange;

  Size? _prevSize;
  @override
  void performLayout() {
    super.performLayout();
    Size newSize = child!.size;
    if (_prevSize == newSize) return;
    _prevSize = newSize;
    WidgetsBinding.instance!.addPostFrameCallback((_) => onChange(newSize));
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  const MeasureSize({Key? key, required this.onChange, required Widget child})
      : super(key: key, child: child);
  final void Function(Size size) onChange;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      MeasureSizeRenderObject(onChange);
}
