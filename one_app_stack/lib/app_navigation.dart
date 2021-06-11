// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'project_page/bloc/project_bloc.dart';
import 'common_model/utilities.dart';
import 'schemas_page/bloc/schemas_bloc.dart';

import 'common_widget/main_app_scaffold.dart';
import 'landing_page/widget/landing_page_widget.dart';
import 'manager_page/bloc/manager_bloc.dart';
import 'manager_page/widget/manager_page_widget.dart';
import 'one_stack.dart';
import 'project_page/widget/project_page_widget.dart';
import 'schemas_page/widget/schemas_page_widget.dart';
import 'settings/widget/settings_page_widget.dart';

enum AppPage { Landing, Projects, Schemas, Manager, Snippets, Settings }

abstract class AppNavigationApi {
  MaterialApp materialApp();
  Future<void> navigateToLandingPage(BuildContext context);
  Future<void> navigateToProjectsPage(BuildContext context);
  Future<void> navigateToSchemasPage(BuildContext context);
  Future<void> navigateToSettingsPage(BuildContext context);
  Future<void> navigateToManagerPage(BuildContext context);
}

class AppNavigation implements AppNavigationApi {
  AppNavigation(this.services);

  static final routeName = {
    AppPage.Landing: '/landing',
    AppPage.Projects: '/projects',
    AppPage.Schemas: '/schemas',
    AppPage.Manager: '/manager',
    AppPage.Snippets: '/snippets',
    AppPage.Settings: '/settings'
  };

  CommonServices services;
  AppPage first = AppPage.Landing;
  AppPage? current = AppPage.Landing;
  AppPage? previous;

  MaterialApp materialApp() {
    return MaterialApp(
      title: '1AppStack',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: teal,
        accentColor: Color(0xff0086EB),
        canvasColor: Colors.white,
        buttonColor: Color(0xff0088F3),
        textTheme: TextTheme(
          headline1: TextStyle(
              fontSize: 22,
              height: 1.6,
              fontWeight: FontWeight.normal,
              color: Colors.black54),
          headline2: TextStyle(
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.normal,
              color: Colors.black54),
          headline3: TextStyle(
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.normal,
              color: Colors.black54),
          button: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black54),
          bodyText1: TextStyle(
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.normal,
              color: Colors.black54),
          bodyText2: TextStyle(
              fontSize: 12,
              height: 1.6,
              fontWeight: FontWeight.normal,
              color: Colors.black54),
          headline5: TextStyle(
              fontSize: 50, fontWeight: FontWeight.w200, color: black28),
          headline6: TextStyle(
              //Button
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black54),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: AppNavigation.routeName[AppPage.Landing],
      home: LandingPageWidget(services),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/landing':
            return FadeRoute(
                page: WillPopScope(
                    onWillPop: () async {
                      return false;
                    },
                    child: MainAppScaffold(
                        child: () => LandingPageWidget(services))));
          case '/projects':
            return FadeRoute(
                page: WillPopScope(onWillPop: () async {
              _setPopScreenValues();
              return true;
            }, child: MainAppScaffold(child: () {
              final bloc = ProjectBloc(services, ProjectState());
              return ProjectPageWidget(services, bloc);
            })));
          case '/schemas':
            return FadeRoute(
                page: WillPopScope(onWillPop: () async {
              _setPopScreenValues();
              return true;
            }, child: MainAppScaffold(child: () {
              final bloc = SchemasBloc(services, SchemasState());
              return SchemasPageWidget(services, bloc);
            })));
          case '/manager':
            return FadeRoute(
                page: WillPopScope(onWillPop: () async {
              _setPopScreenValues();
              return true;
            }, child: MainAppScaffold(child: () {
              final bloc = ManagerBloc(services, ManagerState());
              return ManagerPageWidget(services, bloc);
            })));
          case '/snippets':
            break;
          case '/settings':
            return FadeRoute(
                page: WillPopScope(onWillPop: () async {
              _setPopScreenValues();
              return true;
            }, child: MainAppScaffold(child: () {
              return SettingsPageWidget(services);
            })));
          default:
            break;
        }
        return null;
      },
    );
  }

  void _setPopScreenValues() {
    final next = previous;
    previous = current;
    current = next;
  }

  @override
  Future<void> navigateToProjectsPage(BuildContext context) async {
    if (current == AppPage.Projects) {
      return null;
    }
    previous = current;
    current = AppPage.Projects;
    await Navigator.pushNamed(
        context, AppNavigation.routeName[AppPage.Projects]!);
  }

  @override
  Future<void> navigateToSchemasPage(BuildContext context) async {
    if (current == AppPage.Schemas) {
      return null;
    }
    previous = current;
    current = AppPage.Schemas;
    await Navigator.pushNamed(
        context, AppNavigation.routeName[AppPage.Schemas]!);
  }

  @override
  Future<void> navigateToManagerPage(BuildContext context) async {
    if (current == AppPage.Manager) {
      return null;
    }
    previous = current;
    current = AppPage.Manager;
    await Navigator.pushNamed(
        context, AppNavigation.routeName[AppPage.Manager]!);
  }

  @override
  Future<void> navigateToSettingsPage(BuildContext context) async {
    if (current == AppPage.Settings) {
      return null;
    }
    previous = current;
    current = AppPage.Settings;
    await Navigator.pushNamed(
        context, AppNavigation.routeName[AppPage.Settings]!);
  }

  @override
  Future<void> navigateToLandingPage(BuildContext context) async {
    if (current == AppPage.Landing) {
      return null;
    }
    previous = current;
    current = AppPage.Landing;
    if (previous == AppPage.Landing) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamed(context, AppNavigation.routeName[AppPage.Landing]!);
    }
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget? page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page!,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
