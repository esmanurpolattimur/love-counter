import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PhotoStorageService {
  PhotoStorageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;

  Future<List<String>> pickAndStoreImages() async {
    final selected = await _picker.pickMultiImage(imageQuality: 88);
    if (selected.isEmpty) return [];
    final documents = await getApplicationDocumentsDirectory();
    final memoriesDir = Directory('${documents.path}${Platform.pathSeparator}memories');
    if (!await memoriesDir.exists()) await memoriesDir.create(recursive: true);

    final storedPaths = <String>[];
    for (final image in selected) {
      final extension = image.path.contains('.') ? image.path.substring(image.path.lastIndexOf('.')) : '.jpg';
      final target = File('${memoriesDir.path}${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}_${storedPaths.length}$extension');
      await File(image.path).copy(target.path);
      storedPaths.add(target.path);
    }
    return storedPaths;
  }

  Future<List<XFile>> recoverLostImages() async {
    final response = await _picker.retrieveLostData();
    return response.files ?? const [];
  }
}
