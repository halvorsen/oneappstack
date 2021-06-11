// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

class FirebaseHelperString {
  static user(String uid) => 'users/$uid';
  static project(String id) => 'projects/$id';
  static firestoreSchema(String uuid) => 'firestoreSchemas/$uuid';
  static realtimeSchema(String uuid) => 'realtimeSchemas/$uuid';
  static storageSchema(String uuid) => 'storageSchemas/$uuid';
  static documentDefinition(String uuid) => 'documentDefinitions/$uuid';
  static widgetDefinition(String uuid) => 'widgetDefinitions/$uuid';
  static final firestoreSchemas = 'firestoreSchemas';
  static final realtimeSchemas = 'realtimeSchemas';
  static final storageSchemas = 'storageSchemas';
  static final documentDefinitions = 'documentDefinitions';
  static final widgetDefinitions = 'widgetDefinitions';
  static final terms = 'terms';
  static final projectAuth = 'authInfo';
}
