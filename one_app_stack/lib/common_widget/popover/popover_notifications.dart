// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class ShowPopOverNotification extends Notification {
  ShowPopOverNotification(
    this.context,
    this.link, {
    required this.popChild,
    this.useBarrier = true,
    this.barrierColor,
    this.dismissOnBarrierClick = true,
    this.onCloseOverlay,
  });
  final BuildContext context;
  final LayerLink link;
  final Widget popChild;
  final bool useBarrier;
  final Color? barrierColor;
  final bool dismissOnBarrierClick;
  final Function? onCloseOverlay;
}

// Dispatched from the PopOver Widget, so the PopOverContext can get the size of an arbitrary child Widget
class SizePopoverNotification extends Notification {
  SizePopoverNotification(this.size);
  final Size size;
}

// Anyone can send one of these up the tree to Close the current PopOver
class ClosePopoverNotification extends Notification {}

// used by the signin screen
class RefreshScreenNotification extends Notification {}
