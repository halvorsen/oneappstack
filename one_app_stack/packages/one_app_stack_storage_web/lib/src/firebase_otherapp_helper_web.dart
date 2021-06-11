// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:firebase/firebase.dart';
import 'package:firebase/firestore.dart';

class FirebaseOtherAppHelper {
  FirebaseOtherAppHelper(
      {this.apiKey,
      this.authDomain,
      this.databaseURL,
      this.projectId,
      this.storageBucket,
      this.messagingSenderId,
      this.measurementId,
      this.appId})
      : otherApp = initializeOtherApp(projectId!,
            apiKey: apiKey,
            authDomain: authDomain,
            databaseURL: databaseURL,
            projectId: projectId,
            storageBucket: storageBucket,
            messagingSenderId: messagingSenderId,
            measurementId: measurementId,
            appId: appId) {
    realtimeDatabase = database(otherApp);
    firestoreDatabase = firestore(otherApp);
    storageDatabase = storage(otherApp);
  }

  final App otherApp;
  late Database realtimeDatabase;
  late Firestore firestoreDatabase;
  late Storage storageDatabase;

  final String? apiKey;
  final String? authDomain;
  final String? databaseURL;
  final String? projectId;
  final String? storageBucket;
  final String? messagingSenderId;
  final String? measurementId;
  final String? appId;

  static Map<String, bool> apps = {};
  static App initializeOtherApp(String name,
      {String? apiKey,
      String? authDomain,
      String? databaseURL,
      String? projectId,
      String? storageBucket,
      String? messagingSenderId,
      String? measurementId,
      String? appId}) {
    App? otherApp;
    if (apps[name] != null) {
      otherApp = app(name);
    }
    otherApp ??= initializeApp(
        apiKey: apiKey,
        authDomain: authDomain,
        databaseURL: databaseURL,
        projectId: projectId,
        storageBucket: storageBucket,
        messagingSenderId: messagingSenderId,
        name: name,
        measurementId: measurementId,
        appId: appId);
    apps[name] = true;
    return otherApp;
  }

  DatabaseReference realtimeReferenceByPath(List<String> path) =>
      realtimeDatabase.ref((path).join('/'));

  DocumentReference firestoreDocumentReferenceByPath(List<String> path) =>
      firestoreDatabase.doc((path).join('/'));

  CollectionReference firestoreCollectionReferenceByPath(List<String> path) =>
      firestoreDatabase.collection((path).join('/'));

  StorageReference fileStorageByPath(List<String> path, String filename) =>
      storageDatabase.ref(((path) + [filename]).join('/'));

  StorageReference directoryStorageByPath(List<String> path) =>
      storageDatabase.ref(((path)).join('/'));
}
