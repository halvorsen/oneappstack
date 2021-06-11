// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../../common_widget/popover/popover_notifications.dart';
import '../../project_page/bloc/project_bloc.dart';
import '../../project_page/widget/project_cell_widget.dart';

import '../../one_stack.dart';
import 'project_edit_form.dart';

//Try to keep widget state and communication with BLoC to the page controller

class ProjectPageController with CellWidgetDelegate, ProjectEditFormDelegate {
  final ProjectBloc bloc;
  late void Function(VoidCallback) setState;
  final CommonServices services;

  ProjectPageController(this.bloc, this.services);

  @override
  void didSelect(String id, BuildContext context) {
    bloc.add(SelectCellEvent(id, context));
  }

  @override
  void exitDocument(BuildContext context) {
    ClosePopoverNotification().dispatch(
      context,
    );
    bloc.add(SelectExitNewProjectEvent());
  }

  @override
  void save(String? id, String name, String? config, String? configIos,
      String? configAndroid, BuildContext context) {
    bloc.add(
        SaveProjectEvent(id, name, config, configIos, configAndroid, context));
  }

  void updateUserId() {
    final uid = services.auth.currentUserUid();
    bloc.add(UpdateUserIdEvent(uid));
  }
}
