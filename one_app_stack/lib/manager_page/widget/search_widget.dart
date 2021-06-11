// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../common_model/utilities.dart';

class SearchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 200,
        height: 40,
        decoration: BoxDecoration(
          color: grayda,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextFormField(
          onChanged: (value) {},
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 10.0),
            hintText: 'Search',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          onEditingComplete: () => null,
          onFieldSubmitted: (_) => null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ));
  }
}
