// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

const saveProjectAuth = require('./save_project_auth')
const admin = require('firebase-admin')
const service = require('../../../service_key.json')
const { runWith } = require('firebase-functions')

admin.initializeApp({
  credential: admin.credential.cert(service),
  databaseURL: "https://oneappstack-default-rtdb.firebaseio.com"
})

const data = {
  'email': 'test',
  'cleanEmail': 'test',
  'projectId': 'test4',
  'permission': 'admin'
}

saveProjectAuth.main(data, 'uid_test', admin)

setTimeout(() => process.exit(), 3000);