import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gratitude_entry.dart';

class GratitudeService {
  static const String _storageKey = 'gratitudeEntries';

  Future<List<GratitudeEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null) return [];

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => GratitudeEntry.fromJson(e)).toList();
  }

  Future<void> saveEntries(List<GratitudeEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  int calculateStreak(List<GratitudeEntry> entries) {
    if (entries.isEmpty) return 0;

    // Get unique dates, sorted descending
    final uniqueDates = entries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (uniqueDates.isEmpty) return 0;

    int streak = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    // Check if the most recent entry is today or yesterday to keep streak alive
    if (uniqueDates.first.isBefore(todayDate.subtract(const Duration(days: 1)))) {
      return 0;
    }

    // Calculate consecutive days
    DateTime checkDate = uniqueDates.first;
    // If the latest entry is today, start counting from today. 
    // If it was yesterday, start from yesterday.
    
    for (int i = 0; i < uniqueDates.length; i++) {
      // Ideally, uniqueDates[i] should be exactly 1 day before uniqueDates[i-1]
      // But for the first one, we just count it.
      if (i == 0) {
        streak++;
        continue;
      }

      final prevDate = uniqueDates[i - 1];
      final currentDate = uniqueDates[i];
      
      final difference = prevDate.difference(currentDate).inDays;
      
      if (difference == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
