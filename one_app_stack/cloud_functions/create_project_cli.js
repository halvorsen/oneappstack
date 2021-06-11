// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

const createProject = require('./create_project')
const admin = require('firebase-admin')
const service = require('../../../service_key.json')

admin.initializeApp({
  credential: admin.credential.cert(service),
  databaseURL: "https://oneappstack-default-rtdb.firebaseio.com"
})

const data = {
  'projectId': 'test',
  'name': 'testName',
  'config': 'configText',
  'configIos': 'configIosText',
  'configAndroid': 'configAndroidText'
}

createProject.main(data, 'UTce0lfba2cPYoFQNBeY6OwDGUA3', admin)

setTimeout(() => process.exit(), 3000);