// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../../one_stack.dart';
import 'popover_notifications.dart';

class SigninWidget extends StatefulWidget {
  SigninWidget(this.services);
  @override
  _SigninWidgetState createState() => _SigninWidgetState();
  final CommonServices services;
  static showSigninWidget(CommonServices services, BuildContext context) {
    ShowPopOverNotification(
      context,
      LayerLink(),
      popChild:
          Container(width: 500, height: 200, child: SigninWidget(services)),
      useBarrier: true,
      dismissOnBarrierClick: true,
    ).dispatch(context);
  }
}

class _SigninWidgetState extends State<SigninWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Sign In or Create Account',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 30,
                ),
              ),
              Container(height: 20),
              FutureBuilder(
                future: widget.services.auth.initializeApp(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error initializing Firebase');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return GoogleSigninButton(widget.services);
                  }
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.orange,
                    ),
                  );
                },
              ),
            ],
          ),
        ));
  }
}

class GoogleSigninButton extends StatefulWidget {
  GoogleSigninButton(this.services);
  final CommonServices services;
  @override
  _GoogleSigninButtonState createState() => _GoogleSigninButtonState();
}

class _GoogleSigninButtonState extends State<GoogleSigninButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _isSigningIn
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color?>(
                  Theme.of(context).textTheme.headline1!.color),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isSigningIn = true;
                });

                await widget.services.auth.signIn(context);
                ClosePopoverNotification().dispatch(context);
                RefreshScreenNotification().dispatch(context);
                setState(() {
                  _isSigningIn = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage("assets/images/google_logo.png"),
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.headline1!.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
