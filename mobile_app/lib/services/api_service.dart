import 'package:flutter/material.dart';
import '../models/food_item.dart';
import 'food_classifier_service.dart';

class ApiService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  int _reminderDays = 1;
  bool _notificationsEnabled = true;
  int _rescuedCount = 0;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  int get reminderDays => _reminderDays;
  bool get notificationsEnabled => _notificationsEnabled;
  int get rescuedCount => _rescuedCount;

  // GIAO DIỆN TRỐNG BAN ĐẦU (Không có sẵn nguyên liệu mẫu)
  final List<FoodItem> _items = [];

  List<FoodItem> get items {
    final list = List<FoodItem>.from(_items);
    list.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    return list;
  }

  List<FoodItem> get expiringSoonItems =>
      items.where((e) => e.daysLeft <= 3).toList();

  List<FoodItem> itemsByZone(String zone) {
    if (zone == 'Tất cả') return items;
    return items.where((e) => e.zone == zone).toList();
  }

  void setDarkMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setReminderDays(int days) {
    _reminderDays = days;
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  void saveItem(FoodItem item) {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      _items[idx] = item;
    } else {
      _items.insert(0, item);
    }
    notifyListeners();
  }

  void addMultipleItems(List<FoodItem> newItems) {
    _items.insertAll(0, newItems);
    notifyListeners();
  }

  void consumeItem(String id) {
    _items.removeWhere((e) => e.id == id);
    _rescuedCount++;
    notifyListeners();
  }

  void consumeMatchingIngredients(List<String> names) {
    for (final name in names) {
      final idx = _items.indexWhere(
          (item) => item.name.toLowerCase().contains(name.toLowerCase()));
      if (idx >= 0) {
        _items.removeAt(idx);
        _rescuedCount++;
      }
    }
    notifyListeners();
  }

  /// Phân tích văn bản thực tế từ OCR hoặc Giọng nói
  List<DraftFoodItem> analyzeDetectedText(String rawText) {
    return FoodClassifierService.parseRawTextToDrafts(rawText);
  }
}