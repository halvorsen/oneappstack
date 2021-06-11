// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

//BLoC

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_app_stack/main_common.dart';
import '../../common_model/utilities.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import 'package:uuid/uuid.dart';

import '../../one_stack.dart';

class ProjectBloc extends Bloc<ProjectEvent, ImmutableProjectState> {
  CommonServices services;
  ProjectState projectState;
  bool createOnce = false;
  ProjectBloc(this.services, this.projectState)
      : super(ImmutableProjectState.from(projectState)) {
    _startProjectObserver();
  }

  void _startProjectObserver() {
    if (observeOnce && services.auth.currentUserUid() != null) {
      observeOnce = false;
      services.storage.observeUserInfo(services.auth.currentUserUid()!,
          (userInfo) async {
        projectState.showActivityIndicator = false;
        await _recordProjects(userInfo, services.auth.currentUserUid()!);
        this.add(YieldStateEvent());
      });
    }
  }

  Future<void> _recordProjects(UserInfo userInfo, String? uid) async {
    if (uid == null) {
      return;
    }
    var _projects = <ProjectInfo>[];
    final projectIds = userInfo.projects ?? [];
    for (var projectId in projectIds) {
      try {
        final projectInfo = await services.storage.loadProjectInfo(projectId);
        _projects.add(projectInfo);
      } catch (e) {
        final userInfo = await services.storage.loadUserInfo(uid);
        var projects = userInfo!.projects ?? [];
        projects.remove(projectId);
        userInfo.projects = projects;
        await services.storage.saveUserInfo(userInfo);
      }
    }
    projectState.projects = _projects;
  }

  Future<void> _updateUserIdEvent(String? uid) async {
    if (uid == null) {
      return;
    }
    try {
      projectState.userInfo = await services.storage.loadUserInfo(uid);
      if (projectState.userInfo == null) {
        await _createNewUser(uid);
      } else {
        await _recordProjects(projectState.userInfo!, uid);
      }
    } catch (e) {
      await _createNewUser(uid);
    }
    _startProjectObserver();
  }

  Future<void> _createNewUser(String uid) async {
    if (createOnce) {
      return;
    }
    createOnce = true;
    if (projectState.userInfo == null &&
        services.auth.currentUserEmail() != null) {
      final userInfo = await services.storage.createNewUser(uid,
          services.auth.currentUserName(), services.auth.currentUserEmail());
      projectState.userInfo = userInfo;
      services.storage.checkInvites(services.auth.currentUserEmail()!);
      _startProjectObserver();
    }
  }

  var observeOnce = true;
  Future<void> _saveProject(String? id, String name, String? config,
      String? configIos, String? configAndroid, BuildContext context) async {
    final projectId = id ?? Uuid().v4();
    projectState.showActivityIndicator = true;
    await services.storage
        .createProject(projectId, name, config, configIos, configAndroid);
  }

  void _exitDocument() {
    projectState.showProjectEditForm = false;
  }

  void _launchCreateProjectForm() {
    projectState.showProjectEditForm = true;
  }

  void _setMenu() {
    switch (services.platform.platform) {
      case AppPlatform.web:
        projectState.showManager = currentProjectConfig != null;
        break;
      case AppPlatform.ios:
      case AppPlatform.mac:
        projectState.showManager = currentProjectConfigIos != null;
        break;
      case AppPlatform.android:
        projectState.showManager = currentProjectConfigAndroid != null;
        break;
      default:
        projectState.showManager = currentProjectConfig != null;
    }
  }

  void _navigate(BuildContext context) {
    if (projectState.showManager) {
      services.appNavigation.navigateToManagerPage(context);
    } else {
      services.appNavigation.navigateToSettingsPage(context);
    }
  }

  Future<void> _selectedCellEvent(String id, BuildContext context) async {
    if (id == 'newProject') {
      if (services.auth.currentUserEmail() != null) {
        _launchCreateProjectForm();
      } else {
        services.auth.signIn(context).then((value) {
          _updateUserIdEvent(services.auth.currentUserUid());
        });
      }
    } else {
      currentProjectId = id;
      currentProjectConfigString = null;
      currentProjectConfigStringIos = null;
      currentProjectConfigStringAndroid = null;
      final projectInfo =
          await services.storage.loadProjectInfo(currentProjectId!);
      currentProjectName = projectInfo.namePrimary;
      currentProjectConfigStringIos = projectInfo.firebaseConfigIos;
      currentProjectConfigStringAndroid = projectInfo.firebaseConfigAndroid;
      currentProjectConfigString = projectInfo.firebaseConfig;

      permissionLevel = await _projectAuth();
      _setOtherApp(context);
      _setMenu();
      _navigate(context);
    }
  }

  Future<UserPermissionLevel> _projectAuth() async {
    final auth = await services.storage.loadProjectAuth(currentProjectId!);
    for (var map in auth) {
      if (map['email'] == services.auth.currentUserEmail()) {
        return UserPermissionHelper.levelEnum(map['permission']);
      }
    }
    return UserPermissionLevel.Reader;
  }

  void _setOtherApp(BuildContext context) {
    Map<String, dynamic>? configMap;
    switch (services.platform.platform) {
      case AppPlatform.web:
        configMap = currentProjectConfig;
        break;
      case AppPlatform.ios:
      case AppPlatform.mac:
        configMap = currentProjectConfigIos;
        break;
      case AppPlatform.android:
        configMap = currentProjectConfigAndroid;
        break;
      default:
        configMap = currentProjectConfig;
    }
    if (configMap != null) {
      try {
        services.storage.setOtherApp(configMap);
      } catch (error) {}
    }
  }

  @override
  Stream<ImmutableProjectState> mapEventToState(ProjectEvent event) async* {
    if (event is SelectCellEvent) {
      _selectedCellEvent(event.id, event.context);
      yield ImmutableProjectState.from(projectState);
    } else if (event is YieldStateEvent) {
      yield ImmutableProjectState.from(projectState);
    } else if (event is UpdateUserIdEvent) {
      await _updateUserIdEvent(event.uid);
      yield ImmutableProjectState.from(projectState);
    } else if (event is SelectExitNewProjectEvent) {
      _exitDocument();
      yield ImmutableProjectState.from(projectState);
    } else if (event is SaveProjectEvent) {
      _exitDocument();
      await _saveProject(event.id, event.name, event.config, event.configIos,
          event.configAndroid, event.context);
      yield ImmutableProjectState.from(projectState);
    }
  }
}

//BLoC events

abstract class ProjectEvent {}

///Yields the state to the streams that feed the widgets
class YieldStateEvent extends ProjectEvent {}

class UpdateUserIdEvent extends ProjectEvent {
  UpdateUserIdEvent(this.uid);
  String? uid;
}

class SelectCellEvent extends ProjectEvent {
  SelectCellEvent(this.id, this.context);
  final String id;
  final BuildContext context;
}

class SelectExitNewProjectEvent extends ProjectEvent {}

class SaveProjectEvent extends ProjectEvent {
  SaveProjectEvent(this.id, this.name, this.config, this.configIos,
      this.configAndroid, this.context);
  final String name;
  final String? config;
  final String? configIos;
  final String? configAndroid;
  final String? id;
  final BuildContext context;
}

//state

///This mutable state mimics the immutable state object and represents the data model of the schemas owned by a project.
class ProjectState {
  UserInfo? userInfo;
  List<ProjectInfo> projects = [];
  bool showProjectEditForm = false;
  bool showManager = currentProjectConfig != null;
  bool showActivityIndicator = false;
}

///This immutable state gets pushed to the widgets
@immutable
class ImmutableProjectState extends Equatable {
  ImmutableProjectState.from(ProjectState projectState)
      : projects = projectState.projects,
        userInfo = projectState.userInfo,
        showProjectEditForm = projectState.showProjectEditForm,
        showManager = projectState.showManager,
        showActivityIndicator = projectState.showActivityIndicator;

  ///Props are used to determine comparison of state between yields, if the state doesn't change, determined by the prop values the stream filters it out
  @override
  List<Object> get props {
    return [
      projects.map((e) => e.id).toList().join(),
      userInfo?.toJsonString() ?? '',
      showProjectEditForm,
      showManager,
      showActivityIndicator
    ];
  }

  final List<ProjectInfo> projects;
  final UserInfo? userInfo;
  final bool showProjectEditForm;
  final bool showManager;
  final bool showActivityIndicator;
}
