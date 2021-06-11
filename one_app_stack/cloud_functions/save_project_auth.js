// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

exports.main = mainFunction

async function mainFunction(data, requesterId, admin) {
  const email = data.email
  const cleanEmail = data.cleanEmail
  const projectId = data.projectId
  const permission = data.permission
  const db = admin.database()
  const requesterAuthRef = db.ref(`projects/${projectId}/authInfo/${requesterId}/permission`)
  requesterAuthRef.once("value", (snapshot) => {
    const requesterAuth = snapshot
    if (requesterAuth.val() === 'admin') {
      admin
      .auth()
      .getUserByEmail(email)
      .then((userRecord) => {
        const userId = userRecord.toJSON().uid
        if (userId !== requesterId) {
          const userAuthEmailRef = db.ref(`projects/${projectId}/authInfo/${userId}/email`)
          const userAuthPermissionRef = db.ref(`projects/${projectId}/authInfo/${userId}/permission`)
          userAuthEmailRef.set(email)
          userAuthPermissionRef.set(permission)

          var userProjectsRef = db.ref(`users/${userId}/projects`)
          // eslint-disable-next-line promise/no-nesting
          userProjectsRef.once("value", (snapshot) => {
            const list = snapshot.val()
            if (list === null) {
              var userProjectsRef = db.ref(`users/${userId}/projects`)
              userProjectsRef.set([projectId])
            } else {
              if (!list.includes(projectId)) {
                list.push(projectId)
                userProjectsRef.set(list)
              }
            }
            return
            }).catch((_) => {
              var userProjectsRef = db.ref(`users/${userId}/projects`)
              userProjectsRef.set([projectId])
            })
        }
        return
      }).catch((_) => {
        var invitesRef = db.ref(`invites/${cleanEmail}/${projectId}`)
        invitesRef.set(permission)
        const userAuthEmailRef = db.ref(`projects/${projectId}/authInfo/${cleanEmail}/email`)
        const userAuthPermissionRef = db.ref(`projects/${projectId}/authInfo/${cleanEmail}/permission`)
        userAuthEmailRef.set(email)
        userAuthPermissionRef.set(permission)
      })
    }
  })
}