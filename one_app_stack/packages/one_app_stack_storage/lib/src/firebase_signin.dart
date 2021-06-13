// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../one_app_stack_storage.dart';

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
      FirebaseApp? app;
      try {
        app = Firebase.apps.firstWhere((element) => element.name == appName);
      } catch (e) {}
      final isSignedIn = (app != null)
          ? (FirebaseAuth.instanceFor(app: app).currentUser != null)
          : false;
      try {
        if (!isSignedIn) {
          final success = await _signInWithGoogle(context,
              appName: appName, email: email, password: password);
          return success;
        }
      } catch (error) {
        print(error);
        return false;
      }
    }
    return true;
  }

  @override
  bool isSignedIn(String appName) {
    try {
      final otherApp =
          Firebase.apps.firstWhere((element) => element.name == appName);
      return FirebaseAuth.instanceFor(app: otherApp).currentUser != null;
    } catch (error) {
      return false;
    }
  }

  Future<bool> _signInWithGoogle(BuildContext context,
      {String? appName, String? email, String? password}) async {
    try {
      final otherApp = (appName != null)
          ? Firebase.apps.firstWhere((element) => element.name == appName)
          : null;
      if (otherApp != null) {
        if (FirebaseAuth.instanceFor(app: otherApp).currentUser == null) {
          // this seems to be the only way to do this with current google sign in sdk
          try {
            await FirebaseAuth.instanceFor(app: otherApp)
                .signInWithEmailAndPassword(email: email!, password: password!);
            return true;
          } catch (error) {
            return false;
          }
        }
      } else {
        if (FirebaseAuth.instance.currentUser == null) {
          if (!Platform.isAndroid || !Platform.isIOS) {
            final success = await signInDesktop(context);
            return success;
          }
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
              return true;
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
    return false;
  }

  Future<bool> signInDesktop(BuildContext context) async {
    final info = ci;
    final id = ClientId(
        info['one']! +
            info['two']! +
            info['three']! +
            info['four']! +
            info['eight']!,
        info['five']! + info['six']! + info['seven']!);
    final scopes = ['email'];
    final client = Client();
    final credentials = await obtainAccessCredentialsViaUserConsent(
        id, scopes, client, (String url) => launch(url));
    client.close();
    final oauth = GoogleAuthProvider.credential(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken.data);
    try {
      await FirebaseAuth.instance.signInWithCredential(oauth);
      return true;
    } catch (error) {
      return false;
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
