// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../common_widget/popover/popover_notifications.dart';
import '../../common_widget/popover/textfield_popover_widget.dart';
import '../../manager_page/bloc/manager_bloc.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';

import '../../one_stack.dart';
import 'document_form.dart';
import 'initial_widget.dart';
import 'instance_widget.dart';
import 'navigation_widget.dart';

//Try to keep widget state and communication with BLoC to the page controller

class ManagerPageController
    with
        InstanceWidgetDelegate,
        InitialWidgetDelegate,
        NavigationWidgetDelegate,
        DocumentFormDelegate {
  final ManagerBloc bloc;
  late void Function(VoidCallback) setState;
  final CommonServices services;

  ManagerPageController(this.bloc, this.services);

  @override
  void didSelect(NavigationElement navigationElement) {
    bloc.add(SelectPathElement(navigationElement));
  }

  @override
  void saveValidValues(List<DocumentProperty> values,
      Map<String, Uint8List> filesToSave, List<String> filesToDelete) {
    bloc.add(SaveValidDocumentValuesEvent(values, filesToSave, filesToDelete));
  }

  void addDocument() {
    bloc.add(AddDocumentEvent());
  }

  void exitDocument() {
    bloc.add(ExitDocumentEvent());
  }

  void remove(String id, int index) {}
  void add(String id) {}

  void deleteDocument(String documentId) {
    bloc.add(DeleteDocument(documentId));
  }

  void userEntryPopup(String entry, BuildContext context) {
    ShowPopOverNotification(context, LayerLink(),
            popChild: Container(
                width: 500,
                height: 230,
                child: TextFieldPopoverWidget(entry, null, '', [],
                    (value) => bloc.add(ReturnUserEntryEvent(value)), true)),
            dismissOnBarrierClick: false)
        .dispatch(context);
  }

  void comingSoon(BuildContext context) {
    ShowPopOverNotification(context, LayerLink(),
            popChild: Container(
                width: 200,
                height: 100,
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(
                            child: Text('File Storage support\nCOMING SOON',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                )))))),
            dismissOnBarrierClick: true)
        .dispatch(context);
  }
}
