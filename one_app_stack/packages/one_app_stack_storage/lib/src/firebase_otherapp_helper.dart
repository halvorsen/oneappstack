// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseOtherAppHelper {
  FirebaseOtherAppHelper(
      {this.apiKey,
      this.authDomain,
      this.databaseURL,
      this.projectId,
      this.storageBucket,
      this.messagingSenderId,
      this.measurementId,
      this.appId}) {
    initializeOtherApp(projectId!,
            apiKey: apiKey,
            authDomain: authDomain,
            databaseURL: databaseURL,
            projectId: projectId,
            storageBucket: storageBucket,
            messagingSenderId: messagingSenderId,
            measurementId: measurementId,
            appId: appId)
        .then((app) {
      otherApp = app;
      realtimeDatabase = FirebaseDatabase(app: otherApp);
      firestoreDatabase = FirebaseFirestore.instanceFor(app: otherApp);
      storageDatabase = FirebaseStorage.instanceFor(app: otherApp);
    });
  }

  late FirebaseApp otherApp;
  late FirebaseDatabase realtimeDatabase;
  late FirebaseFirestore firestoreDatabase;
  late FirebaseStorage storageDatabase;

  final String? apiKey;
  final String? authDomain;
  final String? databaseURL;
  final String? projectId;
  final String? storageBucket;
  final String? messagingSenderId;
  final String? measurementId;
  final String? appId;

  static Map<String, bool> apps = {};
  static Future<FirebaseApp> initializeOtherApp(String name,
      {String? apiKey,
      String? authDomain,
      String? databaseURL,
      String? projectId,
      String? storageBucket,
      String? messagingSenderId,
      String? measurementId,
      String? appId}) async {
    FirebaseApp? app;
    if (apps[name] != null) {
      app = Firebase.app(name);
    }
    app ??= await Firebase.initializeApp(
        name: name,
        options: FirebaseOptions(
            apiKey: apiKey!,
            authDomain: authDomain,
            databaseURL: databaseURL,
            projectId: projectId!,
            storageBucket: storageBucket,
            messagingSenderId: messagingSenderId!,
            measurementId: measurementId,
            appId: appId!));
    apps[name] = true;
    return app;
  }

  DatabaseReference realtimeReferenceByPath(List<String> path) =>
      realtimeDatabase.reference().child((path).join('/'));

  DocumentReference firestoreDocumentReferenceByPath(List<String> path) =>
      firestoreDatabase.doc((path).join('/'));

  CollectionReference firestoreCollectionReferenceByPath(List<String> path) =>
      firestoreDatabase.collection((path).join('/'));

  Reference fileStorageByPath(List<String> path, String filename) =>
      storageDatabase.ref(((path) + [filename]).join('/'));

  Reference directoryStorageByPath(List<String> path) =>
      storageDatabase.ref(((path)).join('/'));
}
