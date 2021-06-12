import '../../schemas_page/bloc/schemas_diagram.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import '../../common_model/utilities.dart';
import './code_generator.dart';

class CodeGeneratorDart extends CodeGenerator {
  CodeGeneratorDart(SchemasDiagram diagram) : super(diagram);

  //Info Structs
  @override
  String repeatedSctructCodeSpecific(
      String documentName, List<DocumentProperty> properties) {
    final propertyDefinitions = properties
        .map((e) =>
            '${PropertyTypeHelper.codeGenString(e.type)}? ${lower(e.name)};')
        .toList();
    final propertyInits =
        properties.map((e) => 'this.${lower(e.name)}').toList();
    final fromMaps = properties
        .where((element) => (!PropertyTypeHelper.isList(element.type)))
        .map((e) => '${lower(e.name)}: map[\'${lower(e.name)}\']')
        .toList();
    final fromListMaps = properties
        .where((element) => (PropertyTypeHelper.isList(element.type)))
        .map((e) =>
            '${lower(e.name)}: (map[\'${lower(e.name)}\'] != null) ? List<${PropertyTypeHelper.codeGenString(e.type)}>.from(map[\'${lower(e.name)}\']) : null')
        .toList();
    final maps = properties
        .map((e) => '\'${lower(e.name)}\': ${lower(e.name)}')
        .toList();

    return '''
class ${upper(documentName)}Info {

    ${propertyDefinitions.join('\n    ')}
    ${upper(documentName)}(
    {${propertyInits.join(', ')}});
      
    factory ${upper(documentName)}.fromMap(Map<String, dynamic> map) {
        return ${upper(documentName)}(
            ${(fromMaps + fromListMaps).join(',\n            ')}
        );
    }
    
    factory ${upper(documentName)}.fromJson(String json) {
        Map<String, dynamic> map = jsonDecode(json);
        return ${upper(documentName)}.fromMap(map);
    }
    
    String toJsonString() => jsonEncode(infoMap());
    
    Map<String, dynamic> infoMap() {
        return {
            ${maps.join(',\n            ')}
        };
    }
}

''';
  }

  //Api

  @override
  String repeatedApiCodeSpecific(String documentName, SchemaType type) {
    return '''
    Future<void> save${upper(documentName)}Info(String ${lower(documentName)}Id, ${upper(documentName)}Info ${lower(documentName)}Info);
    Future<${upper(documentName)}Info> load${upper(documentName)}Info(String ${lower(documentName)}Id);
    Future<void> delete${upper(documentName)}Info(String ${lower(documentName)}Id);

''' +
        ((type == SchemaType.realtime)
            ? '''
    void observe${upper(documentName)}Info(String ${lower(documentName)}Id, Function(${upper(documentName)}) onEvent);

'''
            : '');
  }

  @override
  String startApiCodeSpecific() {
    return '''
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';


abstract class AbstractStorage {

''';
  }

  @override
  String endApiCodeSpecific() {
    return '''
    Future<void> saveAppFile(List<String> path, String filename, Uint8List data);
    Future<void> deleteAppFile(List<String> path, String filename);
    Future<Uri> getAppFileUri(List<String> path, String filename);
}


''';
  }

  //Implementation

  @override
  String repeatedImplementationCodeSpecific(String documentName,
      List<String> documentNames, String path, SchemaType type) {
    var arguments =
        documentNames.map((e) => 'String ${lower(e)}Id').toList().join(' ,');
    switch (type) {
      case SchemaType.realtime:
        return '''
    @override
    Future<void> save${upper(documentName)}Info($arguments, ${upper(documentName)}Info ${lower(documentName)}Info) async {
        await databaseBaseReference.child($path).set(${lower(documentName)}.infoMap());
    }

    @override
    Future<${upper(documentName)}Info> load${upper(documentName)}Info($arguments) async {
        Map<String, dynamic> map;
        final snapshot = await databaseBaseReference.child($path).once();
        map = snapshot.value() ?? {};
        return ${upper(documentName)}Info.fromMap(map);
    }

    @override
    Future<void> delete${upper(documentName)}Info($arguments) async {
        await databaseBaseReference.child($path).remove();
    }

    @override
    void observe${upper(documentName)}Info($arguments, Function(${upper(documentName)}) onEvent) {
        databaseBaseReference.child($path).onValue.listen((event) {
            if (event.snapshot.value != null) {
                Map<String, dynamic> map = Map<String, dynamic>.from(event.snapshot.value);
                onEvent(${upper(documentName)}Info.fromMap(map));
            }
        });
    }

''';
      case SchemaType.firestore:
        return '''
    @override
    Future<void> save${upper(documentName)}Info($arguments, ${upper(documentName)}Info ${lower(documentName)}Info) async {
        await firebaseFirestore.doc($path).set(${lower(documentName)}.infoMap());
    }

    @override
    Future<${upper(documentName)}> load${upper(documentName)}Info($arguments) async {
        final snapshot = await firebaseFirestore.doc($path).get();
        final map = snapshot.data();
        return ${upper(documentName)}.fromMap(map);
    }

    @override
    Future<void> delete${upper(documentName)}Info($arguments) async {
        await firebaseFirestore.doc($path).delete();
    }

''';
      case SchemaType.storage:
        return '';
      default:
        return '';
    }
  }

  @override
  String startImplementationCodeSpecific() {
    return '''

class Storage implements AbstractStorage {

    final firebaseDatabase = FirebaseDatabase.instance;
    final firebaseFirestore = FirebaseFirestore.instance;
    final firebaseStorage = FirebaseStorage.instance;
    DatabaseReference get databaseBaseReference => firebaseDatabase.reference();

''';
  }

  @override
  String endImplementationCodeSpecific() {
    return '''
    @override
    Future<void> saveAppFile(List<String> path, String filename, Uint8List data) async {
        otherAppHelper.fileStorageByPath(path, filename).putData(data);
    }

    @override
    Future<Uri> getAppFileUri(List<String> path, String filename) async {
        final urlString = await otherAppHelper.fileStorageByPath(path, filename).getDownloadURL();
        return Uri(path: urlString);
    }

    @override
    Future<void> deleteAppFile(List<String> path, String filename) async {
        await otherAppHelper.fileStorageByPath(path, filename).delete();
    }
}


''';
  }
}
