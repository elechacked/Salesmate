import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }


  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }


  static Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  static Future<bool> requestAllRequiredPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final locationStatus = await Permission.location.request();
    final results = await [
      Permission.storage,
      Permission.camera,
      Permission.location,
    ].request();

    return results.values.every((status) => status.isGranted) && cameraStatus.isGranted && locationStatus.isGranted;

  }


  static Future<bool> hasStoragePermission() async {
    return await Permission.storage.isGranted;
  }

  static Future<bool> requestStorageRequiredPermissions() async {
    final results = await [
      Permission.storage,
      Permission.camera,
      Permission.location,
    ].request();

    return results.values.every((status) => status.isGranted);
  }
  static Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

}
