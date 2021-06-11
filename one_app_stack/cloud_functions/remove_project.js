// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

exports.main = mainFunction

async function mainFunction(data, requesterId, admin) {

  const projectId = data.projectId

  const db = admin.database()
  const requesterAuthRef = db.ref(`projects/${projectId}/authInfo/${requesterId}/permission`)
  requesterAuthRef.once("value", (snapshot) => {
    const requesterAuth = snapshot
    if (requesterAuth.val() === 'admin') {

      const projectRef = db.ref(`projects/${projectId}`)
      projectRef.remove()
    }
  })
}