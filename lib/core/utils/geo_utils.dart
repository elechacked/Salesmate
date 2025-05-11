import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GeoUtils {

  static Future<Position?> getCurrentPosition() async {
  try {
  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
  await Geolocator.openLocationSettings();
  return null;
  }

  // Check permissions
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
  return null;
  }
  }

  if (permission == LocationPermission.deniedForever) {
  await openAppSettings();
  return null;
  }

  // Get current position with high accuracy
  return await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.high,
  );
  } catch (e) {
  return null;
  }
  }

  static Future<bool> hasLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  return permission == LocationPermission.always ||
  permission == LocationPermission.whileInUse;
  }

  static Future<double?> calculateDistance(
  double startLatitude,
  double startLongitude,
  double endLatitude,
  double endLongitude,
  ) async {
  return Geolocator.distanceBetween(
  startLatitude,
  startLongitude,
  endLatitude,
  endLongitude,
  );
  }
  }