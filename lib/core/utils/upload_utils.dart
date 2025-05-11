// lib/core/utils/upload_utils.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

enum UploadType {
  profilePicture, // needs companyId and email
  visitPhoto,     // needs companyId, email, and visitId
  companyLogo,    // needs companyId only
}

class UploadUtils {
  static final ImagePicker _picker = ImagePicker();
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Picks and compresses image from gallery
  static Future<File?> pickAndCompressImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      return await _compressImage(file);
    } catch (e) {
      throw Exception('Image picking failed: ${e.toString()}');
    }
  }

  /// Compresses image file
  static Future<File> _compressImage(File file) async {
    final tempDir = Directory.systemTemp;
    final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
    );

    if (result == null) throw Exception('Image compression failed');
    return File(result.path);
  }

  /// Uploads image based on type and metadata
  static Future<String> uploadImage({
    required UploadType type,
    required File imageFile,
    required Map<String, String> metadata,
  }) async {
    try {
      final ref = _getStorageRef(type, metadata);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Upload failed: ${e.toString()}');
    }
  }

  /// Resolves Firebase path based on UploadType and identifiers
  static Reference _getStorageRef(UploadType type, Map<String, String> metadata) {
    switch (type) {
      case UploadType.profilePicture:
        return _storage.ref(
          'companies/${metadata['companyId']}/employees/${metadata['email']}/profile.jpg',
        );
      case UploadType.visitPhoto:
        return _storage.ref(
          'companies/${metadata['companyId']}/employees/${metadata['email']}/visits/${metadata['visitId']}.jpg',
        );
      case UploadType.companyLogo:
        return _storage.ref(
          'companies/${metadata['companyId']}/logo.jpg',
        );
    }
  }
}