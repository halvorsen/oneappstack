// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

exports.main = mainFunction

async function mainFunction(data, requesterId, admin) {
  const cleanEmail = data.cleanEmail
  const email = data.email
  var db = admin.database()
  var invitesRef = db.ref(`invites/${cleanEmail}`)
  invitesRef.once("value", (snapshot) => {
    const invitesMap = snapshot.toJSON()
    if (invitesMap === null) {
      return 
    }
    const projectIds = Object.keys(invitesMap)
    const userId = requesterId

    var userProjectsRef = db.ref(`users/${userId}/projects`)
    // eslint-disable-next-line promise/no-nesting
    userProjectsRef.once("value", (snapshot) => {
      var list = snapshot.val()
      if (list === null) {
        var userProjectsRef = db.ref(`users/${userId}/projects`)
        userProjectsRef.set(projectIds)
        invitesRef.remove()
        for (let i = 0; i < projectIds.length; i++) {
          const id = projectIds[i]
          const userAuth = db.ref(`projects/${id}/authInfo/${cleanEmail}`)
          userAuth.remove()
          const userAuthEmailRef = db.ref(`projects/${id}/authInfo/${userId}/email`)
          const userAuthPermissionRef = db.ref(`projects/${id}/authInfo/${userId}/permission`)
          userAuthEmailRef.set(email)
          userAuthPermissionRef.set(invitesMap[id])
        }
      } else {
        for (let i = 0; i < projectIds.length; i++) {
          const id = projectIds[i]
          if (!list.includes(id)) {
            list.push(id)
          }
          const userAuthEmailRef = db.ref(`projects/${id}/authInfo/${userId}/email`)
          const userAuthPermissionRef = db.ref(`projects/${id}/authInfo/${userId}/permission`)
          userAuthEmailRef.set(email)
          userAuthPermissionRef.set(invitesMap[id])
        }
        userProjectsRef.set(list)
        invitesRef.remove()
      }
      return
    }).catch((_) => {
      var userProjectsRef = db.ref(`users/${userId}/projects`)
      userProjectsRef.set(projectIds)
    })
  })
}