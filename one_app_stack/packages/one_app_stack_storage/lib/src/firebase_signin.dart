// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseSignin extends FirebaseSigninApi {
  @override
  Future<void> initializeApp() async {
    await Firebase.initializeApp();
  }

  Future<void> initializeOtherApp(String name,
      {String? apiKey,
      String? authDomain,
      String? databaseURL,
      String? projectId,
      String? storageBucket,
      String? messagingSenderId,
      String? measurementId,
      String? appId}) async {
    await Firebase.initializeApp(
        name: name,
        options: FirebaseOptions(
            apiKey: apiKey!,
            authDomain: authDomain,
            databaseURL: databaseURL,
            projectId: projectId!,
            storageBucket: storageBucket,
            messagingSenderId: messagingSenderId!,
            measurementId: measurementId,
            appId: appId!));
  }

  @override
  String? currentUserName() {
    return FirebaseAuth.instance.currentUser?.displayName;
  }

  @override
  String? currentUserEmail() {
    return FirebaseAuth.instance.currentUser?.email;
  }

  @override
  String? currentUserUid() {
    return FirebaseAuth.instance.currentUser?.uid;
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
      FirebaseApp? app;
      try {
        app = Firebase.apps.firstWhere((element) => element.name == appName);
      } catch (e) {}
      final isSignedIn = (app != null)
          ? (FirebaseAuth.instanceFor(app: app).currentUser != null)
          : false;
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
          ? Firebase.apps.firstWhere((element) => element.name == appName)
          : null;
      if (otherApp != null) {
        if (FirebaseAuth.instanceFor(app: otherApp).currentUser == null) {
          // this seems to be the only way to do this with current google sign in sdk
          FirebaseAuth.instanceFor(app: otherApp)
              .signInWithEmailAndPassword(email: '', password: '');
        }
      } else {
        if (FirebaseAuth.instance.currentUser == null) {
          final googleSignInAccount = await GoogleSignIn().signIn();
          if (googleSignInAccount != null) {
            final googleSignInAuthentication =
                await googleSignInAccount.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: googleSignInAuthentication.accessToken,
              idToken: googleSignInAuthentication.idToken,
            );
            try {
              await FirebaseAuth.instance.signInWithCredential(credential);
            } on FirebaseAuthException catch (error) {
              if (error.code == 'account-exists-with-different-credential') {
                snackBar(
                    content:
                        'The account already exists with a different password.',
                    context: context,
                    warningColor: true);
              } else if (error.code == 'invalid-credential') {
                snackBar(
                    content: 'Error occurred. Try again.',
                    context: context,
                    warningColor: true);
              }
            } catch (e) {
              snackBar(
                  content: 'Error occurred. Try again.',
                  context: context,
                  warningColor: true);
            }
          }
        }
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Future<void> signOut(BuildContext context) async {
    try {
      for (var app in Firebase.apps) {
        await FirebaseAuth.instanceFor(app: app).signOut();
      }
    } catch (e) {
      snackBar(
          content: 'Error signing out. Try again..',
          context: context,
          warningColor: true);
    }
  }
}
