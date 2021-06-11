// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import '../common_widget/decorated_container.dart';

import '../common_model/utilities.dart';
import 'package:flutter/material.dart';

class MarketingMessage {
  MarketingMessage(this.title, this.body);
  String title;
  String body;
}

class MarketingCellWidget extends StatelessWidget {
  MarketingCellWidget(this.messages, {this.imageNames, Key? key})
      : super(key: key);
  final List<MarketingMessage> messages;
  final List<String>? imageNames;

  Widget _textWidget(double width, String title, String body, String? imageName,
      bool? imageAbove, BuildContext context) {
    return Row(children: [
      Container(
          width: width,
          height: varyForScreenWidth((messages.length > 1) ? 430 : 280,
              (messages.length > 1) ? 430 : 280, null, null, context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (imageName != null && imageAbove != null && imageAbove)
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(width * 0.1, 0, 0, 0),
                      child: Container(
                          height: headerWidgetHeight(context) * 3,
                          child: Image.asset('assets/images/$imageName')))
                  : Container(height: 50),
              Text(
                title,
                style: varyForScreenWidth(
                    Theme.of(context).textTheme.headline1,
                    Theme.of(context).textTheme.headline2,
                    Theme.of(context).textTheme.headline2,
                    Theme.of(context).textTheme.headline2,
                    context),
                textAlign: TextAlign.left,
                softWrap: true,
              ),
              Container(
                height: 10,
              ),
              Text(
                body,
                style: varyForScreenWidth(
                    Theme.of(context).textTheme.bodyText1,
                    Theme.of(context).textTheme.bodyText2,
                    Theme.of(context).textTheme.bodyText2,
                    Theme.of(context).textTheme.bodyText2,
                    context),
                textAlign: TextAlign.left,
                softWrap: true,
              ),
              Container(height: 20)
            ],
          )),
      (imageName != null && imageAbove != null && !imageAbove)
          ? Container(
              height: headerWidgetHeight(context) * 4,
              child: Image.asset('assets/images/$imageName'))
          : Container()
    ]);
  }

  Widget _buildArrayWidget(
      double textWidth, double spacing, BuildContext context) {
    var children = <Widget>[];
    var index = 0;
    for (var message in messages) {
      children.add(
        _textWidget(textWidth, message.title, message.body, imageNames?[index],
            imageNames?.length != 1, context),
      );
      index += 1;
      children.add(
        Container(
          width: spacing,
          height: spacing,
        ),
      );
    }
    children.removeLast();
    return varyForScreenWidth(Row(children: children), Row(children: children),
        Column(children: children), Column(children: children), context);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = 40.0;
    final horizontalSpacing =
        varyForScreenWidth(120.0, 40.0, 40.0, 40.0, context);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final largeWidth = (constraints.maxWidth -
              spacing * (messages.length - 1) -
              horizontalSpacing * 2) /
          ((messages.length == 3) ? 3 : 2);
      final compactWidth = 300.0;
      final textWidth = varyForScreenWidth(
          largeWidth, largeWidth, compactWidth, compactWidth, context);
      return DecoratedContainer(
          child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalSpacing,
                  vertical: varyForScreenWidth(
                      0, 0, horizontalSpacing, horizontalSpacing, context)),
              child: _buildArrayWidget(textWidth, spacing, context)));
    });
  }
}
