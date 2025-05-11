//time service.dart

import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimeServices {
  static Future<DateTime> getCurrentTime() async {
    try {
      // Try NTP first (returns UTC but we'll convert to local)
      final ntpTime = await NTP.now();
      return ntpTime.toLocal(); // Convert to device's local time
    } catch (e) {
      // Fallback to Firebase Server time
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('timestamp')
            .doc('serverTime')
            .get(const GetOptions(source: Source.server));

        if (snapshot.exists) {
          return (snapshot.data()!['time'] as Timestamp).toDate().toLocal();
        }
      } catch (e) {
        print('Failed to get Firebase server time: $e');
      }

      // Final fallback - use device local time
      print('Warning: Using device local time as fallback');
      return DateTime.now().toLocal();
    }
  }

  static String formatTime(DateTime time) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(time);
  }
}