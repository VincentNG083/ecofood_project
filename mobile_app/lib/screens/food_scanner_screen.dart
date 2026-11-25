import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/food_api_service.dart';
import 'detected_foods_screen.dart';

class FoodScannerScreen extends StatefulWidget {
  final FoodApiService apiService;
  final bool isReceiptMode;

  const FoodScannerScreen({
    super.key,
    required this.apiService,
    required this.isReceiptMode,
  });

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  bool _isAnalyzing = false;

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _isAnalyzing = true;
    });

    try {
      final detectedList = await widget.apiService.detectFoodsFromImage(
        imageBytes: bytes,
        isReceiptMode: widget.isReceiptMode,
      );
      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DetectedFoodsScreen(
            apiService: widget.apiService,
            capturedImage: bytes,
            isReceiptMode: widget.isReceiptMode,
            detectedItems: detectedList,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTokens.danger,
          content: Text('Không thể nhận diện ảnh: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTokens.darkSurface : AppTokens.lightSurface;
    final border = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isReceiptMode
            ? 'Chụp hóa đơn mua hàng'
            : 'Chụp bàn thực phẩm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTokens.tint(AppTokens.primary, 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates_outlined,
                      color: AppTokens.primaryDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.isReceiptMode
                          ? 'Đặt hóa đơn phẳng, đủ sáng để Gemini AI trích xuất danh sách thực phẩm.'
                          : 'Bày các thực phẩm cần bảo quản lên bàn, giữ camera bao quát toàn bộ các món.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  border: Border.all(color: border, width: 1.5),
                ),
                child: _isAnalyzing
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppTokens.primary),
                          SizedBox(height: 14),
                          Text(
                            'Gemini Vision AI đang phân tích hình ảnh...',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      )
                    : _imageBytes != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusLg),
                            child: Image.memory(_imageBytes!,
                                fit: BoxFit.contain),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isReceiptMode
                                    ? Icons.receipt_long_rounded
                                    : Icons.dining_rounded,
                                size: 64,
                                color: AppTokens.primary,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Chọn chụp trực tiếp bằng Camera hoặc tải ảnh từ máy',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokens.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      ),
                    ),
                    onPressed: _isAnalyzing
                        ? null
                        : () => _pickAndAnalyze(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Mở Camera',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      ),
                    ),
                    onPressed: _isAnalyzing
                        ? null
                        : () => _pickAndAnalyze(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Chọn ảnh có sẵn',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}