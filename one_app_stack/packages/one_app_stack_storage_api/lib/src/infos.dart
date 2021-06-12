// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'dart:convert';
import 'utilities.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final docName = 'zzvalue_name';
final docId = 'zzvalue_doc_id';
final docCreationId = 'zzvalue_creation';
final docLastEditedId = 'zzvalue_last_edited';

///---------data scheme objects ------------///

class CommonInfo {
  String? id;
  String? namePrimary;
  String? nameSecondary;
  String? descriptionPrimary;
  String? descriptionSeconary;
  double? creationTimestamp;
  double? editedTimestamp;
  List<String>? tags;

  CommonInfo(
      {this.id,
      this.namePrimary,
      this.nameSecondary,
      this.descriptionPrimary,
      this.descriptionSeconary,
      this.creationTimestamp,
      this.editedTimestamp,
      this.tags});

  factory CommonInfo.fromMap(Map<String, dynamic> map) {
    return CommonInfo(
        id: map['id'],
        namePrimary: map['namePrimary'],
        nameSecondary: map['nameSecondary'],
        descriptionPrimary: map['descriptionPrimary'],
        descriptionSeconary: map['descriptionSeconary'],
        creationTimestamp: safeDouble(map['creationTimestamp']),
        editedTimestamp: safeDouble(map['editedTimestamp']),
        tags: (map['tags'] != null) ? List<String>.from(map['tags']) : null);
  }

  factory CommonInfo.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    return CommonInfo.fromMap(map);
  }

  String toJsonString() => jsonEncode(infoMap());

  Map<String, dynamic> infoMap() {
    return {
      'id': id,
      'namePrimary': namePrimary,
      'nameSecondary': nameSecondary,
      'descriptionPrimary': descriptionPrimary,
      'descriptionSecondary': descriptionSeconary,
      'creationTimestamp': creationTimestamp,
      'editedTimestamp': editedTimestamp,
      'tags': tags
    };
  }

  CommonInfo.clone(CommonInfo commonInfo)
      : this(
            id: commonInfo.id,
            namePrimary: commonInfo.namePrimary,
            nameSecondary: commonInfo.nameSecondary,
            descriptionPrimary: commonInfo.descriptionPrimary,
            descriptionSeconary: commonInfo.descriptionSeconary,
            creationTimestamp: commonInfo.creationTimestamp,
            editedTimestamp: commonInfo.editedTimestamp,
            tags: commonInfo.tags);
}

class UserInfo extends CommonInfo {
  List<String>? projects;
  Map<String, String>? projectPermissions;

  UserInfo(
    CommonInfo commonInfo,
    this.projects,
    this.projectPermissions,
  ) : super.clone(commonInfo);

  factory UserInfo.fromMap(Map<String, dynamic> map) {
    return UserInfo(
      CommonInfo.fromMap(map),
      (map['projects'] != null) ? List<String>.from(map['projects']) : null,
      (map['projectPermissions'] != null)
          ? Map<String, String>.from(map['projectPermissions'])
          : null,
    );
  }

  factory UserInfo.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    return UserInfo.fromMap(map);
  }

  String toJsonString() => jsonEncode(infoMap());

  Map<String, dynamic> infoMap() {
    var map = super.infoMap();
    map['projects'] = projects;
    map['projectPermissions'] = projectPermissions;
    return map;
  }
}

class ProjectInfo extends CommonInfo {
  String? firebaseConfig;
  String? firebaseConfigIos;
  String? firebaseConfigAndroid;

  ProjectInfo({
    required CommonInfo commonInfo,
    this.firebaseConfig,
    this.firebaseConfigIos,
    this.firebaseConfigAndroid,
  }) : super.clone(commonInfo);

  factory ProjectInfo.fromMap(Map<String, dynamic> map) {
    return ProjectInfo(
      commonInfo: CommonInfo.fromMap(map),
      firebaseConfig: map['firebaseConfig'],
      firebaseConfigIos: map['firebaseConfigIos'],
      firebaseConfigAndroid: map['firebaseConfigAndroid'],
    );
  }

  factory ProjectInfo.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    return ProjectInfo.fromMap(map);
  }

  String toJsonString() => jsonEncode(infoMap());

  Map<String, dynamic> infoMap() {
    var map = super.infoMap();
    map['firebaseConfig'] = firebaseConfig;
    map['firebaseConfigIos'] = firebaseConfigIos;
    map['firebaseConfigAndroid'] = firebaseConfigAndroid;
    return map;
  }
}

class SchemaInfo extends CommonInfo {
  List<String>? path;
  int index;
  bool isBaseSchema;
  String? linkedDocument;

  SchemaInfo(CommonInfo commonInfo, this.path, this.index, this.linkedDocument,
      this.isBaseSchema)
      : super.clone(commonInfo);

  factory SchemaInfo.fromMap(Map<String, dynamic> map) {
    return SchemaInfo(
        CommonInfo.fromMap(map),
        (map['path'] != null) ? List<String>.from(map['path']) : null,
        map['index'],
        map['linkedDocument'],
        map['isBaseSchema']);
  }

  factory SchemaInfo.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    return SchemaInfo.fromMap(map);
  }

  String toJsonString() => jsonEncode(infoMap());

  Map<String, dynamic> infoMap() {
    var map = super.infoMap();
    map['path'] = path;
    map['id'] = id;
    map['index'] = index;
    map['linkedDocument'] = linkedDocument;
    map['isBaseSchema'] = isBaseSchema;
    return map;
  }

  static String prop(List<SchemaInfo> list) {
    return list
            .map((e) =>
                (e.id ?? '') +
                (e.namePrimary ?? '') +
                (e.index.toString()) +
                (e.linkedDocument ?? '') +
                (e.isBaseSchema.toString()))
            .toList()
            .join() +
        list.map((e) => e.path?.join() ?? '').toList().join();
  }
}

class DocumentInfo extends CommonInfo {
  List<DocumentProperty>? properties;
  int index;
  DocumentInfo(
    CommonInfo commonInfo,
    this.properties,
    this.index,
  ) : super.clone(commonInfo);

  factory DocumentInfo.fromMap(Map<String, dynamic> map) {
    return DocumentInfo(
        CommonInfo.fromMap(map),
        (map['properties'] != null)
            ? DocumentProperty.fromDynamic(map['properties'])
            : null,
        map['index']);
  }

  factory DocumentInfo.fromJson(String json) {
    Map<String, dynamic> map = jsonDecode(json);
    return DocumentInfo.fromMap(map);
  }

  String toJsonString() => jsonEncode(infoMap());

  Map<String, dynamic> infoMap() {
    var map = super.infoMap();
    map['properties'] = DocumentProperty.infoMapList(properties);
    map['index'] = index;
    return map;
  }

  static String prop(List<DocumentInfo> list) {
    if (list.isEmpty) {
      return '';
    }
    return list.map((e) => e.id!).toList().join() +
        list.map((e) => e.namePrimary!).toList().join() +
        list
            .map((e) => e.properties!
                .map((f) => (f.name + f.type.toString() + f.value.toString()))
                .toList())
            .toList()
            .join() +
        list
            .map((e) => e.index)
            .join(); //makes a string to compare to previous string to check for uniqueness
  }
}

class DocumentProperty {
  String id;
  String name;
  PropertyType type;
  dynamic value; //type dependant
  DocumentProperty(this.id, this.name, this.type, this.value);

  String get nameAndTypeString {
    return name + ' : ' + PropertyTypeHelper.string(type);
  }

  factory DocumentProperty.fromMap(Map<String, dynamic> map) {
    return DocumentProperty(map['id'], map['name'],
        PropertyTypeHelper.fromString(map['type']), map['value']);
  }

  static List<DocumentProperty> fromDynamic(dynamic value) {
    final list = List<dynamic>.from(value);
    return list
        .map((e) => DocumentProperty.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static List<DocumentProperty> assembleDocument(
      Map<String, dynamic> map,
      DocumentInfo? definition,
      List<SchemaInfo> projectSchemas,
      bool isNewDocument) {
    List<DocumentProperty> _requiredProperties(
      String? id,
    ) {
      return [
        DocumentProperty(docName, docName, PropertyType.RequiredProperty, id),
        DocumentProperty(docId, docId, PropertyType.RequiredProperty, id),
        DocumentProperty(
            docCreationId,
            docCreationId,
            PropertyType.RequiredProperty,
            DateTime.now().millisecondsSinceEpoch),
        DocumentProperty(
            docLastEditedId,
            docLastEditedId,
            PropertyType.RequiredProperty,
            DateTime.now().millisecondsSinceEpoch)
      ];
    }

    List<DocumentProperty> _listFromMap(
        Map<String, dynamic> map,
        DocumentInfo? definition,
        List<SchemaInfo> projectSchemas,
        bool includeDefaultFields) {
      final oldProperties = (definition?.properties ?? []) +
          (includeDefaultFields ? _requiredProperties(null) : []);
      final properties = List<DocumentProperty>.from(oldProperties);
      final newProperties = <DocumentProperty>[];
      for (var property in properties) {
        if (property.type == PropertyType.Branch) {
          final schemaName = projectSchemas
              .firstWhere((element) => element.id == property.value)
              .namePrimary;
          newProperties.add(DocumentProperty(property.id, property.name,
              property.type, {'name': schemaName, 'id': property.value}));
        } else if (property.id != docLastEditedId) {
          newProperties.add(DocumentProperty(
              property.id, property.name, property.type, map[property.name]));
        }
      }
      return newProperties;
    }

    List<DocumentProperty> document = [];

    if (isNewDocument) {
      document = _listFromMap({}, definition, projectSchemas, false);
      final id = Uuid().v4();
      document.addAll(_requiredProperties(id));
    } else {
      document = _listFromMap(map, definition, projectSchemas, true);
    }

    return document;
  }

  Map<String, dynamic> infoMap() {
    Map<String, dynamic> map = {};
    map['id'] = id;
    map['name'] = name;
    map['type'] = PropertyTypeHelper.string(type);
    map['value'] = value;
    return map;
  }

  static List<Map<String, dynamic>> infoMapList(List<DocumentProperty>? list) {
    if (list == null) {
      return [];
    }
    return list.map((e) => e.infoMap()).toList();
  }
}

enum PropertyType {
  DocumentString,
  DocumentInt,
  DocumentDouble,
  DocumentFile,
  DocumentStringList,
  DocumentIntList,
  DocumentDoubleList,
  DocumentFileList,
  Branch,
  RequiredProperty
}

class PropertyTypeHelper {
  static List<DropdownMenuItem> list(TextStyle? style) => [
        DropdownMenuItem(
          child: Text(PropertyTypeHelper.string(PropertyType.DocumentString),
              style: style),
          value: PropertyTypeHelper.string(PropertyType.DocumentString),
        ),
        DropdownMenuItem(
          child: Text(PropertyTypeHelper.string(PropertyType.DocumentInt),
              style: style),
          value: PropertyTypeHelper.string(PropertyType.DocumentInt),
        ),
        DropdownMenuItem(
          child: Text(PropertyTypeHelper.string(PropertyType.DocumentDouble),
              style: style),
          value: PropertyTypeHelper.string(PropertyType.DocumentDouble),
        ),
        DropdownMenuItem(
          child: Text(PropertyTypeHelper.string(PropertyType.DocumentFile),
              style: style),
          value: PropertyTypeHelper.string(PropertyType.DocumentFile),
        ),
        DropdownMenuItem(
          child: Text(
              PropertyTypeHelper.string(PropertyType.DocumentStringList),
              style: style),
          value: PropertyTypeHelper.string(PropertyType.DocumentStringList),
        ),
        DropdownMenuItem(
          child: Text(PropertyTypeHelper.string(PropertyType.DocumentIntList),
              style: style),
          value: PropertyTypeHelper.string(PropertyType.DocumentIntList),
        ),
        DropdownMenuItem(
          child: Text(
              PropertyTypeHelper.string(PropertyType.DocumentDoubleList),
              style: style),
          value: PropertyTypeHelper.string(PropertyType.DocumentDoubleList),
        ),
        DropdownMenuItem(
          child: Text(PropertyTypeHelper.string(PropertyType.DocumentFileList),
              style: style),
          value: PropertyTypeHelper.string(PropertyType.DocumentFileList),
        ),
        DropdownMenuItem(
          child: Text(PropertyTypeHelper.string(PropertyType.Branch),
              style: style),
          value: PropertyTypeHelper.string(PropertyType.Branch),
        ),
      ];

  static String string(PropertyType type) {
    switch (type) {
      case PropertyType.DocumentString:
        return 'String';
      case PropertyType.DocumentInt:
        return 'Int';
      case PropertyType.DocumentDouble:
        return 'Double';
      case PropertyType.DocumentFile:
        return 'File';
      case PropertyType.DocumentStringList:
        return 'List<String>';
      case PropertyType.DocumentIntList:
        return 'List<Int>';
      case PropertyType.DocumentDoubleList:
        return 'List<Double>';
      case PropertyType.DocumentFileList:
        return 'List<File>';
      case PropertyType.Branch:
        return 'Branch';
      default:
        return '';
    }
  }

  static PropertyType fromString(String string) {
    switch (string) {
      case 'String':
        return PropertyType.DocumentString;
      case 'Int':
        return PropertyType.DocumentInt;
      case 'Double':
        return PropertyType.DocumentDouble;
      case 'File':
        return PropertyType.DocumentFile;
      case 'List<String>':
        return PropertyType.DocumentStringList;
      case 'List<Int>':
        return PropertyType.DocumentIntList;
      case 'List<Double>':
        return PropertyType.DocumentDoubleList;
      case 'List<File>':
        return PropertyType.DocumentFileList;
      case 'Branch':
        return PropertyType.Branch;
      default:
        throw Error();
    }
  }

  static String codeGenString(PropertyType type) {
    switch (type) {
      case PropertyType.DocumentString:
        return 'String';
      case PropertyType.DocumentInt:
        return 'Int';
      case PropertyType.DocumentDouble:
        return 'Double';
      case PropertyType.DocumentFile:
        return 'String';
      case PropertyType.DocumentStringList:
        return 'List<String>';
      case PropertyType.DocumentIntList:
        return 'List<Int>';
      case PropertyType.DocumentDoubleList:
        return 'List<Double>';
      case PropertyType.DocumentFileList:
        return 'List<String>';
      case PropertyType.Branch:
        return 'String';
      default:
        return '';
    }
  }

  static isList(PropertyType type) {
    return (type == PropertyType.DocumentDoubleList ||
        type == PropertyType.DocumentStringList ||
        type == PropertyType.DocumentIntList ||
        type == PropertyType.DocumentFileList);
  }
}
