import '../../schemas_page/bloc/schemas_diagram.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';
import 'code_generator.dart';

class CodeGeneratorUnity extends CodeGenerator {
  CodeGeneratorUnity(SchemasDiagram diagram) : super(diagram);

  //Info Structs
  @override
  String repeatedSctructCodeSpecific(
      String documentName, List<DocumentProperty> properties) {
    return '''
''';
  }

  //Api

  @override
  String repeatedApiCodeSpecific(String documentName, SchemaType type) {
    return '''
''';
  }

  @override
  String startApiCodeSpecific() {
    return '''
Coming Soon... Only dart for now.
''';
  }

  @override
  String endApiCodeSpecific() {
    return '''
''';
  }

  //Implementation

  @override
  String repeatedImplementationCodeSpecific(String documentName,
      List<String> documentNames, String path, SchemaType type) {
    switch (type) {
      case SchemaType.firestore:
        return '''
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
''';
  }

  @override
  String endImplementationCodeSpecific() {
    return '''
''';
  }
}
