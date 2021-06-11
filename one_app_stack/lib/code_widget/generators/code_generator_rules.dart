import '../../schemas_page/bloc/schemas_diagram.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';

class CodeGeneratorRules {
  final SchemasDiagram diagram;
  String get code {
    // final structCode =
    //     visitEachTreeNode(diagram, nodeStructCode, () => '', () => '');
    // final apiCode = visitEachTreeNode(
    //     diagram, nodeApiCode, startApiCodeSpecific, endApiCodeSpecific);
    // final implementationCode = visitEachTreeNode(
    //     diagram,
    //     nodeImplementationCode,
    //     startImplementationCodeSpecific,
    //     endImplementationCodeSpecific);
    return 'Coming Soon...';
    // return (apiCode + implementationCode + structCode);
  }

  CodeGeneratorRules(this.diagram);

  String visitEachTreeNode(
      SchemasDiagram diagram,
      String Function(DiagramNode currentNode) visitNode,
      String Function() start,
      String Function() end) {
    var stack = [diagram.head];
    var middleStrings = <String>[];
    final startString = start();
    while (stack.isNotEmpty) {
      final currentNode = stack.removeLast();
      middleStrings.add(visitNode(currentNode));
      stack.addAll(currentNode.children.reversed);
    }
    final endString = end();
    return ([startString] + middleStrings + [endString]).join();
  }

  String? findDefinitionName(String id) {
    var stack = [diagram.head];
    while (stack.isNotEmpty) {
      final currentNode = stack.removeLast();
      if (currentNode.value is DocumentInfo) {
        final info = currentNode.value as DocumentInfo;
        if (info.id == id) {
          return info.namePrimary!;
        }
      }
      stack.addAll(currentNode.children.reversed);
    }
    return null;
  }

  //Info Structs
  var infosCreated = <String>[];
  String nodeStructCode(DiagramNode node) {
    if (node.value is DocumentInfo &&
        !infosCreated.contains((node.value as DocumentInfo).id!)) {
      final document = node.value as DocumentInfo;

      infosCreated.add(document.id!);
      final documentName = document.namePrimary!;
      final properties = document.properties ?? [];
      return repeatedSctructCodeSpecific(documentName, properties);
    }
    return '';
  }

  String repeatedSctructCodeSpecific(
      String documentName, List<DocumentProperty> properties) {
    return '';
    //override
  }

  //Api

  String nodeApiCode(DiagramNode node) {
    if (node.value is DocumentInfo) {
      final document = node.value as DocumentInfo;
      final documentName = document.namePrimary!;
      final type = node.type;
      return repeatedApiCodeSpecific(documentName, type);
    }
    return '';
  }

  String repeatedApiCodeSpecific(String documentName, SchemaType type) {
    return '';
    //override
  }

  String startApiCodeSpecific() {
    return '';
    //override
  }

  String endApiCodeSpecific() {
    return '';
    //override
  }

  //Implementation

  String nodeImplementationCode(DiagramNode node) {
    if (node.value is DocumentInfo) {
      final document = node.value as DocumentInfo;
      final documentName = document.namePrimary!;
      final path = node.path;
      final documentNames = node.documentNames;
      final type = node.type;
      return repeatedImplementationCodeSpecific(
          documentName, documentNames, path, type);
    }
    return '';
  }

  String repeatedImplementationCodeSpecific(String documentName,
      List<String> documentNames, String path, SchemaType type) {
    return '';
    //override
  }

  String startImplementationCodeSpecific() {
    return '';
    //override
  }

  String endImplementationCodeSpecific() {
    return '';
    //override
  }
}
