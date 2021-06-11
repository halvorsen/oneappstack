// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'dart:typed_data';

import '../one_app_stack_storage_api.dart';
import 'infos.dart';

abstract class AbstractUserStorage {
  //Setters
  Future<UserInfo> createNewUser(
      String uid, String? namePrimary, String? email);
  Future<void> saveUserInfo(UserInfo userInfo);
  Future<UserInfo?> loadUserInfo(String uid);
  void observeUserInfo(String uid, Function(UserInfo) onEvent);
}

abstract class AbstractProjectStorage {
  //Setters
  Future<void> saveProjectInfo(String projectId, ProjectInfo projectInfo);
  Future<void> saveProjectAuth(
      String projectId, String email, String permission);
  Future<List<Map<String, dynamic>>> loadProjectAuth(String projectId);
  void observeAuthInfo(
      String projectId, Function(List<Map<String, dynamic>>) onEvent);
  Future<void> removeProjectAuth(String projectId, String email);
  Future<void> removeProject(String projectId);
  Future<void> createProject(String projectId, String name, String? config,
      String? configIos, String? configAndroid);
  Future<void> saveSchema(SchemaType schemaType, String projectId,
      String schemaId, SchemaInfo schemaInfo);
  Future<void> saveAllSchemas(
      SchemaType schemaType, String projectId, List<SchemaInfo> schemaInfos);
  Future<void> saveAllDocuments(
      String projectId, List<DocumentInfo> documentDefinitions);
  Future<void> saveDocumentDefinition(
      String projectId, String documentId, DocumentInfo documentInfo);
  Future<void> removeSchema(
      SchemaType schemaType, String projectId, String schemaId);
  Future<void> removeDocumentDefinition(String projectId, String documentId);
  Future<void> removeWidgetDefinition(String projectId, String widgetId);

  //Getters
  Future<ProjectInfo> loadProjectInfo(String projectId);
  Future<List<SchemaInfo>> loadSchemas(SchemaType schemaType, String projectId);
  Future<List<DocumentInfo>> loadDocumentDefinitions(String projectId);
  Future<void> checkInvites(String email);

  void observeProjectInfo(String projectId, Function(ProjectInfo) onEvent);
  void observeSchemas(SchemaType schemaType, String projectId,
      Function(List<SchemaInfo>) onEvent);
  void observeDocumentDefinitions(
      String projectId, Function(List<DocumentInfo>) onEvent);
}

abstract class AbstractAppStorage {
  Future<Map<String, dynamic>> getAppDocuments(
      SchemaType type, List<String> path);
  Future<void> saveAppDocument(
      SchemaType type,
      List<String> path,
      Map<String, dynamic> document,
      bool
          savePiecewise); // for realtime, piecewise saves document property by property and skips any data-pahs that branch off
  Future<void> deleteAppDocument(SchemaType type, List<String> path);

  Future<void> saveAppFile(List<String> path, String filename, Uint8List data);
  Future<void> deleteAppFile(List<String> path, String filename);
  Future<Uri> getAppFileUri(List<String> path, String filename);

  void setOtherApp(Map<String, dynamic> config);
}

abstract class StorageApi
    implements
        AbstractProjectStorage,
        AbstractUserStorage,
        AbstractAppStorage {}
