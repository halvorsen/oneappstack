// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

abstract class FirebaseSigninApi {
  Future<void> initializeApp();

  String? currentUserName();
  String? currentUserEmail();
  String? currentUserUid();

  Future<bool> signIn(BuildContext context,
      {String? appName, String? email, String? password});
  bool isSignedIn(String appName);

  Future<void> signOut(BuildContext context);
}
