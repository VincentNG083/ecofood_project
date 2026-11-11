import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoFood Test API',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  // Hàm gọi API từ nút bấm
  Future<void> _callApiAndShowPopup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Địa chỉ API FastAPI:
      // - Nếu chạy trên Android Emulator: dùng http://10.0.2.2:8000/
      // - Nếu chạy trên Chrome (Web): dùng http://127.0.0.1:8000/
      final url = Uri.parse('http://127.0.0.1:8000/');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Hiện Popup thành công lấy từ Backend
        _showPopupDialog("Thành công từ API!", data['message']);
      } else {
        _showPopupDialog("Lỗi", "Mã phản hồi từ server: ${response.statusCode}");
      }
    } catch (e) {
      _showPopupDialog("Lỗi kết nối", "Không thể kết nối đến Backend: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm hiển thị hộp thoại Popup
  void _showPopupDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("Đóng"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ECOFOOD - Test API Connection')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const CircularProgressIndicator() // Vòng tròn loading khi đang gọi API
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _callApiAndShowPopup,
                  child: const Text(
                    'GỌI API VÀ HIỆN POPUP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
        ),
      ),
    );
  }
}