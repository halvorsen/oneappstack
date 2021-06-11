// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

const removeProjectAuth = require('./remove_project_auth')
const admin = require('firebase-admin')
const service = require('../../../service_key.json')

admin.initializeApp({
  credential: admin.credential.cert(service),
  databaseURL: "https://oneappstack-default-rtdb.firebaseio.com"
})

const data = {
  'email': 'test',
  'cleanEmail': 'test@gmailcom',
  'projectId': 'test4'
}
removeProjectAuth.main(data, 'uid_test', admin)

setTimeout(() => process.exit(), 3000);