// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../manager_page/bloc/manager_logic.dart';
import '../../common_model/utilities.dart';
import '../../manager_page/widget/navigation_widget.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import '../../one_stack.dart';
import 'file_storage_manager_logic.dart';

//BLoC

class ManagerBloc extends Bloc<ManagerEvent, ImmutableManagerState> {
  CommonServices services;
  ManagerState managerState;

  ManagerBloc(this.services, this.managerState)
      : super(ImmutableManagerState.from(managerState)) {
    services.storage.observeSchemas(
        SchemaType.firestore, currentProjectId ?? '', (_schemas) {
      var schemas = List<SchemaInfo>.from(_schemas);
      schemas.sort((a, b) => a.index.compareTo(b.index));
      managerState.firestoreSchemas = schemas;
      this.add(YieldStateEvent());
    });
    services.storage.observeSchemas(SchemaType.realtime, currentProjectId ?? '',
        (_schemas) {
      var schemas = List<SchemaInfo>.from(_schemas);
      schemas.sort((a, b) => a.index.compareTo(b.index));
      managerState.realtimeSchemas = schemas;
      this.add(YieldStateEvent());
    });
    services.storage.observeSchemas(SchemaType.storage, currentProjectId ?? '',
        (_schemas) {
      var schemas = List<SchemaInfo>.from(_schemas);
      schemas.sort((a, b) => a.index.compareTo(b.index));
      managerState.storageSchemas = schemas;
      this.add(YieldStateEvent());
    });
    services.storage.observeDocumentDefinitions(currentProjectId ?? '',
        (_documents) {
      var documents = List<DocumentInfo>.from(_documents);
      documents.sort((a, b) => a.index.compareTo(b.index));
      managerState.documentDefinitions = documents;
      this.add(YieldStateEvent());
    });
    standardLogic = ManagerLogic(managerState, services);
    fileStorageLogic = FileStorageManagerLogic(managerState, services);
  }

  late ManagerLogic standardLogic;
  late ManagerLogic fileStorageLogic;

  ManagerLogic get _logic {
    //factory that inspects path to determine the business logic to apply to the incoming event.
    //storage logic has a lot of similarities to the database logic so we use similar interface with different implementations
    if (managerState.getTypeFromCurrentPath() == SchemaType.storage) {
      return fileStorageLogic;
    }
    return standardLogic;
  }

  ManagerLogic _firstSelectionLogic(String schemaId) {
    //factory that inspects path to determine the business logic to apply to the incoming event
    if (managerState.allSchemas.map((e) => e.id).toList().contains(schemaId)) {
      if (managerState.storageSchemas
          .map((e) => e.id)
          .toList()
          .contains(schemaId)) {
        return fileStorageLogic;
      }
    }
    return standardLogic;
  }

  @override
  Stream<ImmutableManagerState> mapEventToState(ManagerEvent event) async* {
    if (event is SelectPathElement) {
      _logic.checkIfInDocument();
      yield ImmutableManagerState.from(managerState);
      late ManagerLogic selectionLogic;
      if (managerState.path.isEmpty) {
        selectionLogic = _firstSelectionLogic(event.navigationElement!.id);
      } else {
        selectionLogic = _logic;
      }
      final shouldGetDocuments =
          await selectionLogic.selectPathElement(event.navigationElement!);
      yield ImmutableManagerState.from(managerState);
      if (shouldGetDocuments) {
        await selectionLogic.getDocuments();
        managerState.isFetchingNeededDataToContinue = false;
        yield ImmutableManagerState.from(managerState);
      }
    } else if (event is AddDocumentEvent) {
      _logic.addDocument();
      yield ImmutableManagerState.from(managerState);
    } else if (event is ExitDocumentEvent) {
      await _logic.exitDocument();
      yield ImmutableManagerState.from(managerState);
    } else if (event is YieldStateEvent) {
      yield ImmutableManagerState.from(managerState);
    } else if (event is SaveValidDocumentValuesEvent) {
      await _logic.saveValidDocumentValuesEvent(
          event.values, event.filesToSave);
      await _logic.getDocuments();
      yield ImmutableManagerState.from(managerState);
      await _logic.deleteFiles(event.filesToDelete);
    } else if (event is DeleteDocument) {
      await _logic.deleteDocument(event.documentId);
      yield ImmutableManagerState.from(managerState);
    } else if (event is ReturnUserEntryEvent) {
      final shouldGetDocuments =
          await _logic.returnUserEntriesEvent(event.value);
      if (shouldGetDocuments) {
        await _logic.getDocuments();
        managerState.isFetchingNeededDataToContinue = false;
        yield ImmutableManagerState.from(managerState);
      } else {
        await Future.delayed(Duration(milliseconds: 100));
        yield ImmutableManagerState.from(managerState);
      }
    } else if (event is ReplaceLastPathElement) {
      _logic.replaceLastPath(event.navigationElement);
      yield ImmutableManagerState.from(managerState);
    } else {
      addError(Exception('unsupported schema event'));
    }
  }
}

//BLoC events

abstract class ManagerEvent {}

///Yields the state to the streams that feed the widgets
class YieldStateEvent extends ManagerEvent {}

class AddDocumentEvent extends ManagerEvent {}

class ExitDocumentEvent extends ManagerEvent {}

class ReturnUserEntryEvent extends ManagerEvent {
  ReturnUserEntryEvent(this.value);
  final String value;
}

class DeleteDocument extends ManagerEvent {
  DeleteDocument(this.documentId);
  final String documentId;
}

class SelectPathElement extends ManagerEvent {
  SelectPathElement(this.navigationElement);
  final NavigationElement? navigationElement;
}

class ReplaceLastPathElement extends ManagerEvent {
  ReplaceLastPathElement(this.navigationElement);
  final NavigationElement navigationElement;
}

class SaveValidDocumentValuesEvent extends ManagerEvent {
  SaveValidDocumentValuesEvent(
      this.values, this.filesToSave, this.filesToDelete);
  final List<DocumentProperty> values;
  final Map<String, Uint8List> filesToSave;
  final List<String> filesToDelete;
}

//state

///This mutable state mimics the immutable state object and represents the data model of the schemas owned by a project.
class ManagerState {
  /// The path represents descrete nodes that can be navigated to. The tail of the path can be a collection of documents or a single document.
  /// Firestore and Realtime paths can potentially be n nodes deep, however good database designs will be flat and not go too deep
  /// In the case of file storage the path either represents the entire path in postion 0 or the path in position 0 and filename in position 1
  List<NavigationElement> path = [];

  ///The 'schema paths' and 'document definitions' here in the manager are the same ones defined explicitely in the schemas page also known by the
  /// more user friendly name: 'data-paths'
  List<SchemaInfo> firestoreSchemas = [];
  List<SchemaInfo> realtimeSchemas = [];
  List<SchemaInfo> storageSchemas = [];
  List<DocumentInfo> documentDefinitions = [];

  ///[userEntries] is used for interacting with the file storage schemas. Holds state
  ///information for where the user currently is adding, removing, editing files.
  List<String> userEntries = [];

  ///[currentDefinition] and [selectedDocument] are used for interacting with the firestore and realtime schemas.
  ///Holds state information for the current document getting added, removed, edited.
  DocumentInfo? currentDefinition;
  List<DocumentProperty>? selectedDocument;
  bool selectedDocumentNew = false;

  ///Userd by all the schemas [documents] has the state information for collections at given storage locations
  Map<String, dynamic>? documents;

  ///App state designating that there is currently an asynchronous network request
  bool isFetchingNeededDataToContinue = false;

  ///path returned by getStoragePath() is the lightweight path to the data that is equivalent to what firebase needs
  ///this is different from List<NavigationElement> path which is a heavier more descriptive path for the app to display more information
  ///lightweight path is derived from the heavier List<NavigationElement> path
  List<String> getStoragePath() {
    var list = <String>[];
    for (var element in path) {
      var isSchemaId = false;
      for (var schema in allSchemas) {
        if (schema.id == element.id) {
          isSchemaId = true;
          list.addAll(schema.path!);
        }
      }
      if (!isSchemaId) {
        list.add(element.name);
      }
    }
    return list;
  }

  List<String> getLastDocumentsPath() {
    var list = <String>[];
    var isDocument = false;
    for (var element in path) {
      var isSchemaId = false;
      for (var schema in allSchemas) {
        if (schema.id == element.id) {
          isDocument = false;
          isSchemaId = true;
          list.addAll(schema.path!);
        }
      }
      if (!isSchemaId) {
        isDocument = true;
        list.add(element.name);
      }
    }
    if (isDocument) {
      list.removeLast();
    }
    return list;
  }

  List<String> get allDocumentNames =>
      (documentDefinitions).map((e) => e.namePrimary!).toList();

  SchemaType getTypeFromCurrentPath() {
    SchemaType? _search(String id) {
      for (var schema in firestoreSchemas) {
        if (schema.id == id) {
          return SchemaType.firestore;
        }
      }
      for (var schema in realtimeSchemas) {
        if (schema.id == id) {
          return SchemaType.realtime;
        }
      }
      for (var schema in storageSchemas) {
        if (schema.id == id) {
          return SchemaType.storage;
        }
      }
      return null;
    }

    SchemaType? schema;
    if (path.length > 0) {
      schema = _search(path.last.id);
    }
    if (schema != null) {
      return schema;
    } else if (path.length > 1) {
      schema = _search(path[path.length - 2].id);
    }
    return schema ?? SchemaType.storage;
  }

  List<SchemaInfo> get allSchemas =>
      schemas(SchemaType.firestore) +
      schemas(SchemaType.realtime) +
      schemas(SchemaType.storage);

  List<SchemaInfo> schemas(SchemaType type) {
    switch (type) {
      case SchemaType.firestore:
        return firestoreSchemas;
      case SchemaType.realtime:
        return realtimeSchemas;
      case SchemaType.storage:
        return storageSchemas;
      case SchemaType.document:
        throw Error();
    }
  }

  static Map<String, dynamic> toMap(
      List<DocumentProperty> properties, SchemaType type) {
    Map<String, dynamic> map = {};
    for (var property in properties) {
      if (property.type == PropertyType.Branch && type == SchemaType.realtime) {
        //skip because realtime overwrites subtrees
      } else {
        map[property.name] = property.value;
      }
    }
    return map;
  }

  static bool shouldSavePiecewise(
      List<DocumentProperty> properties, SchemaType type) {
    for (var property in properties) {
      if (property.type == PropertyType.Branch && type == SchemaType.realtime) {
        return true;
      }
    }
    return false;
  }
}

///This immutable state gets pushed to the widgets
@immutable
class ImmutableManagerState extends Equatable {
  ImmutableManagerState.from(ManagerState managerState)
      : firestoreSchemas = managerState.firestoreSchemas,
        realtimeSchemas = managerState.realtimeSchemas,
        storageSchemas = managerState.storageSchemas,
        documentDefinitions = managerState.documentDefinitions,
        path = managerState.path,
        documents = managerState.documents,
        selectdDocumentNew = managerState.selectedDocumentNew,
        selectedDocument = managerState.selectedDocument,
        currentDefinition = managerState.currentDefinition,
        isFetchingNeededDataToContinue =
            managerState.isFetchingNeededDataToContinue,
        userEntries = managerState.userEntries;

  ///Props are used to determine comparison of state between yields, if the state doesn't change, determined by the prop values the stream filters it out
  @override
  List<Object> get props {
    return [
          SchemaInfo.prop(firestoreSchemas ?? []),
          SchemaInfo.prop(realtimeSchemas ?? []),
          SchemaInfo.prop(storageSchemas ?? []),
          DocumentInfo.prop(documentDefinitions ?? []),
          path.map((e) => e.id).toList().join(),
          documents?.keys ?? '',
          (selectedDocument != null),
          isFetchingNeededDataToContinue
        ] +
        userEntries;
  }

  final List<SchemaInfo>? firestoreSchemas;
  final List<SchemaInfo>? realtimeSchemas;
  final List<SchemaInfo>? storageSchemas;
  final List<DocumentInfo>? documentDefinitions;
  final List<NavigationElement> path;

  final DocumentInfo? currentDefinition;
  final Map<String, dynamic>? documents;
  final List<DocumentProperty>? selectedDocument;
  final bool selectdDocumentNew;

  final bool isFetchingNeededDataToContinue;
  final List<String> userEntries;

  List<String> getStoragePath() {
    var list = <String>[];
    for (var element in path) {
      var isSchemaId = false;
      for (var schema in allSchemas) {
        if (schema.id == element.id) {
          isSchemaId = true;
          list.addAll(schema.path!);
        }
      }
      if (!isSchemaId) {
        list.add(element.id);
      }
    }
    return list;
  }

  SchemaType getTypeFromCurrentPath({String? searchId}) {
    SchemaType? _search(String id) {
      for (var schema in (firestoreSchemas ?? [])) {
        if (schema.id == id) {
          return SchemaType.firestore;
        }
      }
      for (var schema in (realtimeSchemas ?? [])) {
        if (schema.id == id) {
          return SchemaType.realtime;
        }
      }
      for (var schema in (storageSchemas ?? [])) {
        if (schema.id == id) {
          return SchemaType.storage;
        }
      }
      return null;
    }

    SchemaType? schema;
    if (path.length > 0 || searchId != null) {
      schema = _search(searchId ?? path.last.id);
    }
    if (schema != null) {
      return schema;
    } else if (path.length > 1) {
      schema = _search(searchId ?? path[path.length - 2].id);
    }
    return schema ?? SchemaType.storage;
  }

  List<String> get allDocumentNames =>
      (documentDefinitions ?? []).map((e) => e.namePrimary!).toList();

  List<SchemaInfo> get allSchemas =>
      (schemas(SchemaType.firestore) ?? []) +
      (schemas(SchemaType.realtime) ?? []) +
      (schemas(SchemaType.storage) ?? []);

  List<SchemaInfo>? schemas(SchemaType type) {
    switch (type) {
      case SchemaType.firestore:
        return firestoreSchemas;
      case SchemaType.realtime:
        return realtimeSchemas;
      case SchemaType.storage:
        return storageSchemas;
      case SchemaType.document:
        return null;
    }
  }
}
