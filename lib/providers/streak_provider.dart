// lib/providers/streak_provider.dart
import 'package:flutter/foundation.dart';

class StreakProvider with ChangeNotifier {
  int _currentStreak = 0;
  DateTime? _lastOpenedDate;

  int get currentStreak => _currentStreak;
  DateTime? get lastOpenedDate => _lastOpenedDate;

  void incrementStreak() {
    _currentStreak++;
    notifyListeners();
  }

  void updateLastOpenedDate(DateTime date) {
    _lastOpenedDate = date;
    notifyListeners();
  }

  void resetStreak() {
    _currentStreak = 0;
    _lastOpenedDate = null;
    notifyListeners();
  }
}