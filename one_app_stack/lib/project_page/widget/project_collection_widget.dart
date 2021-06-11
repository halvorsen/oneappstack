// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import '../../project_page/widget/project_cell_info.dart';
import '../../project_page/widget/project_cell_widget.dart';

import '../../common_model/utilities.dart';
import 'package:flutter/material.dart';

class ProjectCollectionWidget extends StatelessWidget {
  ProjectCollectionWidget(this.infos, this.delegate, {Key? key})
      : super(key: key);
  final List<ProjectCellInfo> infos;
  final CellWidgetDelegate delegate;

  @override
  Widget build(BuildContext context) {
    final verticalSpacing = varyForScreenWidth(30.0, 20.0, 0.0, 0.0, context);
    final horizontalSpacing = varyForScreenWidth(30.0, 20.0, 0.0, 0.0, context);
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 0.0, vertical: headerWidgetHeight(context)),
        child: Center(
            child: Container(
                width: varyForScreenWidth(900.0, 700.0, 500.0, 500.0, context),
                child: GridView.count(
                  mainAxisSpacing: verticalSpacing,
                  crossAxisSpacing: horizontalSpacing,
                  crossAxisCount: 3,
                  childAspectRatio: 1.3,
                  children: List.generate(infos.length + 1, (index) {
                    return (index != 0)
                        ? ProjectCellWidget(infos[index - 1], delegate)
                        : ProjectCellWidget(
                            ProjectCellInfo('+ project', 'newProject'),
                            delegate);
                  }),
                ))));
  }
}
