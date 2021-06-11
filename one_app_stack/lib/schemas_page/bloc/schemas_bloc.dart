// Copyright 2021 One App Stack Authors. All rights reserved.
// Use of this source code is governed by the 3-clause BSD License that can be
// found in the LICENSE file.

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import 'package:uuid/uuid.dart';
import '../../common_model/utilities.dart';
import '../../one_stack.dart';

//BLoC

class SchemasBloc extends Bloc<SchemasEvent, ImmutableSchemasState> {
  CommonServices services;
  SchemasState schemasState;

  SchemasBloc(this.services, this.schemasState)
      : super(ImmutableSchemasState.from(schemasState)) {
    services.storage.observeSchemas(
        SchemaType.firestore, currentProjectId ?? '', (_schemas) {
      var schemas = List<SchemaInfo>.from(_schemas);
      schemas.sort((a, b) => a.index.compareTo(b.index));
      schemasState.firestoreSchemas = schemas;
      this.add(YieldStateEvent());
    });
    services.storage.observeSchemas(SchemaType.realtime, currentProjectId ?? '',
        (_schemas) {
      var schemas = List<SchemaInfo>.from(_schemas);
      schemas.sort((a, b) => a.index.compareTo(b.index));
      schemasState.realtimeSchemas = schemas;
      this.add(YieldStateEvent());
    });
    services.storage.observeSchemas(SchemaType.storage, currentProjectId ?? '',
        (_schemas) {
      var schemas = List<SchemaInfo>.from(_schemas);
      schemas.sort((a, b) => a.index.compareTo(b.index));
      schemasState.storageSchemas = schemas;
      this.add(YieldStateEvent());
    });
    services.storage.observeDocumentDefinitions(currentProjectId ?? '',
        (_documents) {
      var documents = List<DocumentInfo>.from(_documents);
      documents.sort((a, b) => a.index.compareTo(b.index));
      schemasState.documentDefinitions = documents;
      this.add(YieldStateEvent());
    });
  }

  final _defaultInitialNames = {
    SchemaType.firestore: ['collection-name'],
    SchemaType.realtime: ['path-name'],
    SchemaType.storage: ['path-name']
  };

  final _defaultPathNames = {
    SchemaType.firestore: ['document-name', 'collection-name'],
    SchemaType.realtime: ['path-name'],
    SchemaType.storage: ['path-name']
  };

  final _defaultSchemaNames = {
    SchemaType.firestore: 'object',
    SchemaType.realtime: 'object',
    SchemaType.storage: 'directory'
  };

  final _defaultProperties = [
    DocumentProperty(
        Uuid().v4(), 'myString', PropertyType.DocumentString, null),
    DocumentProperty(Uuid().v4(), 'myInt', PropertyType.DocumentInt, null),
    DocumentProperty(Uuid().v4(), 'myFile', PropertyType.DocumentFile, null),
  ];

  Future<void> _schemaCreate(SchemaCreationEvent create) async {
    final uuid = Uuid().v4();
    final newDocumentName = uniqueName(_defaultSchemaNames[create.type]!,
        schemasState.allSchemas.map((e) => e.namePrimary!).toList());
    final schema = SchemaInfo(
        CommonInfo(id: uuid, namePrimary: newDocumentName),
        _defaultInitialNames[create.type],
        0,
        (create.type == SchemaType.storage) ? 'n/a' : null,
        true);
    await _reorderIndexesBeforeAdding(create.type);
    await services.storage
        .saveSchema(create.type, currentProjectId ?? '', schema.id!, schema);
  }

  Future<void> _schemaMove(SchemaMoveEvent move) async {
    final newIndex =
        (move.newIndex > move.oldIndex) ? move.newIndex - 1 : move.newIndex;
    var schemas = List<SchemaInfo>.from(schemasState.schemas(move.type));
    final schema = schemas.removeAt(move.oldIndex);
    schemas.insert(newIndex, schema);
    for (var i = 0; i < schemas.length; i++) {
      schemas[i].index = i;
    }
    await services.storage
        .saveAllSchemas(move.type, currentProjectId ?? '', schemas);
  }

  Future<void> _reorderIndexesBeforeAdding(SchemaType type) async {
    if (type == SchemaType.document) {
      final documents = await services.storage
          .loadDocumentDefinitions(currentProjectId ?? '');
      for (var document in documents) {
        document.index += 1;
        await services.storage.saveDocumentDefinition(
            currentProjectId ?? '', document.id!, document);
      }
      return;
    }
    final schemas =
        await services.storage.loadSchemas(type, currentProjectId ?? '');
    for (var schema in schemas) {
      schema.index += 1;
      await services.storage
          .saveSchema(type, currentProjectId ?? '', schema.id!, schema);
    }
  }

  Future<void> _schemaPathAdd(SchemaAddPathEvent add) async {
    final schemas =
        await services.storage.loadSchemas(add.type, currentProjectId ?? '');
    final schema = schemas.firstWhere((element) => element.id == add.id);
    schema.path = schema.path! + _defaultPathNames[add.type]!;
    await services.storage
        .saveSchema(add.type, currentProjectId ?? '', schema.id!, schema);
  }

  Future<void> _schemaPathRemove(SchemaRemovePathEvent remove) async {
    final schemas =
        await services.storage.loadSchemas(remove.type, currentProjectId ?? '');
    final schema = schemas.firstWhere((element) => element.id == remove.id);
    var path = schema.path!;
    if (remove.type == SchemaType.firestore && path.length > 2) {
      path.removeLast();
      path.removeLast();
      schema.path = path;
      await services.storage
          .saveSchema(remove.type, currentProjectId ?? '', remove.id, schema);
    } else if (path.length > 1 && remove.type != SchemaType.firestore) {
      path.removeLast();
      schema.path = path;
      await services.storage
          .saveSchema(remove.type, currentProjectId ?? '', remove.id, schema);
    }
  }

  Future<void> _schemaDelete(SchemaDeleteEvent delete) async {
    await services.storage
        .removeSchema(delete.type, currentProjectId ?? '', delete.id);
    this.add(YieldStateEvent());
  }

  Future<void> _schemaIsBase(ToggleIsBaseEvent toggle) async {
    final schemas =
        await services.storage.loadSchemas(toggle.type, currentProjectId ?? '');
    final schema = schemas.firstWhere((element) => element.id == toggle.id);
    schema.isBaseSchema = toggle.isBaseSchema;
    await services.storage
        .saveSchema(toggle.type, currentProjectId ?? '', toggle.id, schema);
    this.add(YieldStateEvent());
  }

  Future<void> _schemaChange(ValidSchemaEdit edit) async {
    final schemas =
        await services.storage.loadSchemas(edit.type, currentProjectId ?? '');
    final schema = schemas.firstWhere((element) => element.id == edit.id);
    if (edit.index == -1) {
      final docName = edit.validString;
      if (docName == 'none') {
        schema.linkedDocument = null;
      } else {
        schema.linkedDocument = schemasState.documentDefinitions
            .firstWhere((element) => (element.namePrimary == docName))
            .id;
      }
    } else if (edit.index == -2) {
      schema.namePrimary = edit.validString;
    } else {
      var path = schema.path!;
      path[edit.index!] = edit.validString;
      schema.path = path;
    }
    await services.storage
        .saveSchema(edit.type, currentProjectId ?? '', edit.id, schema);
  }

  Future<void> _documentCreate(DocumentCreationEvent create) async {
    final documents =
        await services.storage.loadDocumentDefinitions(currentProjectId ?? '');
    final newDocumentName =
        uniqueName('document', documents.map((e) => e.namePrimary!).toList());
    final uuid = Uuid().v4();
    final document = DocumentInfo(
        CommonInfo(id: uuid, namePrimary: newDocumentName),
        _defaultProperties,
        0);
    await _reorderIndexesBeforeAdding(SchemaType.document);
    await services.storage
        .saveDocumentDefinition(currentProjectId ?? '', uuid, document);
  }

  Future<void> _documentDelete(DocumentDeleteEvent delete) async {
    final allSchemas = schemasState.allSchemas;
    for (var schema in allSchemas) {
      if (schema.linkedDocument == delete.id) {
        schema.linkedDocument = null;
        await services.storage.saveSchema(schemasState.getTypeFrom(schema.id!)!,
            currentProjectId ?? '', schema.id!, schema);
      }
    }
    await services.storage
        .removeDocumentDefinition(currentProjectId ?? '', delete.id);
    this.add(YieldStateEvent());
  }

  Future<void> _documentMove(DocumentMoveEvent move) async {
    final newIndex =
        (move.newIndex > move.oldIndex) ? move.newIndex - 1 : move.newIndex;
    var documents = schemasState.documentDefinitions;
    final document = documents.removeAt(move.oldIndex);
    documents.insert(newIndex, document);
    for (var i = 0; i < documents.length; i++) {
      documents[i].index = i;
    }
    await services.storage.saveAllDocuments(currentProjectId ?? '', documents);
  }

  Future<void> _documentAddProperty(DocumentAddPropertyEvent add) async {
    final documents =
        await services.storage.loadDocumentDefinitions(currentProjectId ?? '');
    final document = documents.firstWhere((element) => element.id == add.id);
    if (document.properties == null) {
      document.properties = [];
    }
    final newPropertyName = uniqueName(
        'myProperty', document.properties!.map((e) => e.name).toList());
    final newProperty = DocumentProperty(
        Uuid().v4(), newPropertyName, PropertyType.DocumentString, null);
    document.properties!.add(newProperty);
    await services.storage
        .saveDocumentDefinition(currentProjectId ?? '', add.id, document);
  }

  Future<void> _documentRemoveProperty(
      DocumentRemovePropertyEvent remove) async {
    final documents =
        await services.storage.loadDocumentDefinitions(currentProjectId ?? '');
    final document =
        documents.firstWhere((element) => element.id == remove.documentId);
    var properties = document.properties!;
    for (var i = 0; i < properties.length; i++) {
      if (properties[i].id == remove.name && properties.length > 1) {
        properties.removeAt(i);
      }
    }
    document.properties = properties;
    await services.storage.saveDocumentDefinition(
        currentProjectId ?? '', remove.documentId, document);
  }

  Future<void> _documentChangeProperty(
      ValidDocumentEditPropertyEvent edit) async {
    final documents =
        await services.storage.loadDocumentDefinitions(currentProjectId ?? '');
    final document =
        documents.firstWhere((element) => element.id == edit.documentId);
    if (edit.propertyId == 'name') {
      document.namePrimary = edit.newDocumentProperty.name;
      await services.storage.saveDocumentDefinition(
          currentProjectId ?? '', edit.documentId, document);
      return;
    }
    var properties = List<DocumentProperty>.from(document.properties!);
    for (var i = 0; i < properties.length; i++) {
      if (properties[i].id == edit.propertyId) {
        properties[i] = edit.newDocumentProperty;
        if (properties[i].value == 'none') {
          properties[i].value = null;
        }
      }
    }
    document.properties = properties;
    await services.storage.saveDocumentDefinition(
        currentProjectId ?? '', edit.documentId, document);
  }

  @override
  Stream<ImmutableSchemasState> mapEventToState(SchemasEvent event) async* {
    if (event is SchemaCreationEvent) {
      await _schemaCreate(event);
    } else if (event is SchemaMoveEvent) {
      await _schemaMove(event);
    } else if (event is SchemaAddPathEvent) {
      await _schemaPathAdd(event);
    } else if (event is SchemaRemovePathEvent) {
      await _schemaPathRemove(event);
    } else if (event is ToggleIsBaseEvent) {
      await _schemaIsBase(event);
    } else if (event is SchemaDeleteEvent) {
      await _schemaDelete(event);
    } else if (event is ValidSchemaEdit) {
      await _schemaChange(event);
    } else if (event is DocumentCreationEvent) {
      await _documentCreate(event);
    } else if (event is DocumentDeleteEvent) {
      await _documentDelete(event);
    } else if (event is DocumentMoveEvent) {
      await _documentMove(event);
    } else if (event is DocumentAddPropertyEvent) {
      await _documentAddProperty(event);
    } else if (event is DocumentRemovePropertyEvent) {
      await _documentRemoveProperty(event);
    } else if (event is ValidDocumentEditPropertyEvent) {
      await _documentChangeProperty(event);
    } else if (event is YieldStateEvent) {
      yield ImmutableSchemasState.from(schemasState);
    } else {
      addError(Exception('unsupported schema event'));
    }
  }
}

//BLoC events

abstract class SchemasEvent {}

///Add a new schema with the starter path
class SchemaCreationEvent extends SchemasEvent {
  SchemaCreationEvent(this.type);
  final SchemaType type;
}

class ToggleIsBaseEvent extends SchemasEvent {
  ToggleIsBaseEvent(this.type, this.id, this.isBaseSchema);
  final String id;
  final SchemaType type;
  final bool isBaseSchema;
}

///Delete a schema after warning if any data exists at its endpoint
class SchemaDeleteEvent extends SchemasEvent {
  SchemaDeleteEvent(this.id, this.type);
  final String id;
  final SchemaType type;
}

///Move a schema to index, this reorders the schemas, order is just a user preference
class SchemaMoveEvent extends SchemasEvent {
  SchemaMoveEvent(this.type, this.oldIndex, this.newIndex);
  final SchemaType type;
  final int oldIndex;
  final int newIndex;
}

///Add path element to the end of current path, named by default
class SchemaAddPathEvent extends SchemasEvent {
  SchemaAddPathEvent(this.id, this.type);
  final String id;
  final SchemaType type;
}

///Removes path element(s) from the end of current path
class SchemaRemovePathEvent extends SchemasEvent {
  SchemaRemovePathEvent(this.id, this.type);
  final String id;
  final SchemaType type;
}

///Textfields filter out bad schema entries, when a schema is edited the system checks to see if there is data saved in the schema path and warns the user if they're changing a schema that is in use. Data is never migrated by a schema edit, it stays in the location it was saved, even if there is no longer a schema path pointing to it
class ValidSchemaEdit extends SchemasEvent {
  ValidSchemaEdit(this.type, this.id, this.index, this.validString);
  final SchemaType type;
  final String id;
  final int?
      index; //a -1 index designates the document link change, a -2 index designates name change
  final String validString;
}

///Add a new Document with the starter variables
class DocumentCreationEvent extends SchemasEvent {}

///Delete a Document after warning if any data exists at its endpoint
class DocumentDeleteEvent extends SchemasEvent {
  DocumentDeleteEvent(this.id);
  final String id;
}

///Move a Document to index, this reorders the schemas, order is just a user preference
class DocumentMoveEvent extends SchemasEvent {
  DocumentMoveEvent(this.oldIndex, this.newIndex);
  final int oldIndex;
  final int newIndex;
}

///Add Document Property to end of current properties, named by default
class DocumentAddPropertyEvent extends SchemasEvent {
  DocumentAddPropertyEvent(this.id);
  final String id;
}

///Removes Document Property
class DocumentRemovePropertyEvent extends SchemasEvent {
  DocumentRemovePropertyEvent(this.documentId, this.name);
  final String documentId;
  final String name;
}

///Edit Document Property, when a Document is edited the widget editor checks to see if is valid edit before pushing the event
class ValidDocumentEditPropertyEvent extends SchemasEvent {
  ValidDocumentEditPropertyEvent(
      this.documentId, this.propertyId, this.newDocumentProperty);
  final String documentId;
  final String propertyId;
  final DocumentProperty newDocumentProperty;
}

///Yields the state to the streams that feed the widgets
class YieldStateEvent extends SchemasEvent {}

//state

///This mutable state mimics the immutable state object and represents the data model of the schemas owned by a project.
class SchemasState {
  List<SchemaInfo> firestoreSchemas = [];
  List<SchemaInfo> realtimeSchemas = [];
  List<SchemaInfo> storageSchemas = [];
  List<DocumentInfo> documentDefinitions = [];

  List<String> get allDocumentNames =>
      (documentDefinitions).map((e) => e.namePrimary!).toList();

  SchemaType? getTypeFrom(String id) {
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
}

///This immutable state gets pushed to the widgets
@immutable
class ImmutableSchemasState extends Equatable {
  ImmutableSchemasState.from(SchemasState schemasState)
      : firestoreSchemas = schemasState.firestoreSchemas,
        realtimeSchemas = schemasState.realtimeSchemas,
        storageSchemas = schemasState.storageSchemas,
        documentDefinitions = schemasState.documentDefinitions;

  ///Props are used to determine comparison of state between yields, if the state doesn't change, determined by the prop values the stream filters it out
  @override
  List<Object> get props => [
        SchemaInfo.prop(firestoreSchemas ?? []),
        SchemaInfo.prop(realtimeSchemas ?? []),
        SchemaInfo.prop(storageSchemas ?? []),
        DocumentInfo.prop(documentDefinitions ?? [])
      ];

  final List<SchemaInfo>? firestoreSchemas;
  final List<SchemaInfo>? realtimeSchemas;
  final List<SchemaInfo>? storageSchemas;
  final List<DocumentInfo>? documentDefinitions;

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

  SchemaType getTypeFrom(String id) {
    for (var schema in firestoreSchemas ?? []) {
      if (schema.id == id) {
        return SchemaType.firestore;
      }
    }
    for (var schema in realtimeSchemas ?? []) {
      if (schema.id == id) {
        return SchemaType.realtime;
      }
    }
    for (var schema in storageSchemas ?? []) {
      if (schema.id == id) {
        return SchemaType.storage;
      }
    }
    return SchemaType.document;
  }
}
