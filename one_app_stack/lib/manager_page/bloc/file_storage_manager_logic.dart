import '../../manager_page/widget/navigation_widget.dart';
import 'package:one_app_stack_storage_api/one_app_stack_storage_api.dart';

import '../../one_stack.dart';
import 'manager_bloc.dart';
import 'manager_logic.dart';

class FileStorageManagerLogic extends ManagerLogic {
  FileStorageManagerLogic(ManagerState managerState, CommonServices services)
      : super(managerState, services);

  @override
  Future<void> getDocuments() async {
    final type = SchemaType.storage;
    managerState.documents = await services.storage
        .getAppDocuments(type, _pathNamesFrom(managerState.path));
  }

  @override
  Future<bool> selectPathElement(NavigationElement navigationElement) async {
    managerState.userEntries = [];
    if (!navigationElement.isNavigationBarElement &&
        !navigationElement.isDocuments) {
      // document is selected, not from navigation bar
      managerState.selectedDocument = [
        DocumentProperty('', 'Files', PropertyType.DocumentFileList, [])
      ];
      showDocument(navigationElement);
      return false;
    } else if (!navigationElement.isNavigationBarElement &&
        navigationElement.isDocuments) {
      // schema path is selected, not from naviation bar, collection is shown
      final schema = managerState.allSchemas
          .firstWhere((element) => element.id == navigationElement.id);
      final filePath = schema.path!;
      managerState.path = _navigationElementsFrom(filePath);
      managerState.userEntries = getVariableNames(filePath);
      if (managerState.userEntries.isEmpty) {
        managerState.isFetchingNeededDataToContinue = true;
        return true;
      } else {
        return false;
      }
    } else if (navigationElement.isNavigationBarElement &&
        !navigationElement.isDocuments) {
      // document is selected, from naviation bar
      if (navigationElement.id == NavigationElement.baseId) {
        // if we've selected a base, just starting out, this is the base of the tree
        managerState.path = [];
        managerState.documents = null;
      }
    } else if (navigationElement.isNavigationBarElement &&
        navigationElement.isDocuments) {
      // schema path is selected, from naviation bar, collection is shown
      //do nothing
    } else {
      assert(false);
    }
    return false;
  }

  @override
  void showDocument(NavigationElement navigationElement) {
    managerState.selectedDocument = [
      DocumentProperty('', 'Files', PropertyType.DocumentFileList,
          [filename(navigationElement.id)])
    ];
  }

  @override
  void addDocument() {
    managerState.selectedDocument = [
      DocumentProperty('', 'Files', PropertyType.DocumentFileList, [])
    ];
  }

  @override
  Future<void> exitDocument() async {
    managerState.selectedDocument = null;
    await getDocuments();
  }

  @override
  Future<void> deleteFiles(List<String> filesToDelete) async {
    for (var filename in filesToDelete) {
      await services.storage
          .deleteAppFile(_pathNamesFrom(managerState.path), filename);
    }
  }

  @override
  Future<bool> returnUserEntriesEvent(String entry) async {
    var newValue = <String>[];
    var substituteOnce = false;
    for (var value in _pathNamesFrom(managerState.path)) {
      if (value.contains('\$') && !substituteOnce) {
        substituteOnce = true;
        newValue.add(entry);
      } else {
        newValue.add(value);
      }
    }
    managerState.path = _navigationElementsFrom(newValue);
    if (_pathNamesFrom(managerState.path).join().contains('\$')) {
      managerState.userEntries =
          getVariableNames(_pathNamesFrom(managerState.path));
      return false;
    } else {
      managerState.userEntries = [];
      managerState.isFetchingNeededDataToContinue = true;
      return true;
    }
  }

  List<String> _pathNamesFrom(List<NavigationElement> elements) {
    return elements.map((e) => e.name).toList();
  }

  List<NavigationElement> _navigationElementsFrom(List<String> names) {
    return names.map((e) => NavigationElement(e, e, false, false)).toList();
  }
}
