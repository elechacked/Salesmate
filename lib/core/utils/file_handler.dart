// lib/core/utils/file_handler.dart
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileHandler {
  static Future<File> createTempFile({
    required String fileName,
    required List<int> bytes,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<File> createTempFileFromString({
    required String fileName,
    required String content,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(content);
    return file;
  }

  static Future<void> deleteTempFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
    }
  }
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      return await _picker.pickImage(source: source);
    } catch (e) {
      return null;
    }
  }
  static Future<File> compressImage(String filePath) async {
    try {
      // Read the image file as bytes
      final bytes = await File(filePath).readAsBytes();

      // Compress the image using flutter_image_compress
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 600, // Resize width (optional)
        minHeight: 600, // Resize height (optional)
        quality: 85,    // Quality (0-100, where 100 is the best)
        rotate: 0,      // Rotate if needed (optional)
      );

      // Save the compressed image to a new file
      final tempDir = Directory.systemTemp;
      final compressedFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(result);

      return compressedFile;
    } catch (e) {
      throw Exception('Image compression failed: $e');
    }
  }

}