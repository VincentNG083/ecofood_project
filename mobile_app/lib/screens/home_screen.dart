import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'storage_detail_screen.dart';
import 'ocr_scanner_screen.dart';
import 'voice_input_screen.dart';
import 'manual_add_screen.dart';
import 'recommend_screen.dart';
import 'setting_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;

  const HomeScreen({super.key, required this.apiService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0;

  // SCREEN 5: Popup menu chọn cách nhập khi bấm dấu '+' ở dưới
  void _openAddMenuPopup() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTokens.darkSurface : AppTokens.lightSurface;

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(100),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Thêm thực phẩm mới',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'Chọn phương thức nhập liệu vào tủ lạnh',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _buildMethodTile(
                icon: Icons.document_scanner_rounded,
                color: AppTokens.primary,
                title: 'Quét hóa đơn (OCR / Scanner)',
                subtitle: 'Chụp hóa đơn siêu thị, AI tự nhận diện danh sách món',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          OcrScannerScreen(apiService: widget.apiService),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildMethodTile(
                icon: Icons.mic_rounded,
                color: AppTokens.secondary,
                title: 'Đọc hóa đơn (Voice AI)',
                subtitle: 'Đọc tên món và số lượng bằng giọng nói tự nhiên',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          VoiceInputScreen(apiService: widget.apiService),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildMethodTile(
                icon: Icons.edit_note_rounded,
                color: AppTokens.warning,
                title: 'Nhập thủ công (Manual)',
                subtitle: 'Tự nhập tên món, số lượng và chọn ngày hết hạn',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ManualAddScreen(apiService: widget.apiService),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMethodTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTokens.tint(color, 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTokens.darkSurface : AppTokens.lightSurface;
    final border = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;

    final tabs = [
      _HomeOverviewTab(
        apiService: widget.apiService,
        onGoStorage: () => setState(() => _activeTab = 1),
        onGoRecommend: () => setState(() => _activeTab = 2),
      ),
      StorageDetailScreen(
        apiService: widget.apiService,
        showBackButton: false,
      ),
      RecommendScreen(apiService: widget.apiService),
      SettingScreen(apiService: widget.apiService),
    ];

    return Scaffold(
      body: tabs[_activeTab],
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: surface,
          border: Border(top: BorderSide(color: border)),
        ),
        child: Row(
          children: [
            _buildNavTab(0, Icons.home_outlined, Icons.home_rounded, 'Trang chủ'),
            _buildNavTab(
                1, Icons.kitchen_outlined, Icons.kitchen_rounded, 'Kho đồ'),
            // Nút dấu '+' ở giữa giống TikTok / YouTube
            Expanded(
              child: GestureDetector(
                onTap: _openAddMenuPopup,
                child: Center(
                  child: Container(
                    width: 52,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTokens.primary, AppTokens.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTokens.tint(AppTokens.primary, 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
            _buildNavTab(2, Icons.restaurant_menu_outlined,
                Icons.restaurant_menu_rounded, 'Gợi ý'),
            _buildNavTab(
                3, Icons.settings_outlined, Icons.settings_rounded, 'Cài đặt'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTab(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTokens.primary : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTokens.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeOverviewTab extends StatelessWidget {
  final ApiService apiService;
  final VoidCallback onGoStorage;
  final VoidCallback onGoRecommend;

  const _HomeOverviewTab({
    required this.apiService,
    required this.onGoStorage,
    required this.onGoRecommend,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: apiService,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface =
            isDark ? AppTokens.darkSurface : AppTokens.lightSurface;
        final border = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;
        final urgent = apiService.expiringSoonItems;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chào Phú 👋',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Tủ lạnh hiện có ${apiService.items.length} thực phẩm',
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: onGoStorage,
                      icon: const Icon(Icons.inventory_2_outlined,
                          size: 18, color: AppTokens.primary),
                      label: const Text(
                        'Toàn bộ kho',
                        style: TextStyle(
                            color: AppTokens.primary,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 3 Khu vực lưu trữ (Bấm vào mở Screen 4 lọc theo ngăn)
                Row(
                  children: [
                    _zoneCard(
                      context,
                      'Ngăn mát',
                      Icons.ac_unit_rounded,
                      AppTokens.secondary,
                      apiService.itemsByZone('Ngăn mát').length,
                    ),
                    const SizedBox(width: 10),
                    _zoneCard(
                      context,
                      'Ngăn đông',
                      Icons.severe_cold_rounded,
                      AppTokens.purpleFreeze,
                      apiService.itemsByZone('Ngăn đông').length,
                    ),
                    const SizedBox(width: 10),
                    _zoneCard(
                      context,
                      'Tủ khô',
                      Icons.kitchen_rounded,
                      AppTokens.warning,
                      apiService.itemsByZone('Tủ khô').length,
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Thẻ điều hướng nhanh sang Screen 10 (Recommend)
                InkWell(
                  onTap: onGoRecommend,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTokens.primary, AppTokens.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 30),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gợi ý món ăn hôm nay',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Giải cứu ${urgent.length} thực phẩm sắp hết hạn',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                const Text(
                  '🚨 Thực phẩm sắp hết hạn',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (urgent.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      border: Border.all(color: border),
                    ),
                    child: const Text(
                      'Tuyệt vời! Chưa có món nào sắp hết hạn.',
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...urgent.map((item) {
                    final color = item.daysLeft <= 1
                        ? AppTokens.danger
                        : AppTokens.warning;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                        border: Border.all(color: AppTokens.tint(color, 0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, color: color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                                Text('${item.quantityDisplay} • ${item.zone}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTokens.tint(color, 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radiusPill),
                            ),
                            child: Text(
                              'Còn ${item.daysLeft} ngày',
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline_rounded,
                                color: AppTokens.primary),
                            onPressed: () => apiService.consumeItem(item.id),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _zoneCard(BuildContext context, String zone, IconData icon,
      Color accent, int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTokens.darkSurface : AppTokens.lightSurface;
    final border = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;

    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StorageDetailScreen(
                apiService: apiService,
                initialZone: zone,
                showBackButton: true,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accent, size: 24),
              const SizedBox(height: 10),
              Text(zone,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14)),
              Text('$count món',
                  style: TextStyle(
                      fontSize: 12,
                      color: accent,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}