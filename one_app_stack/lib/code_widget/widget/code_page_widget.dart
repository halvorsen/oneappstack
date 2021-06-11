// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../code_widget/generators/code_generator.dart';
import '../../code_widget/generators/code_generator_c.dart';
import '../../code_widget/generators/code_generator_dart.dart';
import '../../code_widget/generators/code_generator_java.dart';
import '../../code_widget/generators/code_generator_kotlin.dart';
import '../../code_widget/generators/code_generator_nodejs.dart';
import '../../code_widget/generators/code_generator_rules.dart';
import '../../code_widget/generators/code_generator_swift.dart';
import '../../code_widget/generators/code_generator_unity.dart';
import '../../common_widget/rounded_button.dart';
import '../../schemas_page/bloc/schemas_diagram.dart';

import '../../one_stack.dart';
import '../../common_model/utilities.dart';

class CodePageWidget extends StatelessWidget {
  CodePageWidget(this.services, this.schemasDiagram, this.currentLanguage,
      {Key? key})
      : super(key: key);
  final CommonServices services;
  final SchemasDiagram schemasDiagram;
  final String currentLanguage;

  CodeGenerator get codeGenerator {
    switch (currentLanguage) {
      case 'dart':
        return CodeGeneratorDart(schemasDiagram);
      case 'swift':
        return CodeGeneratorSwift(schemasDiagram);
      case 'java':
        return CodeGeneratorJava(schemasDiagram);
      case 'kotlin':
        return CodeGeneratorKotlin(schemasDiagram);
      case 'nodejs':
        return CodeGeneratorNodeJs(schemasDiagram);
      case 'c++':
        return CodeGeneratorC(schemasDiagram);
      case 'unity':
        return CodeGeneratorUnity(schemasDiagram);
      default:
        return CodeGeneratorDart(schemasDiagram);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryPadding = 20.0;
    final edgePadding = varyForScreenWidth(0.0, 0.0, 0.0, 0.0, context);
    return Container(
        color: Colors.white38,
        child: Column(
          children: [
            Row(children: [
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: primaryPadding, horizontal: edgePadding),
                      child: Text('Class Snippets',
                          style: Theme.of(context).textTheme.headline1))),
              Container(
                width: 20,
              ),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                      width: 40,
                      height: 40,
                      child: RoundedIconButton(
                        Icons.content_copy,
                        () {
                          Clipboard.setData(
                              ClipboardData(text: codeGenerator.code));
                        },
                        fontSize: 30,
                        backgroundColor: Colors.transparent,
                        insets: EdgeInsets.zero,
                      ))),
              Container(width: 20)
            ]),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(codeGenerator.code,
                    style: TextStyle(
              fontSize: 14,
              height: 1.6,
              letterSpacing: 1.7,
              fontWeight: FontWeight.normal,
              color: Colors.black54))),
            Row(children: [
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: primaryPadding, horizontal: edgePadding),
                      child: Text(
                        'Rules Snippets',
                        style: Theme.of(context).textTheme.headline1,
                        softWrap: true,
                      ))),
              Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                      width: 40,
                      height: 40,
                      child: RoundedIconButton(
                        Icons.content_copy,
                        () {},
                        fontSize: 30,
                        backgroundColor: Colors.transparent,
                        insets: EdgeInsets.zero,
                      ))),
              Container(width: 20)
            ]),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Text(CodeGeneratorRules(schemasDiagram).code,
                    style: Theme.of(context).textTheme.bodyText1)),
          ],
        ));
  }
}
