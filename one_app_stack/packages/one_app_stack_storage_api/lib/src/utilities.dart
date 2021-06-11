// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

snackBar(
    {required String content,
    required BuildContext context,
    bool warningColor = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.black,
    content: Text(
      content,
      style: TextStyle(
          color: warningColor ? Colors.redAccent : Colors.white,
          letterSpacing: 0.5),
    ),
  ));
}

double? safeDouble(dynamic value) {
  if (value is double) {
    return value;
  } else if (value is int) {
    return value.toDouble();
  } else {
    return null;
  }
}

String uniqueName(String desiredName, List<String> takenNames) {
  var index = 1;
  var newName = desiredName;
  while (takenNames.contains(newName)) {
    index += 1;
    newName = desiredName + index.toString();
  }
  return newName;
}

String clean(String input) {
  final invalidCharacters = ['.', '\$', '[', ']', '#', '/', '%'];
  var output = input;
  for (var char in invalidCharacters) {
    output = output.replaceAll(char, '');
  }
  return output;
}
