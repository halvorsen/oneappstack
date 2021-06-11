// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

const functions = require('firebase-functions')
const admin = require('firebase-admin')
const checkInvites = require('./check_invites')
const saveProjectAuth = require('./save_project_auth')
const removeProjectAuth = require('./remove_project_auth')
const createProject = require('./create_project')
const removeProject = require('./remove_project')

admin.initializeApp()

//cloud functions are used for cases where 1. the database rules aren't adaquate to manage approval for a read/write. 2. anything project access related, ie giving and revoking admin or other approval for any given project.

exports.saveProjectAuth = functions.https.onCall((data, context) => {
  if (!context.auth) {
    return {message: 'Auth Required', code: 401}
  } else {
    context.auth.
    saveProjectAuth.main(data, context.auth.uid, admin)
    return {message: 'Success', code: 400}
  }
})

exports.removeProjectAuth = functions.https.onCall((data, context) => {
  if (!context.auth) {
    return {message: 'Auth Required', code: 401}
  } else {
    removeProjectAuth.main(data, context.auth.uid, admin)
    return {message: 'Success', code: 400}
  }
})

exports.createProject = functions.https.onCall((data, context) => {
  if (!context.auth) {
    return {message: 'Auth Required', code: 401}
  } else {
    createProject.main(data, context.auth.uid, admin)
    return {message: 'Success', code: 400}
  }
})

exports.removeProject = functions.https.onCall((data, context) => {
  if (!context.auth) {
    return {message: 'Auth Required', code: 401}
  } else {
    removeProject.main(data, context.auth.uid, admin)
    return {message: 'Success', code: 400}
  }
})

exports.checkInvites = functions.https.onCall((data, context) => {
  if (!context.auth) {
    return {message: 'Auth Required', code: 401}
  } else {
    checkInvites.main(data, context.auth.uid, admin)
    return {message: 'Success', code: 400}
  }
})