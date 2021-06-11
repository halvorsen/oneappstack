// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import '../one_app_stack_storage_api.dart';

class StorageHelper {
  static List<SchemaInfo> schemaInfosFromMap(Map<String, dynamic> map) {
    var schemaList = <SchemaInfo>[];
    map.forEach((_, value) {
      final schemaInfo = SchemaInfo.fromMap(Map<String, dynamic>.from(value));
      schemaList.add(schemaInfo);
    });
    return schemaList;
  }

  static List<DocumentInfo> documentDefinitionsFromMap(
      Map<String, dynamic> map) {
    var documentList = <DocumentInfo>[];
    map.forEach((_, value) {
      final documentInfo =
          DocumentInfo.fromMap(Map<String, dynamic>.from(value));
      documentList.add(documentInfo);
    });
    return documentList;
  }
}
