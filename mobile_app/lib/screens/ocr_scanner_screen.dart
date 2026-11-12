import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'ai_review_screen.dart';

class OcrScannerScreen extends StatefulWidget {
  final ApiService apiService;

  const OcrScannerScreen({super.key, required this.apiService});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  bool _isProcessing = false;
  final TextEditingController _ocrTextCtrl = TextEditingController();

  @override
  void dispose() {
    _ocrTextCtrl.dispose();
    super.dispose();
  }

  Future<void> _captureImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _isProcessing = true;
    });

    // Gọi API FastAPI OCR nếu đã chạy server (thay IP máy tính của bạn nếu test trên điện thoại)
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/ocr/scan'),
      );
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: picked.name),
      );
      final streamed =
          await request.send().timeout(const Duration(seconds: 5));
      if (streamed.statusCode == 200) {
        final body = await streamed.stream.bytesToString();
        final data = jsonDecode(body);
        _ocrTextCtrl.text = data['raw_text'] ?? '';
      }
    } catch (_) {
      // Nếu chưa bật server FastAPI, người dùng có thể gõ/dán nhanh nội dung trên ảnh để test
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _analyzeAndProceed() {
    final text = _ocrTextCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng chụp hóa đơn hoặc nhập nội dung quét được.')),
      );
      return;
    }

    final drafts = widget.apiService.analyzeDetectedText(text);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AiReviewScreen(
          apiService: widget.apiService,
          sourceLabel: 'Kết quả quét hóa đơn từ Camera',
          draftItems: drafts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTokens.darkSurface : AppTokens.lightSurface;
    final border = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;

    return Scaffold(
      appBar: AppBar(title: const Text('Quét hóa đơn bằng Camera')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border, width: 1.5),
              ),
              child: _imageBytes == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            size: 52, color: AppTokens.primary),
                        SizedBox(height: 10),
                        Text('Chưa có ảnh hóa đơn nào được chụp',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                    ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokens.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _captureImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Mở Camera chụp'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _captureImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Chọn ảnh có sẵn'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: AppTokens.primary),
              ),
            TextField(
              controller: _ocrTextCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Văn bản trích xuất từ hóa đơn (OCR)',
                hintText:
                    'VD: 500g thịt ba chỉ, 2 bó rau muống, 1 hộp sữa tươi...',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                ),
                onPressed: _analyzeAndProceed,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Phân loại & Tính HSD tự động',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}