// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:firebase/firebase.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';

class FirebaseHelper {
  final firebaseDatabase = database();
  Functions get firebaseFunctions => functions();

  DatabaseReference userDocumentReference(String uid) =>
      firebaseDatabase.ref(FirebaseHelperString.user(uid));

  DatabaseReference projectDocumentReference(String projectId) =>
      firebaseDatabase.ref(FirebaseHelperString.project(projectId));

  DatabaseReference projectInfoReference(String projectId) =>
      projectDocumentReference(projectId).child('projectInfo');

  DatabaseReference firestoreSchemaDocumentReference(
          String projectId, String schemaId) =>
      projectDocumentReference(projectId)
          .child(FirebaseHelperString.firestoreSchema(schemaId));

  DatabaseReference realtimeSchemaDocumentReference(
          String projectId, String schemaId) =>
      projectDocumentReference(projectId)
          .child(FirebaseHelperString.realtimeSchema(schemaId));

  DatabaseReference storageSchemaDocumentReference(
          String projectId, String schemaId) =>
      projectDocumentReference(projectId)
          .child(FirebaseHelperString.storageSchema(schemaId));

  DatabaseReference documentDefinitionDocumentReference(
          String projectId, String definitionId) =>
      projectDocumentReference(projectId)
          .child(FirebaseHelperString.documentDefinition(definitionId));

  DatabaseReference widgetDefinitionDocumentReference(
          String projectId, String definitionId) =>
      projectDocumentReference(projectId)
          .child(FirebaseHelperString.widgetDefinition(definitionId));

  DatabaseReference termsReference(String uid) =>
      userDocumentReference(uid).child(FirebaseHelperString.terms);

  DatabaseReference projectAuthReference(String projectId) =>
      projectDocumentReference(projectId)
          .child(FirebaseHelperString.projectAuth);

  DatabaseReference projectDocumentDefinitionsReference(String projectId) =>
      projectDocumentReference(projectId)
          .child(FirebaseHelperString.documentDefinitions);

  DatabaseReference projectWidgetDefinitionsReference(String projectId) =>
      projectDocumentReference(projectId)
          .child(FirebaseHelperString.widgetDefinitions);

  DatabaseReference projectFirestoreSchemasReference(String projectId) =>
      projectDocumentReference(projectId)
          .child(FirebaseHelperString.firestoreSchemas);

  DatabaseReference projectRealtimeSchemasReference(String projectId) =>
      projectDocumentReference(projectId)
          .child(FirebaseHelperString.realtimeSchemas);

  DatabaseReference projectStorageSchemasReference(String projectId) =>
      projectDocumentReference(projectId)
          .child(FirebaseHelperString.storageSchemas);

  DatabaseReference projectSchemasReferenceBy(
      SchemaType type, String projectId) {
    switch (type) {
      case SchemaType.firestore:
        return projectFirestoreSchemasReference(projectId);
      case SchemaType.realtime:
        return projectRealtimeSchemasReference(projectId);
      case SchemaType.storage:
        return projectStorageSchemasReference(projectId);
      case SchemaType.document:
        return projectDocumentDefinitionsReference(projectId);
    }
  }
}
