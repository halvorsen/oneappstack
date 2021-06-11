// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../../common_widget/rounded_button.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import '../../common_model/utilities.dart';
import 'popover_notifications.dart';

///Used when entering user text.
class TextFieldPopoverWidget extends StatefulWidget {
  //Should be refactored to accomplish a more flexible validation
  TextFieldPopoverWidget(this.title, this.type, this.initialText,
      this.invalidStrings, this.onValidChange, this.requireSubmission,
      {this.requireValidation = true});
  @override
  _TextFieldPopoverWidgetState createState() => _TextFieldPopoverWidgetState();
  final String title;
  final SchemaType? type;
  final String initialText;
  final List<String> invalidStrings;
  final Function(String value)? onValidChange;
  final bool requireSubmission;
  final bool requireValidation;

  static showTextFieldPopoverWidget(
      BuildContext context,
      String title,
      String initialText,
      SchemaType? type,
      List<String> invalidStrings,
      void Function(String value)? onValidTextChange,
      bool requireSubmission) {
    ShowPopOverNotification(context, LayerLink(),
            popChild: Container(
                width: 500,
                height: 230,
                child: TextFieldPopoverWidget(title, type, initialText,
                    invalidStrings, onValidTextChange, requireSubmission)),
            dismissOnBarrierClick: true)
        .dispatch(context);
  }
}

class _TextFieldPopoverWidgetState extends State<TextFieldPopoverWidget> {
  final key = GlobalKey<FormState>();
  final _controller = TextEditingController();
  @override
  void initState() {
    _controller.text = removeVarSyntax(widget.initialText);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: removeVarSyntax(widget.initialText).length,
    );
    lastValidName = removeVarSyntax(widget.initialText);
    super.initState();
  }

  String removeVarSyntax(String value) {
    if (value.contains('\$')) {
      return value.substring(2, value.length);
    } else {
      return value;
    }
  }

  String addVarSynax(String value) {
    return '\${' + value + '}';
  }

  bool? isVar;
  late String lastValidName;
  var isSubmitted = false;

  String? validated(String? value) {
    final invalidCharacters = ['.', '\$', '[', ']', '#', '/', '%'];
    var hasInvalidCharacters = false;
    invalidCharacters.forEach((element) {
      if (value?.contains(element) ?? false) {
        hasInvalidCharacters = true;
      }
    });
    if ((value == null || value.isEmpty)) {
      return 'Please enter some text';
    } else if (hasInvalidCharacters && widget.requireValidation) {
      return 'invalid characters, \"\$ [ ] # . / %\"';
    } else if (value.contains(' ') && widget.requireValidation) {
      return 'cannot contain spaces';
    } else if (widget.invalidStrings.contains(value) &&
        widget.requireValidation) {
      return 'name already in use';
    } else if (value == 'none' || value == 'null') {
      return 'invalid name';
    }
    if ((widget.requireSubmission && isSubmitted) ||
        !widget.requireSubmission) {
      if (widget.onValidChange != null) {
        lastValidName = value;
        final addSyntax = isVar ?? false;
        if (addSyntax) {
          widget.onValidChange!(addVarSynax(lastValidName));
        } else {
          widget.onValidChange!(lastValidName);
        }
      }
      if (widget.requireSubmission) {
        ClosePopoverNotification().dispatch(context);
      }
      return null;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: textfieldKey,
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 20.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 40,
            ),
          ),
          Container(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                width: 300,
                height: 80,
                child: Form(
                    key: key,
                    child: TextFormField(
                      controller: _controller,
                      onChanged: (value) {},
                      onEditingComplete: () {
                        isSubmitted = true;
                        key.currentState!.validate();
                        isSubmitted = false;
                        ClosePopoverNotification().dispatch(context);
                      },
                      // onFieldSubmitted: (_) {
                      //   ClosePopoverNotification().dispatch(context);
                      // },
                      autofocus: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        return validated(value);
                      },
                    ))),
            (widget.type != SchemaType.storage)
                ? Container()
                : Column(children: [
                    Text(
                      'var',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                      ),
                    ),
                    Switch(
                      value: isVar ?? false,
                      onChanged: (value) {
                        setState(() {
                          isVar = value;
                          if (isVar!) {
                            widget.onValidChange!(addVarSynax(lastValidName));
                          } else {
                            widget.onValidChange!(lastValidName);
                          }
                        });
                      },
                      activeTrackColor: Colors.green,
                      activeColor: Colors.greenAccent,
                    )
                  ])
          ]),
          widget.requireSubmission ? Container(height: 8) : Container(),
          widget.requireSubmission
              ? BlueGrayButton('Submit', () {
                  isSubmitted = true;
                  key.currentState!.validate();
                  isSubmitted = false;
                })
              : Container(),
        ],
      ),
    );
  }
}
