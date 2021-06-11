// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

const removeProject = require('./remove_project')
const admin = require('firebase-admin')
const service = require('../../../service_key.json')

admin.initializeApp({
  credential: admin.credential.cert(service),
  databaseURL: "https://oneappstack-default-rtdb.firebaseio.com"
})

const data = {
  'projectId': 'test'
}

removeProject.main(data, 'test-uid', admin)

setTimeout(() => process.exit(), 3000);