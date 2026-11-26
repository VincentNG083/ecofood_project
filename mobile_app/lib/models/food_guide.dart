class PreservationStep {
  final int stepNumber;
  final String instruction;
  final String? imageUrl;
  final String? videoUrl;

  const PreservationStep({
    required this.stepNumber,
    required this.instruction,
    this.imageUrl,
    this.videoUrl,
  });

  factory PreservationStep.fromJson(Map<String, dynamic> json) {
    return PreservationStep(
      stepNumber: json['step_number'] ?? 1,
      instruction: json['instruction'] ?? '',
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
    );
  }
}

class PreservationMethod {
  final int id;
  final int foodId;
  final String methodLabel;
  final String storageZone;
  final String shelfLifeText;
  final bool isDefault;
  final List<PreservationStep> steps;

  const PreservationMethod({
    required this.id,
    required this.foodId,
    required this.methodLabel,
    required this.storageZone,
    required this.shelfLifeText,
    required this.isDefault,
    required this.steps,
  });

  factory PreservationMethod.fromJson(Map<String, dynamic> json) {
    final rawSteps = (json['steps'] as List<dynamic>?) ?? [];
    return PreservationMethod(
      id: json['id'] ?? 0,
      foodId: json['food_id'] ?? 0,
      methodLabel: json['method_label'] ?? 'Bảo quản tiêu chuẩn',
      storageZone: json['storage_zone'] ?? 'Ngăn mát',
      shelfLifeText: json['shelf_life_text'] ?? '2 - 3 ngày',
      isDefault: json['is_default'] ?? false,
      steps: rawSteps
          .map((e) => PreservationStep.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FoodGuide {
  final int id;
  final String name;
  final String? aliases;
  final String category;
  final String? thumbnailUrl;
  final List<PreservationMethod> methods;

  const FoodGuide({
    required this.id,
    required this.name,
    this.aliases,
    required this.category,
    this.thumbnailUrl,
    required this.methods,
  });

  PreservationMethod? get defaultMethod {
    if (methods.isEmpty) return null;
    return methods.firstWhere(
      (m) => m.isDefault,
      orElse: () => methods.first,
    );
  }

  factory FoodGuide.fromJson(Map<String, dynamic> json) {
    final rawMethods = (json['methods'] as List<dynamic>?) ?? [];
    return FoodGuide(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      aliases: json['aliases'],
      category: json['category'] ?? 'Rau củ',
      thumbnailUrl: json['thumbnail_url'],
      methods: rawMethods
          .map((e) => PreservationMethod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DetectedFoodItem {
  String detectedName;
  FoodGuide? matchedGuide;

  DetectedFoodItem({
    required this.detectedName,
    this.matchedGuide,
  });
}