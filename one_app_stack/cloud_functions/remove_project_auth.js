exports.main = mainFunction

// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

async function mainFunction(data, requesterId, admin) {
  const email = data.email
  const cleanEmail = data.cleanEmail
  const projectId = data.projectId
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
          const userAuthRef = db.ref(`projects/${projectId}/authInfo/${userId}`)
          userAuthRef.remove()

          var userProjectsRef = db.ref(`users/${userId}/projects`)
          // eslint-disable-next-line promise/no-nesting
          userProjectsRef.once("value", (snapshot) => {
            var list = snapshot.val()
            if (list === null) {
              return
            } else {
              if (list.includes(projectId)) {
                list = list.filter((item) => {
                  return item !== projectId
                 })
                userProjectsRef.set(list)
              }
            }
            return
            }).catch((_) => {
              
            })
        }
        return
      }).catch((_) => {
        const invitesRef = db.ref(`invites/${cleanEmail}`)
        invitesRef.remove()
        const userAuth = db.ref(`projects/${projectId}/authInfo/${cleanEmail}`)
        userAuth.remove()
      })
    }
  })
}