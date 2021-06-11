// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';

import 'firebase_helper_web.dart';
import 'firebase_otherapp_helper_web.dart';

class UserStorage implements AbstractUserStorage {
  final firebaseHelper = FirebaseHelper();
  final valueString = 'value';

  @override
  Future<UserInfo?> loadUserInfo(String uid) async {
    Map<String, dynamic>? map;
    final event =
        await firebaseHelper.userDocumentReference(uid).once(valueString);
    map = event.snapshot.val();
    if (map == null) {
      return null;
    }
    return UserInfo.fromMap(map);
  }

  @override
  void observeUserInfo(String uid, Function(UserInfo) onEvent) {
    firebaseHelper.userDocumentReference(uid).onValue.listen((event) {
      if (event.snapshot.val() != null) {
        Map<String, dynamic> map = event.snapshot.val();
        onEvent(UserInfo.fromMap(map));
      }
    });
  }

  @override
  Future<void> saveUserInfo(UserInfo userInfo) async {
    await firebaseHelper
        .userDocumentReference(userInfo.id!)
        .set(userInfo.infoMap());
  }

  @override
  Future<UserInfo> createNewUser(
      String uid, String? namePrimary, String? email) async {
    final userMap = {
      'id': uid,
      'namePrimary': namePrimary,
      'email': email,
      'creationTimestamp': DateTime.now().millisecondsSinceEpoch,
      'editedTimestamp': DateTime.now().millisecondsSinceEpoch,
      'projects': []
    };
    firebaseHelper.userDocumentReference(uid).set(userMap);
    return UserInfo.fromMap(userMap);
  }
}

class ProjectStorage implements AbstractProjectStorage {
  final firebaseHelper = FirebaseHelper();
  final valueString = 'value';

  @override
  Future<void> checkInvites(String email) async {
    final cleanEmail = clean(email);
    var message =
        firebaseHelper.firebaseFunctions.httpsCallable('checkInvites');
    await message.call({'cleanEmail': cleanEmail, 'email': email});
  }

  @override
  Future<void> saveProjectInfo(
      String projectId, ProjectInfo projectInfo) async {
    await firebaseHelper
        .projectInfoReference(projectId)
        .set(projectInfo.infoMap());
  }

  @override
  Future<void> createProject(String projectId, String name, String? config,
      String? configIos, String? configAndroid) async {
    var message =
        firebaseHelper.firebaseFunctions.httpsCallable('createProject');
    final map = {
      'projectId': projectId,
      'name': name,
    };
    if (config != null) {
      map['config'] = config;
    }
    if (configIos != null) {
      map['configIos'] = configIos;
    }
    if (configAndroid != null) {
      map['configAndroid'] = configAndroid;
    }
    message.call(map);
  }

  @override
  Future<void> removeProject(String projectId) async {
    var message =
        firebaseHelper.firebaseFunctions.httpsCallable('removeProject');
    message.call({'projectId': projectId});
  }

  @override
  Future<void> saveProjectAuth(
      String projectId, String email, String permission) async {
    var message =
        firebaseHelper.firebaseFunctions.httpsCallable('saveProjectAuth');
    message.call({
      'email': email,
      'cleanEmail': clean(email),
      'projectId': projectId,
      'permission': permission
    });
  }

  @override
  Future<void> removeProjectAuth(String projectId, String email) async {
    var message =
        firebaseHelper.firebaseFunctions.httpsCallable('removeProjectAuth');
    message.call(
        {'email': email, 'cleanEmail': clean(email), 'projectId': projectId});
  }

  @override
  Future<List<Map<String, dynamic>>> loadProjectAuth(String projectId) async {
    final event =
        await firebaseHelper.projectAuthReference(projectId).once(valueString);
    final map = Map<String, dynamic>.from(event.snapshot.val());
    final secondaryMap =
        map.values.map((e) => Map<String, dynamic>.from(e)).toList();
    return secondaryMap;
  }

  @override
  void observeAuthInfo(
      String projectId, Function(List<Map<String, dynamic>>) onEvent) {
    firebaseHelper.projectAuthReference(projectId).onValue.listen((event) {
      if (event.snapshot.val() != null) {
        final map = Map<String, dynamic>.from(event.snapshot.val());
        final secondaryMap =
            map.values.map((e) => Map<String, dynamic>.from(e)).toList();
        onEvent(secondaryMap);
      }
    });
  }

  @override
  Future<List<DocumentInfo>> loadDocumentDefinitions(String projectId) async {
    final event = await firebaseHelper
        .projectDocumentDefinitionsReference(projectId)
        .once(valueString);
    if (event.snapshot.val() == null) {
      return [];
    }
    Map<String, dynamic> documentsMap = event.snapshot.val();
    return StorageHelper.documentDefinitionsFromMap(documentsMap);
  }

  @override
  Future<List<SchemaInfo>> loadSchemas(
      SchemaType schemaType, String projectId) async {
    final event = await firebaseHelper
        .projectSchemasReferenceBy(schemaType, projectId)
        .once(valueString);
    if (event.snapshot.val() == null) {
      return [];
    }
    Map<String, dynamic> documentsMap = event.snapshot.val();
    return StorageHelper.schemaInfosFromMap(documentsMap);
  }

  @override
  Future<void> removeDocumentDefinition(
      String projectId, String documentId) async {
    await firebaseHelper
        .projectDocumentDefinitionsReference(projectId)
        .child(documentId)
        .remove();
  }

  @override
  Future<void> removeSchema(
      SchemaType schemaType, String projectId, String schemaId) async {
    await firebaseHelper
        .projectSchemasReferenceBy(schemaType, projectId)
        .child(schemaId)
        .remove();
  }

  @override
  Future<void> saveDocumentDefinition(
      String projectId, String documentId, DocumentInfo documentInfo) async {
    final value = documentInfo.infoMap();
    await firebaseHelper
        .projectDocumentDefinitionsReference(projectId)
        .child(documentId)
        .set(value);
  }

  @override
  Future<void> saveSchema(SchemaType schemaType, String projectId,
      String schemaId, SchemaInfo schemaInfo) async {
    final value = schemaInfo.infoMap();
    await firebaseHelper
        .projectSchemasReferenceBy(schemaType, projectId)
        .child(schemaId)
        .set(value);
  }

  @override
  Future<void> saveAllDocuments(
      String projectId, List<DocumentInfo> documentDefinitions) async {
    Map<String, dynamic> value = {};
    documentDefinitions.forEach((document) {
      value[document.id!] = document.infoMap();
    });
    await firebaseHelper
        .projectDocumentDefinitionsReference(projectId)
        .set(value);
  }

  @override
  Future<void> saveAllSchemas(SchemaType schemaType, String projectId,
      List<SchemaInfo> schemaInfos) async {
    Map<String, dynamic> value = {};
    schemaInfos.forEach((schema) {
      value[schema.id!] = schema.infoMap();
    });
    await firebaseHelper
        .projectSchemasReferenceBy(schemaType, projectId)
        .set(value);
  }

  @override
  Future<ProjectInfo> loadProjectInfo(String projectId) async {
    Map<String, dynamic>? map;
    final event =
        await firebaseHelper.projectInfoReference(projectId).once(valueString);
    map = event.snapshot.val();
    return ProjectInfo.fromMap(map!);
  }

  @override
  void observeDocumentDefinitions(
      String projectId, Function(List<DocumentInfo>) onEvent) {
    firebaseHelper
        .projectDocumentDefinitionsReference(projectId)
        .onValue
        .listen((event) {
      if (event.snapshot.val() != null) {
        Map<String, dynamic> map = event.snapshot.val();
        onEvent(StorageHelper.documentDefinitionsFromMap(map));
      } else {
        onEvent([]);
      }
    });
  }

  @override
  void observeSchemas(SchemaType schemaType, String projectId,
      Function(List<SchemaInfo>) onEvent) {
    firebaseHelper
        .projectSchemasReferenceBy(schemaType, projectId)
        .onValue
        .listen((event) {
      if (event.snapshot.val() != null) {
        Map<String, dynamic> map = event.snapshot.val();
        onEvent(StorageHelper.schemaInfosFromMap(map));
      } else {
        onEvent([]);
      }
    });
  }

  @override
  void observeProjectInfo(String projectId, Function(ProjectInfo) onEvent) {
    firebaseHelper.projectDocumentReference(projectId).onValue.listen((event) {
      if (event.snapshot.val() != null) {
        Map<String, dynamic> map = event.snapshot.val();
        onEvent(ProjectInfo.fromMap(map));
      }
    });
  }

  @override
  Future<void> removeWidgetDefinition(String projectId, String widgetId) async {
    await firebaseHelper
        .projectWidgetDefinitionsReference(projectId)
        .child(widgetId)
        .remove();
  }
}

class AppStorage implements AbstractAppStorage {
  final valueString = 'value';
  late FirebaseOtherAppHelper otherAppHelper;

  @override
  void setOtherApp(Map<String, dynamic> config) {
    otherAppHelper = FirebaseOtherAppHelper(
        apiKey: config['apiKey'],
        authDomain: config['authDomain'],
        databaseURL: config['databaseURL'],
        projectId: config['projectId'],
        storageBucket: config['storageBucket'],
        messagingSenderId: config['messagingSenderId'],
        measurementId: config['measurementId'],
        appId: config['appId']);
  }

  @override
  Future<Map<String, dynamic>> getAppDocuments(
      SchemaType type, List<String> path) async {
    switch (type) {
      case SchemaType.firestore:
        return _firestoreDocuments(path);
      case SchemaType.realtime:
        return _realtimeDocuments(path);
      case SchemaType.storage:
        return _storageDocuments(path);
      default:
        assert(false);
        return {};
    }
  }

  Future<Map<String, dynamic>> _firestoreDocuments(List<String> path) async {
    final snapshot =
        await otherAppHelper.firestoreCollectionReferenceByPath(path).get();
    final docs =
        snapshot.docs.map((e) => Map<String, dynamic>.from(e.data())).toList();
    Map<String, dynamic> documentsMap = {};
    for (var doc in docs) {
      documentsMap[doc['zzvalue_doc_id']] = doc;
    }
    return documentsMap;
  }

  Future<Map<String, dynamic>> _realtimeDocuments(List<String> path) async {
    final event =
        await otherAppHelper.realtimeReferenceByPath(path).once(valueString);
    if (event.snapshot.val() == null) {
      return {};
    }
    Map<String, dynamic> documentsMap = event.snapshot.val();
    return documentsMap;
  }

  Future<Map<String, dynamic>> _storageDocuments(List<String> path) async {
    final directory =
        await otherAppHelper.directoryStorageByPath(path).listAll();
    final list = directory.items.map((e) => e.fullPath).toList();
    return {'files': list};
  }

  @override
  Future<void> saveAppDocument(SchemaType type, List<String> path,
      Map<String, dynamic> document, bool savePiecewise) async {
    switch (type) {
      case SchemaType.firestore:
        await _saveFirestoreDocument(path, document);
        break;
      case SchemaType.realtime:
        await _saveRealtimeDocument(path, document, savePiecewise);
        break;
      default:
        //do nothing
        return;
    }
  }

  Future<void> _saveFirestoreDocument(
      List<String> path, Map<String, dynamic> document) async {
    await otherAppHelper.firestoreDocumentReferenceByPath(path).set(document);
  }

  Future<void> _saveRealtimeDocument(List<String> path,
      Map<String, dynamic> document, bool savePiecewise) async {
    if (savePiecewise) {
      for (var key in document.keys) {
        await otherAppHelper
            .realtimeReferenceByPath(path)
            .child(key)
            .set(document[key]);
      }
    } else {
      await otherAppHelper.realtimeReferenceByPath(path).set(document);
    }
  }

  @override
  Future<void> deleteAppDocument(SchemaType type, List<String> path) async {
    if (type == SchemaType.firestore) {
      await _deleteFirestoreAppDocument(path);
    } else {
      await _deleteRealtimeAppDocument(path);
    }
  }

  Future<void> _deleteFirestoreAppDocument(List<String> path) async {
    otherAppHelper.firestoreDocumentReferenceByPath(path).delete();
  }

  Future<void> _deleteRealtimeAppDocument(List<String> path) async {
    otherAppHelper.realtimeReferenceByPath(path).remove();
  }

  @override
  Future<void> saveAppFile(
      List<String> path, String filename, Uint8List data) async {
    otherAppHelper.fileStorageByPath(path, filename).put(data);
  }

  @override
  Future<Uri> getAppFileUri(List<String> path, String filename) async {
    return await otherAppHelper
        .fileStorageByPath(path, filename)
        .getDownloadURL();
  }

  @override
  Future<void> deleteAppFile(List<String> path, String filename) async {
    await otherAppHelper.fileStorageByPath(path, filename).delete();
  }
}

class Storage1AppStackWeb
    with UserStorage, ProjectStorage, AppStorage
    implements StorageApi {}
