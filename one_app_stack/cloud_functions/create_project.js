// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

exports.main = mainFunction

async function mainFunction(data, requesterId, admin) {
  const projectId = data.projectId
  const name = data.name
  var config = data.config
  var configIos = data.configIos
  var configAndroid = data.configAndroid

  if ( typeof config === 'undefined' ) {
    config = null
  }
  if ( typeof configIos === 'undefined' ) {
    configIos = null
  }
  if ( typeof configAndroid === 'undefined' ) {
    configAndroid = null
  }

  const db = admin.database()
  const projectRef = db.ref(`projects/${projectId}`)
  admin
      .auth()
      .getUser(requesterId)
      .then((userRecord) => {
        const email = userRecord.toJSON().email
  // eslint-disable-next-line promise/no-nesting
  projectRef.once("value", (snapshot) => {
    const project = snapshot
    if (project.val() === null && email !== null) {
      
      projectRef.set(
        {
          'projectInfo': {
            'id': projectId,
            'namePrimary': name,
            'firebaseConfig': config,
            'firebaseConfigIos': configIos,
            'firebaseConfigAndroid': configAndroid
          },
          'authInfo': {[requesterId]: {
            'email': email,
            'permission': 'admin'
          }
          }
      })
    }
    const userId = requesterId
    var userProjectsRef = db.ref(`users/${userId}/projects`)
    // eslint-disable-next-line promise/no-nesting
    userProjectsRef.once("value", (snapshot) => {
      var list = snapshot.val()
      if (list === null) {
        userProjectsRef.set([projectId])
      } else {
        list.push(projectId)
        userProjectsRef.set(list)
      }
      return
    }).catch((_) => {
      userProjectsRef.set([projectId])
    })
    return
  }).catch((_) => {
  })
  return
}).catch((_) => {
})
}