import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';

class SettingScreen extends StatelessWidget {
  final ApiService apiService;

  const SettingScreen({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: apiService,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface =
            isDark ? AppTokens.darkSurface : AppTokens.lightSurface;
        final border = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;

        return Scaffold(
          appBar: AppBar(title: const Text('Cài đặt')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Thẻ thông tin tài khoản
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: AppTokens.primary,
                      child: Icon(Icons.person_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nguyễn Tấn Phú',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16)),
                          const Text('tanphu.ecofood@gmail.com',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            'Đã giải cứu ${apiService.rescuedCount} thực phẩm 🌱',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTokens.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Cài đặt thông báo hạn sử dụng
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Nhắc nhở thực phẩm sắp hết hạn',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      value: apiService.notificationsEnabled,
                      onChanged: apiService.setNotificationsEnabled,
                    ),
                    const Divider(),
                    Row(
                      children: [1, 2, 3, 5].map((d) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: ChoiceChip(
                              label: Text('Trước ${d}d'),
                              selected: apiService.reminderDays == d,
                              onSelected: (_) => apiService.setReminderDays(d),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Chế độ giao diện Sáng / Tối
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: border),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Chế độ tối (Dark Mode)',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  value: apiService.isDarkMode,
                  onChanged: apiService.setDarkMode,
                ),
              ),
              const SizedBox(height: 24),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTokens.danger,
                  side: const BorderSide(color: AppTokens.danger),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => AuthScreen(apiService: apiService)),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Đăng xuất'),
              ),
            ],
          ),
        );
      },
    );
  }
}