import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../main.dart';
import '../services/api_service.dart';
import 'ai_review_screen.dart';

class VoiceInputScreen extends StatefulWidget {
  final ApiService apiService;

  const VoiceInputScreen({super.key, required this.apiService});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  final TextEditingController _transcriptCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) {
      setState(() => _speechAvailable = available);
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Thiết bị chưa cấp quyền Micro hoặc không hỗ trợ giọng nói.')),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        localeId: 'vi_VN',
        onResult: (result) {
          setState(() {
            _transcriptCtrl.text = result.recognizedWords;
          });
        },
      );
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _transcriptCtrl.dispose();
    super.dispose();
  }

  void _analyzeVoice() {
    final text = _transcriptCtrl.text.trim();
    if (text.isEmpty) return;

    final drafts = widget.apiService.analyzeDetectedText(text);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AiReviewScreen(
          apiService: widget.apiService,
          sourceLabel: 'Kết quả nhận diện giọng nói',
          draftItems: drafts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đọc thực phẩm (Speech-to-Text)')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Bấm vào Micro và đọc tên các món vừa mua\n(VD: "300g thịt bò ngăn đông, 1 bó rau muống, 6 quả trứng gà")',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13.5, height: 1.4),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _toggleListening,
              child: Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTokens.tint(
                      _isListening ? AppTokens.danger : AppTokens.secondary,
                      0.16),
                  border: Border.all(
                    color:
                        _isListening ? AppTokens.danger : AppTokens.secondary,
                    width: 3,
                  ),
                ),
                child: Icon(
                  _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 52,
                  color: _isListening ? AppTokens.danger : AppTokens.secondary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _isListening
                  ? 'Đang thu âm... Bấm lại để dừng'
                  : 'Bấm biểu tượng Micro để bắt đầu nói',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _isListening ? AppTokens.danger : AppTokens.secondary,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _transcriptCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Nội dung giọng nói nhận diện được',
                hintText: 'Văn bản sẽ tự động hiện ra khi bạn nói...',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                ),
                onPressed: _analyzeVoice,
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