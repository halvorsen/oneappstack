// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_app_stack/common_widget/popover/textfield_popover_widget.dart';
import '../../common_widget/popover/popover_notifications.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import '../../common_widget/rounded_button.dart';
import '../../manager_page/bloc/manager_bloc.dart';
import '../../manager_page/widget/search_widget.dart';

import '../../one_stack.dart';
import '../../common_widget/header_widget.dart';
import '../../common_model/utilities.dart';
import 'package:flutter/material.dart';

import 'document_form.dart';
import 'document_summary_collection.dart';
import 'manager_page_controller.dart';
import 'navigation_widget.dart';

class ManagerPageWidget extends StatefulWidget {
  ManagerPageWidget(this.services, this.bloc, {Key? key})
      : pageController = ManagerPageController(bloc, services),
        super(key: key);
  final CommonServices services;
  final ManagerBloc bloc;
  final ManagerPageController pageController;
  @override
  _ManagerPageWidgetState createState() => _ManagerPageWidgetState();
}

class _ManagerPageWidgetState extends State<ManagerPageWidget> {
  @override
  void initState() {
    widget.pageController.setState = this.setState;
    final isSignedIn =
        widget.services.auth.isSignedIn(currentFirebaseProjectId());
    if (!isSignedIn) {
      if (widget.services.platform.isWeb) {
        widget.services.auth
            .signIn(context, appName: currentFirebaseProjectId());
      } else {
        Future.delayed(Duration(seconds: 1)).then((_) {
          showTextFieldPopoverWidget(
              context, '${currentFirebaseProjectId()} email:', '', [], (email) {
            _login(email);
          }, true);
        });
      }
    }
    super.initState();
  }

  void _login(String email) {
    Future.delayed(Duration(seconds: 1)).then((_) {
      showTextFieldPopoverWidget(context, 'password:', '', [],
          (password) async {
        final success = await widget.services.auth.signIn(context,
            appName: currentFirebaseProjectId(),
            email: email,
            password: password);

        if (!success) {
          snackBar(
              content: 'Signin failed.', context: context, warningColor: true);
          widget.services.appNavigation.navigateToProjectsPage(context);
        } else {
          snackBar(
              content: 'Signin Success.',
              context: context,
              warningColor: false);
          widget.services.appNavigation.navigateToProjectsPage(context);
        }
      }, true);
    });
  }

  void showTextFieldPopoverWidget(
      BuildContext context,
      String title,
      String initialText,
      List<String> invalidStrings,
      void Function(String value)? onValidTextChange,
      bool requireSubmission) {
    ShowPopOverNotification(context, LayerLink(),
            popChild: Container(
                width: 500,
                height: 280,
                child: TextFieldPopoverWidget(title, null, initialText,
                    invalidStrings, onValidTextChange, requireSubmission,
                    requireValidation: false)),
            dismissOnBarrierClick: true)
        .dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: teal,
        child: Stack(
          children: [
            Padding(
                padding:
                    EdgeInsets.fromLTRB(0, headerWidgetHeight(context), 0, 0),
                child: Container(
                    height: screenHeight(context) - headerWidgetHeight(context),
                    child: BlocBuilder(
                        bloc: widget.bloc,
                        builder: (BuildContext context,
                            ImmutableManagerState state) {
                          if (state.userEntries.isNotEmpty) {
                            WidgetsBinding.instance!.addPostFrameCallback((_) {
                              widget.pageController.userEntryPopup(
                                  state.userEntries[0], context);
                            });
                          }
                          final isFileStorage =
                              state.getTypeFromCurrentPath() ==
                                  SchemaType.storage;
                          List<InstanceSummary>? instanceSummaries;
                          final docs = (state.getTypeFromCurrentPath() ==
                                  SchemaType.storage)
                              ? List<dynamic>.from(
                                  (state.documents ?? {'files': []})['files']!)
                              : (state.documents?.values.toList() ?? []);
                          final documentDefinition = state.currentDefinition;
                          if (docs.length > 0) {
                            instanceSummaries = [];
                          }
                          if (isFileStorage) {
                            for (var urlString in docs) {
                              instanceSummaries?.add(InstanceSummary(
                                  urlString, [
                                DocumentProperty(urlString, urlString,
                                    PropertyType.DocumentFile, urlString)
                              ]));
                            }
                          } else {
                            for (var doc in docs) {
                              var documentInstance =
                                  Map<String, dynamic>.from(doc);
                              documentInstance.removeWhere((key, value) {
                                return (key == docLastEditedId ||
                                    key == docCreationId);
                              });
                              // print(documentInstance);
                              print(documentDefinition?.toJsonString());
                              instanceSummaries?.add(InstanceSummary(
                                  documentInstance[docId],
                                  DocumentProperty.assembleDocument(
                                      documentInstance,
                                      documentDefinition,
                                      state.allSchemas,
                                      false)));
                            }
                          }
                          final showActivityIndicator =
                              state.isFetchingNeededDataToContinue;

                          final basePaths = state.allSchemas
                              .where((element) => (element.isBaseSchema &&
                                  (element.linkedDocument != null)))
                              .map((e) => NavigationElement(
                                  e.id!, e.namePrimary!, false, false))
                              .toList();
                          return Stack(children: [
                            ListView(
                              children: [
                                Padding(
                                    padding: EdgeInsets.all(
                                        (instanceSummaries == null ||
                                                (state.path).isEmpty)
                                            ? 5.0
                                            : 0.0),
                                    child: Row(children: [
                                      NavigationWidget(
                                          ((state.path).isEmpty)
                                              ? []
                                              : state.path,
                                          widget.pageController),
                                      Expanded(child: projectSelectionWidget()),
                                      // Container(
                                      //     width: 40,
                                      //     height: 40,
                                      //     child: RoundedIconButton(
                                      //       Icons.help_outlined,
                                      //       () {},
                                      //       fontSize: 30,
                                      //       backgroundColor: Colors.transparent,
                                      //       insets: EdgeInsets.zero,
                                      //     )),
                                    ])),
                                Container(
                                    height: (((state.path.length) > 0) &&
                                            (state.path.last.isDocuments))
                                        ? 0
                                        : 20),
                                Row(
                                  children: [
                                    Container(width: 20),
                                    (((state.path.length) > 0) &&
                                            (state.path.last.isDocuments))
                                        ? SearchWidget()
                                        : Container(),
                                    Container(width: 20),
                                    (((state.path.length) > 0) &&
                                            (state.path.last.isDocuments ||
                                                isFileStorage))
                                        ? Container(
                                            width: 40,
                                            height: 40,
                                            child: (permissionLevel ==
                                                    UserPermissionLevel.Reader)
                                                ? Container()
                                                : RoundedIconButton(
                                                    Icons.add,
                                                    () {
                                                      widget.pageController
                                                          .addDocument();
                                                    },
                                                    insets: EdgeInsets.zero,
                                                  ))
                                        : Container()
                                  ],
                                ),
                                Container(height: 20),
                                DocumentSummaryCollection(
                                    (state.path).isEmpty,
                                    isFileStorage,
                                    basePaths,
                                    instanceSummaries,
                                    widget.pageController,
                                    widget.pageController)
                              ],
                            ),
                            (state.selectedDocument == null)
                                ? Container()
                                : DocumentForm(
                                    state.selectedDocument!
                                        .firstWhere(
                                            (element) => element.id == docId,
                                            orElse: () => DocumentProperty(
                                                '',
                                                DocumentForm
                                                    .documentNameForFiles,
                                                PropertyType.DocumentFile,
                                                ''))
                                        .value,
                                    state.selectedDocument!
                                        .firstWhere(
                                            (element) => element.id == docName,
                                            orElse: () => DocumentProperty(
                                                '',
                                                DocumentForm
                                                    .documentNameForFiles,
                                                PropertyType.DocumentFile,
                                                ''))
                                        .value,
                                    state.selectedDocument!, (filename) {
                                    return widget.services.storage
                                        .getAppFileUri(
                                            state.getStoragePath(), filename);
                                  }, widget.pageController, isFileStorage,
                                    widget.services, state.selectdDocumentNew),
                            (showActivityIndicator)
                                ? IgnorePointer(
                                    child: Container(
                                        color: Colors.transparent,
                                        height: screenHeight(context),
                                        width: screenWidth(context)))
                                : Container(),
                            (showActivityIndicator)
                                ? Center(
                                    child: Container(
                                        width: 60,
                                        height: 60,
                                        child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.black54))))
                                : Container(),
                          ]);
                        }))),
            Align(
                alignment: Alignment(0.0, -1.0),
                child: Container(
                    height: headerWidgetHeight(context),
                    child: HeaderWidget(widget.services,
                        currentProjectId != null, HeaderWidget.managerTitle)))
          ],
        ));
  }

  Widget projectSelectionWidget() {
    return Container();
  }
}
