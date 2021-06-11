// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common_widget/popover/popover_notifications.dart';
import '../../project_page/bloc/project_bloc.dart';
import '../../project_page/widget/project_page_controller.dart';

import '../../one_stack.dart';
import '../../project_page/widget/project_cell_info.dart';

import '../../common_widget/header_widget.dart';
import '../../common_model/utilities.dart';
import 'package:flutter/material.dart';

import 'project_edit_form.dart';
import 'project_collection_widget.dart';

class ProjectPageWidget extends StatefulWidget {
  ProjectPageWidget(this.services, this.bloc, {Key? key})
      : pageController = ProjectPageController(bloc, services),
        super(key: key);
  final CommonServices services;
  final ProjectBloc bloc;
  final ProjectPageController pageController;
  @override
  _ProjectPageWidgetState createState() => _ProjectPageWidgetState();
}

class _ProjectPageWidgetState extends State<ProjectPageWidget> {
  @override
  void initState() {
    widget.services.auth.signIn(context).then((value) {
      widget.pageController.updateUserId();
    });
    super.initState();
  }

  void popup() {
    ShowPopOverNotification(context, LayerLink(),
            popChild: ProjectEditForm(null, widget.pageController, false),
            dismissOnBarrierClick: true)
        .dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: widget.bloc,
        builder: (BuildContext context, ImmutableProjectState state) {
          final projects = state.projects
              .map((e) => ProjectCellInfo(e.namePrimary ?? 'Error', e.id!))
              .toList();
          if (state.showProjectEditForm) {
            WidgetsBinding.instance!.addPostFrameCallback((_) => popup());
          }
          return Material(
              color: teal,
              child: Stack(
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(
                          0, headerWidgetHeight(context), 0, 0),
                      child: Container(
                          height: screenHeight(context),
                          child: ProjectCollectionWidget(
                              projects, widget.pageController))),
                  Align(
                      alignment: Alignment(0.0, -1.0),
                      child: Container(
                          height: headerWidgetHeight(context),
                          child: HeaderWidget(
                              widget.services,
                              currentProjectId != null,
                              HeaderWidget.projectTitle))),
                  (state.showActivityIndicator)
                      ? IgnorePointer(
                          child: Container(
                              color: Colors.transparent,
                              height: screenHeight(context),
                              width: screenWidth(context)))
                      : Container(),
                  (state.showActivityIndicator)
                      ? Center(
                          child: Container(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.black54))))
                      : Container(),
                ],
              ));
        });
  }
}
