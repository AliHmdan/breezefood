import 'dart:io';
import 'package:file_picker/file_picker.dart';

class MultiImagePickerHelper {
  static Future<List<File>> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result == null) return [];

    return result.paths.map((path) => File(path!)).toList();
  }
}
