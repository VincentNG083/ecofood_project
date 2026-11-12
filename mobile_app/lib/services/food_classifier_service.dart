import '../models/food_item.dart';

class FoodClassifierService {
  /// 1. Tự động phân loại nhóm thực phẩm từ tên món
  static String classifyCategory(String name) {
    final lower = name.toLowerCase();
    if (_containsAny(lower, [
      'thịt', 'bò', 'heo', 'lợn', 'gà', 'vịt', 'cá', 'tôm', 'mực', 'cua', 'sườn', 'ba chỉ', 'xúc xích', 'chả'
    ])) {
      return 'Thịt cá';
    }
    if (_containsAny(lower, [
      'rau', 'cải', 'cà chua', 'cà rốt', 'khoai', 'hành', 'tỏi', 'xà lách', 'nấm', 'bí', 'bầu', 'mướp', 'đậu cove', 'bông cải', 'chanh', 'ớt', 'trái cây', 'táo', 'chuối'
    ])) {
      return 'Rau củ';
    }
    if (_containsAny(lower, [
      'sữa', 'trứng', 'phô mai', 'bơ', 'sữa chua', 'váng sữa', 'kem'
    ])) {
      return 'Sữa & Trứng';
    }
    if (_containsAny(lower, [
      'gạo', 'mì', 'bún', 'miến', 'đậu', 'hạt', 'bánh', 'gia vị', 'nước mắm', 'dầu ăn', 'đường', 'muối'
    ])) {
      return 'Đồ khô';
    }
    return 'Rau củ';
  }

  /// 2. Tự động gợi ý ngăn lưu trữ mặc định
  static String suggestDefaultZone(String name, String category) {
    final lower = name.toLowerCase();
    if (_containsAny(lower, ['cấp đông', 'đông lạnh', 'kem', 'đá'])) {
      return 'Ngăn đông';
    }
    if (category == 'Đồ khô') {
      return 'Tủ khô';
    }
    return 'Ngăn mát';
  }

  /// 3. Bảng quy tắc tính số ngày bảo quản dựa vào (Nhóm thực phẩm + Ngăn lưu trữ)
  static int calculateShelfLifeDays({
    required String category,
    required String zone,
  }) {
    switch (category) {
      case 'Thịt cá':
        if (zone == 'Ngăn đông') return 30;
        if (zone == 'Ngăn mát') return 2;
        return 1; // Tủ khô
      case 'Rau củ':
        if (zone == 'Ngăn đông') return 14;
        if (zone == 'Ngăn mát') return 4;
        return 2; // Tủ khô
      case 'Sữa & Trứng':
        if (zone == 'Ngăn đông') return 30;
        if (zone == 'Ngăn mát') return 7;
        return 2; // Tủ khô
      case 'Đồ khô':
      default:
        if (zone == 'Ngăn đông') return 90;
        if (zone == 'Ngăn mát') return 60;
        return 45; // Tủ khô
    }
  }

  /// 4. Tính ngày hết hạn thực tế từ đồng hồ hệ thống của điện thoại
  static DateTime calculateExpiryDate({
    required String category,
    required String zone,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = calculateShelfLifeDays(category: category, zone: zone);
    return today.add(Duration(days: days));
  }

  /// 5. Tách văn bản thô (từ Giọng nói hoặc OCR) thành danh sách thực phẩm nháp
  static List<DraftFoodItem> parseRawTextToDrafts(String rawText) {
    // Tách theo dấu xuống dòng, dấu phẩy, chấm phẩy hoặc chữ " và "
    final segments = rawText
        .replaceAll(RegExp(r'\s+và\s+', caseSensitive: false), ',')
        .split(RegExp(r'[\n,;]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final List<DraftFoodItem> results = [];

    for (var seg in segments) {
      // Loại bỏ các từ dẫn dắt tự nhiên khi người dùng nói
      seg = seg.replaceFirst(
        RegExp(
          r'^(tôi\s+mới\s+mua|tôi\s+vừa\s+mua|mua\s+thêm|thêm|có|lấy)\s+',
          caseSensitive: false,
        ),
        '',
      );

      // Xác định ngăn bảo quản nếu người dùng nhắc tới trong câu
      String? explicitZone;
      if (seg.toLowerCase().contains('ngăn đông') ||
          seg.toLowerCase().contains('cấp đông')) {
        explicitZone = 'Ngăn đông';
      } else if (seg.toLowerCase().contains('tủ khô')) {
        explicitZone = 'Tủ khô';
      } else if (seg.toLowerCase().contains('ngăn mát')) {
        explicitZone = 'Ngăn mát';
      }

      seg = seg
          .replaceAll(
            RegExp(r'(để\s+vào|cho\s+vào|để|ở)?\s*(ngăn mát|ngăn đông|tủ khô)',
                caseSensitive: false),
            '',
          )
          .trim();

      // Bóc tách số lượng & đơn vị (VD: "350g thịt bò", "2 bó rau muống", "thịt gà 500 g")
      double qty = 1;
      String unit = 'phần';
      String foodName = seg;

      final leadingMatch = RegExp(
        r'^(\d+(?:[.,]\d+)?)\s*(kg|g|gam|lít|ml|bó|quả|trái|hộp|gói|vỉ|con|củ|bông)?\s+(.+)$',
        caseSensitive: false,
      ).firstMatch(seg);

      final trailingMatch = RegExp(
        r'^(.+?)\s+(\d+(?:[.,]\d+)?)\s*(kg|g|gam|lít|ml|bó|quả|trái|hộp|gói|vỉ|con|củ|bông)?$',
        caseSensitive: false,
      ).firstMatch(seg);

      if (leadingMatch != null) {
        qty = double.tryParse(leadingMatch.group(1)!.replaceAll(',', '.')) ?? 1;
        unit = _normalizeUnit(leadingMatch.group(2));
        foodName = leadingMatch.group(3)!.trim();
      } else if (trailingMatch != null) {
        foodName = trailingMatch.group(1)!.trim();
        qty =
            double.tryParse(trailingMatch.group(2)!.replaceAll(',', '.')) ?? 1;
        unit = _normalizeUnit(trailingMatch.group(3));
      }

      if (foodName.isEmpty) continue;
      // Viết hoa chữ cái đầu
      foodName = foodName[0].toUpperCase() + foodName.substring(1);

      final category = classifyCategory(foodName);
      final zone = explicitZone ?? suggestDefaultZone(foodName, category);
      final days = calculateShelfLifeDays(category: category, zone: zone);

      results.add(
        DraftFoodItem(
          name: foodName,
          category: category,
          qty: qty,
          unit: unit,
          days: days,
          zone: zone,
        ),
      );
    }

    return results;
  }

  static String _normalizeUnit(String? rawUnit) {
    if (rawUnit == null || rawUnit.isEmpty) return 'phần';
    final u = rawUnit.toLowerCase();
    if (u == 'gam') return 'g';
    if (u == 'trái') return 'quả';
    return u;
  }

  static bool _containsAny(String source, List<String> keywords) {
    for (final k in keywords) {
      if (source.contains(k)) return true;
    }
    return false;
  }
}