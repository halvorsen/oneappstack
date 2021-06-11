// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//events

abstract class LandingPageEvent {}

class ShowVideoEvent extends LandingPageEvent {
  ShowVideoEvent(this.isOn);
  final bool isOn;
}

class StartEvent extends LandingPageEvent {}

//BLoC

class LandingPageBloc
    extends Bloc<LandingPageEvent, ImmutableLandingPageState> {
  LandingPageBloc(this.landingPageState)
      : super(ImmutableLandingPageState.from(landingPageState));

  @override
  Stream<ImmutableLandingPageState> mapEventToState(
      LandingPageEvent event) async* {
    if (event is ShowVideoEvent) {
      _showVideo(event.isOn);
      yield ImmutableLandingPageState.from(landingPageState);
    } else if (event is StartEvent) {
      _start();
      yield ImmutableLandingPageState.from(landingPageState);
    } else {
      addError(Exception('unsupported LandingPage event'));
    }
  }

  LandingPageState landingPageState;

  void _showVideo(bool isOn) {
    landingPageState.showVideo = isOn;
  }

  void _start() {
    landingPageState.start = true;
  }
}

//state

class LandingPageState {
  LandingPageState({this.showVideo = false, this.start = false});

  bool start;
  bool showVideo;
}

@immutable
class ImmutableLandingPageState extends Equatable {
  ImmutableLandingPageState.from(LandingPageState schemasState)
      : start = schemasState.start,
        showVideo = schemasState.showVideo;

  @override
  List<Object> get props => [start, showVideo];

  final bool start;
  final bool showVideo;
}
