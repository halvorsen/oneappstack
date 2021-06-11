// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

enum SchemaType { firestore, realtime, storage, document }

class SchemaTypeString {
  final value = {
    SchemaType.firestore: 'firestore',
    SchemaType.realtime: 'realtime',
    SchemaType.storage: 'storage',
    SchemaType.document: 'document'
  };
}
