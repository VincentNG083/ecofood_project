import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/food_guide.dart';

class FoodApiService extends ChangeNotifier {
  String _baseUrl = 'http://127.0.0.1:8000';
  String get baseUrl => _baseUrl;

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  List<FoodGuide> _foods = [];
  List<FoodGuide> _allCachedFoods = [];
  bool _isLoading = false;
  bool _isConnected = false;
  String? _errorMessage;

  List<FoodGuide> get foods => _foods;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;

  FoodApiService() {
    fetchFoods();
  }

  void toggleDarkMode() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> updateBaseUrl(String newUrl) async {
    final cleaned = newUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (cleaned.isEmpty) return;
    _baseUrl = cleaned.startsWith('http') ? cleaned : 'http://$cleaned';
    await fetchFoods();
  }

  /// Lấy danh sách thực phẩm thật từ GET /foods/?q=...&category=...
  Future<void> fetchFoods({String? query, String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final params = <String, String>{};
      if (query != null && query.trim().isNotEmpty) {
        params['q'] = query.trim();
      }
      if (category != null && category != 'Tất cả') {
        params['category'] = category;
      }

      final uri =
          Uri.parse('$_baseUrl/foods/').replace(queryParameters: params);
      final res = await http.get(uri).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        _foods = data
            .map((e) => FoodGuide.fromJson(e as Map<String, dynamic>))
            .toList();
        if (params.isEmpty) {
          _allCachedFoods = List.from(_foods);
        }
        _isConnected = true;
        _errorMessage = null;
      } else {
        _isConnected = false;
        _errorMessage = 'Server phản hồi mã lỗi ${res.statusCode}';
      }
    } catch (e) {
      _isConnected = false;
      _foods = [];
      _errorMessage = 'Không kết nối được tới $_baseUrl';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tra cứu thông tin bảo quản thật từ SQLite theo tên món (dùng sau khi AI nhận diện hoặc người dùng Edit tên)
  Future<FoodGuide> resolveFoodGuide(String name) async {
    final lower = name.trim().toLowerCase();

    for (final f in _allCachedFoods) {
      if (f.name.toLowerCase().contains(lower) ||
          (f.aliases?.toLowerCase().contains(lower) ?? false)) {
        return f;
      }
    }

    try {
      final uri = Uri.parse('$_baseUrl/foods/')
          .replace(queryParameters: {'q': name.trim()});
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        if (data.isNotEmpty) {
          return FoodGuide.fromJson(data.first as Map<String, dynamic>);
        }
      }
    } catch (_) {}

    // Fallback tối thiểu nếu thực phẩm mới chưa được nạp hướng dẫn chi tiết vào SQLite
    return FoodGuide(
      id: 0,
      name: name,
      category: 'Chưa phân loại',
      methods: const [
        PreservationMethod(
          id: 0,
          foodId: 0,
          methodLabel: 'Ngăn mát tiêu chuẩn',
          storageZone: 'Ngăn mát (2°C - 4°C)',
          shelfLifeText: '3 - 5 ngày',
          isDefault: true,
          steps: [
            PreservationStep(
              stepNumber: 1,
              instruction:
                  'Làm sạch sơ bộ và thấm khô bề mặt thực phẩm bằng khăn giấy.',
            ),
            PreservationStep(
              stepNumber: 2,
              instruction:
                  'Cho vào hộp kín hoặc túi zip ép bớt không khí trước khi đặt vào ngăn mát.',
            ),
          ],
        ),
      ],
    );
  }

  /// Gửi ảnh chụp thật lên AI Vision trên FastAPI (/detect-table hoặc /ocr/scan)
  Future<List<DetectedFoodItem>> detectFoodsFromImage({
    required Uint8List imageBytes,
    required bool isReceiptMode,
  }) async {
    final endpoint = isReceiptMode ? '/ocr/scan' : '/detect-table';
    final req = http.MultipartRequest('POST', Uri.parse('$_baseUrl$endpoint'));
    req.files.add(
      http.MultipartFile.fromBytes('file', imageBytes, filename: 'capture.jpg'),
    );

    final streamed = await req.send().timeout(const Duration(seconds: 25));
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode == 200) {
      final decoded = jsonDecode(body);
      final List<dynamic> names = decoded['items'] ?? [];
      final results = <DetectedFoodItem>[];
      for (final n in names) {
        final foodName = n.toString();
        final guide = await resolveFoodGuide(foodName);
        results.add(DetectedFoodItem(
          detectedName: foodName,
          matchedGuide: guide,
        ));
      }
      return results;
    } else {
      throw Exception('Lỗi từ Server (${streamed.statusCode}): $body');
    }
  }
}