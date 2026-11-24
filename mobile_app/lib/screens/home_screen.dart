import 'package:flutter/material.dart';
import '../main.dart';
import '../models/food_guide.dart';
import '../services/food_api_service.dart';
import 'food_scanner_screen.dart';
import 'food_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final FoodApiService apiService;

  const HomeScreen({super.key, required this.apiService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'Tất cả';

  final List<String> _categories = [
    'Tất cả',
    'Rau củ',
    'Thịt cá',
    'Sữa & Trứng',
    'Đồ khô',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    widget.apiService.fetchFoods(
      query: _searchCtrl.text,
      category: _selectedCategory,
    );
  }

  void _showServerSettingsDialog() {
    final ctrl = TextEditingController(text: widget.apiService.baseUrl);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cấu hình địa chỉ Server',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập IP máy tính chạy FastAPI (VD: http://192.168.1.15:8000 khi test trên điện thoại):',
              style: TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                prefixIcon: Icon(Icons.dns_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.apiService.updateBaseUrl(ctrl.text);
              Navigator.pop(dialogCtx);
            },
            child: const Text('Kết nối'),
          ),
        ],
      ),
    );
  }

  void _openScanner({required bool isReceiptMode}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodScannerScreen(
          apiService: widget.apiService,
          isReceiptMode: isReceiptMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.apiService,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface =
            isDark ? AppTokens.darkSurface : AppTokens.lightSurface;
        final border = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;
        final subtext =
            isDark ? AppTokens.darkSubtext : AppTokens.lightSubtext;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTokens.tint(AppTokens.primary, 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.eco_rounded,
                      color: AppTokens.primary, size: 22),
                ),
                const SizedBox(width: 10),
                const Text('ECOFOOD'),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Cấu hình IP Server',
                onPressed: _showServerSettingsDialog,
                icon: const Icon(Icons.settings_ethernet_rounded),
              ),
              IconButton(
                tooltip: 'Đổi giao diện Sáng/Tối',
                onPressed: widget.apiService.toggleDarkMode,
                icon: Icon(isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_outlined),
              ),
            ],
          ),
          body: Column(
            children: [
              // THANH TRẠNG THÁI KẾT NỐI SERVER THẬT
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: widget.apiService.isConnected
                        ? AppTokens.tint(AppTokens.primary, 0.12)
                        : AppTokens.tint(AppTokens.danger, 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 9,
                        color: widget.apiService.isConnected
                            ? AppTokens.primary
                            : AppTokens.danger,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.apiService.isConnected
                              ? 'Đã kết nối Server (${widget.apiService.baseUrl}) • ${widget.apiService.foods.length} món'
                              : (widget.apiService.errorMessage ??
                                  'Đang kết nối Server...'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.apiService.isConnected
                                ? AppTokens.primaryDark
                                : AppTokens.danger,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!widget.apiService.isConnected)
                        InkWell(
                          onTap: _onFilterChanged,
                          child: const Text(
                            'Thử lại',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppTokens.danger,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // TÌM KIẾM NHANH SẢN PHẨM
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => _onFilterChanged(),
                  decoration: InputDecoration(
                    hintText: 'Tìm nhanh thực phẩm (VD: thịt ba chỉ, rau muống...)',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTokens.primary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchCtrl.clear();
                              _onFilterChanged();
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // HAI NÚT CHỤP NHẬN DIỆN AI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildScanActionCard(
                        title: 'Chụp bàn thực phẩm',
                        subtitle: 'AI nhận diện nhiều món',
                        icon: Icons.camera_alt_rounded,
                        gradient: const [
                          AppTokens.primary,
                          AppTokens.primaryDark
                        ],
                        onTap: () => _openScanner(isReceiptMode: false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildScanActionCard(
                        title: 'Chụp hóa đơn',
                        subtitle: 'Trích xuất danh sách mua',
                        icon: Icons.receipt_long_rounded,
                        gradient: const [
                          AppTokens.secondary,
                          Color(0xFF0284C7)
                        ],
                        onTap: () => _openScanner(isReceiptMode: true),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // LỌC DANH MỤC
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppTokens.tint(AppTokens.primary, 0.2),
                      labelStyle: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppTokens.primaryDark : null,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                        _onFilterChanged();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // DANH SÁCH THỰC PHẨM TỪ DATABASE
              Expanded(
                child: widget.apiService.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppTokens.primary))
                    : widget.apiService.foods.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                widget.apiService.isConnected
                                    ? 'Không tìm thấy thực phẩm phù hợp trong cơ sở dữ liệu.'
                                    : 'Chưa kết nối được Server. Hãy khởi chạy FastAPI và bấm "Thử lại".',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: subtext),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _onFilterChanged(),
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 4, 20, 24),
                              itemCount: widget.apiService.foods.length,
                              itemBuilder: (context, idx) {
                                final food = widget.apiService.foods[idx];
                                return _buildFoodCard(
                                    food, surface, border, subtext);
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppTokens.tint(gradient.first, 0.28),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(
      FoodGuide food, Color surface, Color border, Color subtext) {
    final defaultMethod = food.defaultMethod;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodDetailScreen(food: food),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 68,
                height: 68,
                color: AppTokens.tint(AppTokens.primary, 0.12),
                child: food.thumbnailUrl != null
                    ? Image.network(
                        food.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.restaurant_rounded,
                            color: AppTokens.primary,
                            size: 30),
                      )
                    : const Icon(Icons.restaurant_rounded,
                        color: AppTokens.primary, size: 30),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTokens.tint(AppTokens.primary, 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          food.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTokens.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (defaultMethod != null)
                    Row(
                      children: [
                        const Icon(Icons.ac_unit_rounded,
                            size: 14, color: AppTokens.secondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${defaultMethod.storageZone} • ${defaultMethod.shelfLifeText}',
                            style: TextStyle(fontSize: 12.5, color: subtext),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Có ${food.methods.length} cách bảo quản • Bấm để xem chi tiết',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTokens.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}