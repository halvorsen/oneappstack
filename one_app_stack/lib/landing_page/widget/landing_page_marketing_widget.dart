// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../common_model/utilities.dart';
import '../../common_widget/marketing_cell_app_options.dart';
import '../../common_widget/marketing_cell_widget.dart';
import '../../common_widget/rectangle_button.dart';
import '../../one_stack.dart';
import '../bloc/landing_page_bloc.dart';

class LandingPageMarketingWidget extends StatefulWidget {
  LandingPageMarketingWidget(this.services, {Key? key}) : super(key: key);
  final CommonServices services;
  @override
  _LandingPageMarketingWidgetState createState() =>
      _LandingPageMarketingWidgetState();
}

class _LandingPageMarketingWidgetState
    extends State<LandingPageMarketingWidget> {
  final bloc = LandingPageBloc(LandingPageState());

  @override
  void dispose() {
    bloc.close(); //stateful widget so this can be disposed. no method currently exists that calls when stateless widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalSpacing =
        varyForScreenWidth(120.0, 40.0, 40.0, 40.0, context);
    return ListView(
      children: [
        Padding(
            padding: EdgeInsets.fromLTRB(20 + horizontalSpacing, 40, 0, 20),
            child: Text(
                'One App Stack builds on Firebase to help you create your\n serverless application and manage your data',
                style: varyForScreenWidth(
                    Theme.of(context).textTheme.headline1,
                    Theme.of(context).textTheme.headline2,
                    Theme.of(context).textTheme.headline2,
                    Theme.of(context).textTheme.headline2,
                    context))),
        Padding(
            padding: EdgeInsets.fromLTRB(20 + horizontalSpacing, 0, 0,
                varyForScreenWidth(60, 60, 20, 20, context)),
            child: Row(
              children: [
                RectangleButton(
                    'Start',
                    () => widget.services.appNavigation
                        .navigateToProjectsPage(context),
                    Colors.white),
                Container(
                  width: 20,
                ),
                RectangleButton('Video', () => null, Colors.white),
              ],
            )),
        Padding(
            padding: EdgeInsets.all(20),
            child: MarketingCellWidget([
              MarketingMessage('Manage Your Content',
                  'One App Stack helps admin users manage content. Built on top of Google’s Firebase, One App Stack gives you easy access to view, add, arrange, and remove data from Firestore, Realtime Database, and Storage.'),
              MarketingMessage('Copy Code Snippets',
                  'Using the data paths (schemas) you create, One App Stack autogenerates a usable firebase abstraction to insert into your application and conrol the data locations you have defined.'),
              MarketingMessage('Create Data Paths',
                  'Easily combine paths and documents to give definition to your NoSQL database structure and File Storage.'),
            ], imageNames: [
              'whiteboard_sketch.png',
              'import_sketch.png',
              'coding_sketch.png'
            ])),
        Padding(
            padding: EdgeInsets.all(20),
            child: MarketingCellWidget([
              MarketingMessage('Autogenerate database rules',
                  'One App Stack knows the paths to your data so it can suggest storage rules to protect your data.'),
              MarketingMessage('Data Visualization',
                  'Visualize your backend with quickview visualization'),
              MarketingMessage('Firebase',
                  'With Firebase at the core of the backend, your apps are ready to be deployed broadly on any platform and scale safely'),
            ], imageNames: [
              'build_sketch.png',
              'icon_white.png',
              'coffee_sketch.png'
            ])),
        Padding(
            padding: EdgeInsets.all(20),
            child: MarketingCellWidget([
              MarketingMessage('One App Stack is in Alpha',
                  'One App Stack is an open source project that exists to build useful Firebase abstractions for headless app creation. Please direct feedback and feature requests to the issue tracker github.com/halvorsen/oneappstack/issues. To contribute start here: README.md @ github.com/halvorsen/oneappstack.'),
            ], imageNames: [
              'icon_white.png'
            ])),
        Padding(padding: EdgeInsets.all(20), child: MarketingCellAppOptions()),
      ],
    );
  }
}
