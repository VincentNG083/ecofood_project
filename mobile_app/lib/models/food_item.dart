class FoodItem {
  final String id;
  String name;
  String category;
  double quantity;
  String unit;
  DateTime expiryDate;
  String zone;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.zone,
  });

  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return exp.difference(today).inDays;
  }

  String get formattedDate =>
      '${expiryDate.day.toString().padLeft(2, '0')}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year}';

  String get quantityDisplay {
    final q =
        quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toString();
    return '$q $unit';
  }

  /// Map từ JSON trả về của FastAPI (GET /items/)
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? 'Rau củ',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] ?? 'g',
      expiryDate: DateTime.tryParse(json['expiry_date'] ?? '') ??
          DateTime.now().add(const Duration(days: 3)),
      zone: json['zone'] ?? 'Ngăn mát',
    );
  }

  /// Chuyển sang JSON để gửi lên FastAPI (POST /items/)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiry_date': expiryDate.toIso8601String(),
      'zone': zone,
    };
  }
}

/// Dữ liệu AI bóc tách từ OCR / Voice để kiểm tra ở Screen 8 trước khi lưu
class DraftFoodItem {
  String name;
  String category;
  double qty;
  String unit;
  int days;
  String zone;
  bool selected;

  DraftFoodItem({
    required this.name,
    required this.category,
    required this.qty,
    required this.unit,
    required this.days,
    required this.zone,
    this.selected = true,
  });

  FoodItem toFoodItem() {
    return FoodItem(
      id: 'f_${DateTime.now().microsecondsSinceEpoch}_$name',
      name: name,
      category: category,
      quantity: qty,
      unit: unit,
      expiryDate: DateTime.now().add(Duration(days: days)),
      zone: zone,
    );
  }
}

class RecipeItem {
  final String id;
  final String title;
  final String description;
  final String cookTime;
  final String difficulty;
  final List<String> requiredIngredients;
  final List<String> pantryStaples;
  final List<String> steps;

  const RecipeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.cookTime,
    required this.difficulty,
    required this.requiredIngredients,
    required this.pantryStaples,
    required this.steps,
  });
}