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
  Future<bool> signIn(BuildContext context,
      {String? appName, String? email, String? password}) async {
    var currentUser = currentUserEmail();
    if (currentUser == null && appName == null) {
      try {
        return await _signInWithGoogle(context);
      } catch (error) {
        print(error);
        return false;
      }
    } else if (appName != null) {
      App? app;
      try {
        app = apps.firstWhere((element) => element.name == appName);
      } catch (e) {}
      final isSignedIn = app?.auth().currentUser != null;
      try {
        if (!isSignedIn) {
          return await _signInWithGoogle(context, appName: appName);
        }
      } catch (error) {
        print(error);
        return false;
      }
    }
    return false;
  }

  @override
  bool isSignedIn(String appName) {
    try {
      final otherApp = apps.firstWhere((element) => element.name == appName);
      return auth(otherApp).currentUser != null;
    } catch (error) {
      return false;
    }
  }

  Future<bool> _signInWithGoogle(BuildContext context,
      {String? appName}) async {
    try {
      final otherApp = (appName != null)
          ? apps.firstWhere((element) => element.name == appName)
          : null;
      await auth(otherApp).signInWithPopup(GoogleAuthProvider());
      return true;
    } catch (error) {
      print(error);
      return false;
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
