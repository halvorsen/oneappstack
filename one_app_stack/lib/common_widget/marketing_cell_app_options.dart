// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../../common_widget/rounded_button.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import 'package:url_launcher/url_launcher.dart';

import 'decorated_container.dart';

import '../common_model/utilities.dart';

class MarketingCellAppOptions extends StatelessWidget {
  void _launchUrl(String url, BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      snackBar(content: 'coming soon...', context: context);
    }
  }

  void _launchDownload(BuildContext context) async {
    snackBar(content: 'coming soon...', context: context);
  }

  Row _linkRow(String title, String url, BuildContext context) {
    return Row(children: [
      Container(
          width: 70,
          child: Text(title,
              style: varyForScreenWidth(
                  Theme.of(context).textTheme.bodyText1,
                  Theme.of(context).textTheme.bodyText2,
                  Theme.of(context).textTheme.bodyText2,
                  Theme.of(context).textTheme.bodyText2,
                  context))),
      RoundedIconButton(Icons.link, () => _launchUrl(url, context),
          backgroundColor: Colors.transparent)
    ]);
  }

  // ignore: unused_element
  Row _downloadRow(String title, BuildContext context) {
    return Row(children: [
      Container(
          width: 70,
          child: Text(title,
              style: varyForScreenWidth(
                  Theme.of(context).textTheme.bodyText1,
                  Theme.of(context).textTheme.bodyText2,
                  Theme.of(context).textTheme.bodyText2,
                  Theme.of(context).textTheme.bodyText2,
                  context))),
      TransparentButton('download', () => _launchDownload(context))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final horizontalSpacing =
        varyForScreenWidth(120.0, 40.0, 40.0, 40.0, context);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return DecoratedContainer(
          height: varyForScreenWidth(370, 350, 450, 450, context),
          child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalSpacing,
                  vertical: varyForScreenWidth(
                      horizontalSpacing * 0.25,
                      horizontalSpacing * 0.25,
                      horizontalSpacing,
                      horizontalSpacing,
                      context)),
              child: Column(
                children: [
                  Container(height: 40),
                  Row(children: [
                    Text(
                        'Thanks to Flutter, One App Stack is available (or soon to be available):',
                        textAlign: TextAlign.left,
                        style: varyForScreenWidth(
                            Theme.of(context).textTheme.bodyText1,
                            Theme.of(context).textTheme.bodyText2,
                            Theme.of(context).textTheme.bodyText2,
                            Theme.of(context).textTheme.bodyText2,
                            context))
                  ]),
                  Container(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Column(children: [
                        _linkRow('Web', 'oneappstack.web.app', context),
                        Container(height: 10),
                        _linkRow('iOS', '', context),
                        Container(height: 10),
                        _linkRow('Android', '', context)
                      ]),
                      Container(
                        width: 50,
                      ),
                      Column(
                        children: [
                          _linkRow('Windows', '', context),
                          Container(height: 10),
                          _linkRow('Linux', '', context),
                          Container(height: 10),
                          _linkRow('Mac', '', context),
                        ],
                      )
                    ],
                  )
                ],
              )));
    });
  }
}
