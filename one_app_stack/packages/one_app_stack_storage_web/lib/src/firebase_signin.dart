// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.
import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';

class FirebaseSignin extends FirebaseSigninApi {
  @override
  Future<void> initializeApp() async {
    //already initialized in index file
  }

  @override
  String? currentUserName() {
    return auth().currentUser?.displayName;
  }

  @override
  String? currentUserEmail() {
    return auth().currentUser?.email;
  }

  @override
  String? currentUserUid() {
    return auth().currentUser?.uid;
  }

  @override
  Future<void> signIn(BuildContext context, {String? appName}) async {
    var currentUser = currentUserEmail();
    if (currentUser == null && appName == null) {
      try {
        await _signInWithGoogle(context);
      } catch (error) {
        print(error);
      }
    } else if (appName != null) {
      App? app;
      try {
        app = apps.firstWhere((element) => element.name == appName);
      } catch (e) {}
      final isSignedIn = app?.auth().currentUser != null;
      try {
        if (!isSignedIn) {
          await _signInWithGoogle(context, appName: appName);
        }
      } catch (error) {
        print(error);
      }
    }
  }

  Future<void> _signInWithGoogle(BuildContext context,
      {String? appName}) async {
    try {
      final otherApp = (appName != null)
          ? apps.firstWhere((element) => element.name == appName)
          : null;
      await auth(otherApp).signInWithPopup(GoogleAuthProvider());
    } catch (error) {
      print(error);
    }
  }

  @override
  Future<void> signOut(BuildContext context, {String? appName}) async {
    try {
      for (var app in apps) {
        await auth(app).signOut();
      }
    } catch (e) {
      snackBar(
          content: 'Error signing out. Try again..',
          context: context,
          warningColor: true);
    }
  }
}
