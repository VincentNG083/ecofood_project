import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  final ApiService apiService;

  const SplashScreen({super.key, required this.apiService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _pulseAnim;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );

    _navTimer = Timer(const Duration(milliseconds: 2200), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AuthScreen(apiService: widget.apiService),
      ),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTokens.primary, AppTokens.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppTokens.tint(AppTokens.primary, 0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.kitchen_rounded,
                          size: 54, color: Colors.white),
                      Positioned(
                        right: 20,
                        top: 20,
                        child: CircleAvatar(
                          radius: 13,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.eco_rounded,
                              size: 16, color: AppTokens.primaryDark),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'ECOFOOD',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Trạm quản lý tủ lạnh thông minh\nChống lãng phí thực phẩm mỗi ngày',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark
                      ? AppTokens.darkTextSecondary
                      : AppTokens.lightTextSecondary,
                ),
              ),
              const Spacer(flex: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  color: AppTokens.primary,
                  backgroundColor: AppTokens.tint(AppTokens.primary, 0.15),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _goNext,
                child: const Text(
                  'Bắt đầu ngay →',
                  style: TextStyle(
                    color: AppTokens.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}