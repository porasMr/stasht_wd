import 'dart:io';

import 'package:photo_manager/photo_manager.dart';

class FilePath{
  static Future<String?> getFilePath(AssetEntity asset) async {
    final File? file = await asset.file;
    if (file != null) {
      return file.path; // Return the file path
    }
    return null;
  }

  static Future<File?> getFile(AssetEntity assets) async {
    final File? file = (await assets.file);
    if (file != null) {
      return file; // Return the file path
    }
    return null;
  }

}