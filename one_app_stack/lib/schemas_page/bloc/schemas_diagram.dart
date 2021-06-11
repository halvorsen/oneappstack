// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../../common_model/utilities.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import './schemas_bloc.dart';

class SchemasDiagram {
  final head = DiagramNode(null, '', [], SchemaType.firestore,
      stringValue: 'db-root', depth: 0.0);
  final ImmutableSchemasState _state;
  SchemasDiagram(this._state) {
    _assemble();
  }
  Widget widget(BuildContext context) {
    BoxDecoration myBoxDecoration() {
      return BoxDecoration(
        border: Border.all(),
      );
    }

    var stack = [head];
    var children = <Widget>[];
    while (stack.isNotEmpty) {
      final currentNode = stack.removeLast();
      Widget widget = Container();
      if (currentNode.stringValue is String) {
        widget = Container(
            padding: const EdgeInsets.all(10.0),
            child: Text(currentNode.stringValue,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: varyForOneScreenWidth(14, context, large: 20),
                    height: 1.6,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)));
      } else {
        List<String> strings = currentNode.stringValue;
        var children = <Widget>[];
        if (strings.isNotEmpty) {
          var once = false;
          for (var text in (strings)) {
            children.add(Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(text,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize:
                            varyForOneScreenWidth(14, context, large: 20.0),
                        height: 1.6,
                        fontWeight: once ? FontWeight.normal : FontWeight.bold,
                        color: Colors.black54))));
            once = true;
          }
          widget = Container(
              padding: const EdgeInsets.all(10.0),
              decoration: myBoxDecoration(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children));
        }
      }
      children.add(Padding(
          padding: varyForOneScreenWidth(
              EdgeInsets.fromLTRB(
                  currentNode.depth * 25.0 + 15.0, 2.0, 5.0, 2.0),
              context,
              large: EdgeInsets.fromLTRB(
                  currentNode.depth * 70.0 + 30.0, 5.0, 10.0, 5.0)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            (currentNode.depth == 0.0)
                ? Container()
                : Padding(
                    padding: EdgeInsets.only(
                        top: varyForOneScreenWidth(5.0, context, large: 7.0)),
                    child: Icon(
                      Icons.arrow_right,
                      color: black28,
                      size: varyForOneScreenWidth(25, context, large: 35),
                    )),
            widget
          ])));

      stack.addAll(currentNode.children.reversed);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: children,
    );
  }

  void _assemble() {
    for (var schema
        in ((_state.firestoreSchemas ?? []) + (_state.realtimeSchemas ?? []))) {
      final docId = schema.linkedDocument;
      final doc = (docId == null)
          ? null
          : (_state.documentDefinitions ?? [])
              .firstWhere((element) => element.id == docId);
      final isBaseSchema = schema.isBaseSchema;
      final type = _state.getTypeFrom(schema.id!);
      if (isBaseSchema) {
        final pathNode = DiagramNode(schema, '', [], type,
            stringValue: (schema.path ?? []).join('  -  '), depth: 1.0);
        head.addChild(pathNode);
        pathNode.addChild(DiagramNode(
            doc,
            (schema.path! + ['\$' + _lower((doc?.namePrimary ?? '')) + 'Id'])
                .join('/'),
            [doc?.namePrimary ?? ''],
            type,
            stringValue: [doc?.namePrimary ?? ''] +
                (doc?.properties ?? []).map((e) {
                  return e.nameAndTypeString;
                }).toList(),
            depth: 2.0));
      }
    }
    var _leafDocuments = DiagramNode.allDocumentLeafs(head);
    final _timeout = 7;
    var _count = 0;
    while (_leafDocuments.isNotEmpty && _timeout > _count) {
      for (var documentNode in _leafDocuments) {
        final documentInfo = documentNode.value as DocumentInfo;
        final documentProperties = documentInfo.properties ?? [];
        for (var property in documentProperties) {
          if (property.type == PropertyType.Branch) {
            String pathName = property.value;
            final schema = _state.allSchemas
                .firstWhere((element) => element.namePrimary == pathName);
            final docId = schema.linkedDocument;
            final doc = (docId == null)
                ? null
                : (_state.documentDefinitions ?? [])
                    .firstWhere((element) => element.id == docId);
            final pathNode = DiagramNode(
                schema,
                documentNode.path + '/' + property.name,
                documentNode.documentNames,
                documentNode.type,
                stringValue: (schema.path ?? []).join('  -  '),
                depth: documentNode.depth + 1.0);
            documentNode.addChild(pathNode);
            pathNode.addChild(DiagramNode(
                doc,
                ([documentNode.path] +
                        schema.path! +
                        ['\$' + _upper((doc?.namePrimary ?? '')) + 'Id'])
                    .join('/'),
                documentNode.documentNames + [(doc?.namePrimary ?? '')],
                documentNode.type,
                stringValue: [doc?.namePrimary ?? ''] +
                    (doc?.properties ?? []).map((e) {
                      return e.nameAndTypeString;
                    }).toList(),
                depth: documentNode.depth + 2.0));
          }
        }
      }
      _leafDocuments = DiagramNode.allDocumentLeafs(head);
      ++_count;
    }
  }

  String _upper(String name) {
    return name.capitalize();
  }

  String _lower(String name) {
    return name.lowerCaseFirst();
  }
}

class DiagramNode {
  var children = <DiagramNode>[];
  final dynamic value; //tree of DocumentInfos and SchemaInfos values
  final dynamic
      stringValue; //tree of strings and List<Strings> that will be displayed
  final String path;
  final List<String> documentNames;
  final SchemaType type;
  final double depth;

  DiagramNode(this.value, this.path, this.documentNames, this.type,
      {required this.stringValue, required this.depth});

  void addChild(DiagramNode node) {
    children.add(node);
  }

  void addChildren(List<DiagramNode> nodes) {
    children.addAll(nodes);
  }

  static List<DiagramNode> allDocumentLeafs(DiagramNode node) {
    List<DiagramNode> allLeafs = [];
    List<DiagramNode> stack = [node];
    while (stack.isNotEmpty) {
      final currentNode = stack.removeLast();
      if (currentNode.value is DocumentInfo && currentNode.children.isEmpty) {
        allLeafs.add(currentNode);
      }
      stack.addAll(currentNode.children);
    }
    return allLeafs;
  }
}
