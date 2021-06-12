import 'dart:typed_data';

import '../../manager_page/widget/navigation_widget.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';

import '../../one_stack.dart';
import 'manager_bloc.dart';

class ManagerLogic {
  ManagerLogic(this.managerState, this.services);
  final ManagerState managerState;
  final CommonServices services;

  Future<void> getDocuments() async {
    final type = managerState.getTypeFromCurrentPath();
    managerState.documents = await services.storage
        .getAppDocuments(type, managerState.getLastDocumentsPath());
  }

  void checkIfInDocument() {
    if (managerState.selectedDocument != null) {
      //was already in a document, so close document to show new documents list
      managerState.selectedDocument = null;
    }
  }

  replaceLastPath(NavigationElement newNavigationElement) {
    managerState.path.removeLast();
    managerState.path.add(newNavigationElement);
  }

  ///selected a path element that affects the location state of what the user is currently trying to examine
  ///returns true if should get documents for current path
  Future<bool> selectPathElement(NavigationElement navigationElement) async {
    managerState.userEntries = [];
    if (managerState.allSchemas
        .map((e) => e.id)
        .toList()
        .contains(navigationElement.id)) {
      //set current document definition if selected a schema path and not a document
      final schema = managerState.allSchemas
          .firstWhere((element) => element.id == navigationElement.id);
      managerState.currentDefinition = managerState.documentDefinitions
          .firstWhere((element) => element.id == schema.linkedDocument!);
    }
    if (!navigationElement.isNavigationBarElement &&
        !navigationElement.isDocuments) {
      // document is selected, not from navigation bar
      managerState.path.add(navigationElement);
      showDocument(navigationElement);
      return false;
    } else if (!navigationElement.isNavigationBarElement &&
        navigationElement.isDocuments) {
      // schema path is selected, not from naviation bar, collection is shown
      managerState.path.add(navigationElement);
      managerState.isFetchingNeededDataToContinue = true;
      return true;
    } else if (navigationElement.isNavigationBarElement &&
        !navigationElement.isDocuments) {
      // document is selected, from naviation bar

      if (managerState.path.isNotEmpty &&
          navigationElement.id == managerState.path.last.id) {
        managerState.isFetchingNeededDataToContinue = false;
        return false;
      }
      if (navigationElement.id == NavigationElement.baseId) {
        // if we've selected a base, just starting out, this is the base of the tree
        managerState.path = [];
        managerState.documents = null;
      } else {
        final index = managerState.path
            .map((e) => e.id)
            .toList()
            .indexOf(navigationElement.id);
        final newPath = managerState.path.sublist(0, index + 1);
        managerState.path = newPath;
        showDocument(navigationElement);
      }
      return false;
    } else if (navigationElement.isNavigationBarElement &&
        navigationElement.isDocuments) {
      // schema path is selected, from naviation bar, collection is shown
      if (managerState.path.isNotEmpty &&
          navigationElement.id == managerState.path.last.id) {
        return false;
      }
      final index = managerState.path
          .map((e) => e.id)
          .toList()
          .indexOf(navigationElement.id);
      final newPath = managerState.path.sublist(0, index + 1);
      managerState.path = newPath;
      managerState.isFetchingNeededDataToContinue = true;
      return true;
    } else {
      assert(false);
    }
    return false;
  }

  List<String> getVariableNames(List<String> path) {
    var list = <String>[];
    for (var element in path) {
      if (element[0] == '\$') {
        list.add(element.substring(2, element.length - 1));
      }
    }
    return list;
  }

  String filename(String pathName) {
    if (pathName.contains('/')) {
      return pathName.substring(pathName.lastIndexOf('/') + 1, pathName.length);
    } else {
      return pathName;
    }
  }

  void showDocument(NavigationElement navigationElement) {
    final documentId = navigationElement.id;
    Map<String, dynamic> document = managerState.documents![documentId];
    final schemaId = managerState.path[managerState.path.length - 2].id;
    final schema =
        managerState.allSchemas.firstWhere((element) => element.id == schemaId);
    final documentDefinition = managerState.documentDefinitions
        .firstWhere((element) => element.id == schema.linkedDocument);
    managerState.selectedDocumentNew = false;
    managerState.selectedDocument = DocumentProperty.assembleDocument(
        document, documentDefinition, managerState.allSchemas, false);
    managerState.isFetchingNeededDataToContinue = false;
  }

  void addDocument() {
    final schema = managerState.allSchemas
        .firstWhere((element) => element.id == managerState.path.last.id);
    assert(schema.linkedDocument != null);
    final linkedDocumentDefinition = managerState.documentDefinitions
        .firstWhere((element) => element.id == schema.linkedDocument);
    managerState.selectedDocumentNew = true;
    managerState.selectedDocument = DocumentProperty.assembleDocument(
        {}, linkedDocumentDefinition, managerState.allSchemas, true);
    final id = managerState.selectedDocument!
        .firstWhere((element) => element.id == docId)
        .value;
    managerState.path.add(NavigationElement(id, id, false, true));
  }

  Future<void> exitDocument() async {
    managerState.selectedDocument = null;
    managerState.path.removeLast();
  }

  Future<void> deleteFiles(List<String> filesToDelete) async {
    for (var filename in filesToDelete) {
      await services.storage
          .deleteAppFile(managerState.getStoragePath(), filename);
    }
  }

  Future<void> saveValidDocumentValuesEvent(
      List<DocumentProperty> values, Map<String, Uint8List> filesToSave) async {
    final type = managerState.getTypeFromCurrentPath();
    final data = ManagerState.toMap(values, type);
    var storagePath = managerState.getStoragePath();
    await services.storage.saveAppDocument(type, storagePath, data,
        ManagerState.shouldSavePiecewise(values, type));
    for (var filename in filesToSave.keys) {
      if (filesToSave[filename] != null) {
        await services.storage
            .saveAppFile(storagePath, filename, filesToSave[filename]!);
      } else {
        print('file was null');
      }
    }
  }

  void closeDocumentEvent() {
    managerState.path.removeLast();
  }

  Future<void> deleteDocument(String documentId) async {
    managerState.documents!.remove(documentId);
    final type = managerState.getTypeFromCurrentPath();
    await services.storage
        .deleteAppDocument(type, managerState.getStoragePath());
  }

  Future<bool> returnUserEntriesEvent(String entry) async {
    //do nothing
    return false;
  }
}
