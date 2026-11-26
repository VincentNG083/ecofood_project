import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/food_guide.dart';
import '../services/food_api_service.dart';
import 'food_detail_screen.dart';

class DetectedFoodsScreen extends StatefulWidget {
  final FoodApiService apiService;
  final Uint8List? capturedImage;
  final bool isReceiptMode;
  final List<DetectedFoodItem> detectedItems;

  const DetectedFoodsScreen({
    super.key,
    required this.apiService,
    this.capturedImage,
    required this.isReceiptMode,
    required this.detectedItems,
  });

  @override
  State<DetectedFoodsScreen> createState() => _DetectedFoodsScreenState();
}

class _DetectedFoodsScreenState extends State<DetectedFoodsScreen> {
  late List<DetectedFoodItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.detectedItems);
  }

  void _editItemDialog(int index) {
    final current = _items[index];
    final ctrl = TextEditingController(text: current.detectedName);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Chỉnh sửa tên thực phẩm',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập lại tên đúng nếu AI nhận diện chưa chính xác:',
              style: TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Tên thực phẩm đúng',
                prefixIcon: Icon(Icons.edit_outlined),
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
            onPressed: () async {
              final newName = ctrl.text.trim();
              Navigator.pop(dialogCtx);
              if (newName.isNotEmpty) {
                final resolved =
                    await widget.apiService.resolveFoodGuide(newName);
                if (!mounted) return;
                setState(() {
                  _items[index].detectedName = newName;
                  _items[index].matchedGuide = resolved;
                });
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _addManualItemDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Thêm món bị nhận diện sót',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Tên thực phẩm',
            hintText: 'VD: Trứng gà ta',
          ),
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
            onPressed: () async {
              final name = ctrl.text.trim();
              Navigator.pop(dialogCtx);
              if (name.isNotEmpty) {
                final resolved =
                    await widget.apiService.resolveFoodGuide(name);
                if (!mounted) return;
                setState(() {
                  _items.add(DetectedFoodItem(
                    detectedName: name,
                    matchedGuide: resolved,
                  ));
                });
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTokens.darkSurface : AppTokens.lightSurface;
    final border = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả nhận diện (${_items.length} món)'),
        actions: [
          IconButton(
            tooltip: 'Thêm món bị sót',
            onPressed: _addManualItemDialog,
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppTokens.primary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.capturedImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              child: SizedBox(
                height: 155,
                width: double.infinity,
                child: Image.memory(widget.capturedImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTokens.tint(AppTokens.secondary, 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.touch_app_rounded,
                    color: AppTokens.secondary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bấm vào từng món để xem hướng dẫn bảo quản, hoặc bấm nút bút chì (✏️) để sửa nếu AI nhận diện sai.',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                    'AI không tìm thấy thực phẩm nào trong ảnh. Hãy thử chụp lại rõ nét hơn.'),
              ),
            )
          else
            ..._items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final guide = item.matchedGuide;
              final defaultMethod = guide?.defaultMethod;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: border),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  onTap: guide == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FoodDetailScreen(food: guide),
                            ),
                          );
                        },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  AppTokens.tint(AppTokens.primary, 0.15),
                              child: const Icon(Icons.restaurant_menu_rounded,
                                  color: AppTokens.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.detectedName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    guide?.category ?? 'Thực phẩm',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Sửa tên nếu nhận diện sai',
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppTokens.warning, size: 20),
                              onPressed: () => _editItemDialog(idx),
                            ),
                            IconButton(
                              tooltip: 'Xóa khỏi danh sách',
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.grey, size: 20),
                              onPressed: () =>
                                  setState(() => _items.removeAt(idx)),
                            ),
                          ],
                        ),
                        if (defaultMethod != null) ...[
                          const Divider(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '⏱ ${defaultMethod.storageZone}: ${defaultMethod.shelfLifeText}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTokens.primaryDark,
                                ),
                              ),
                              const Text(
                                'Xem cách bảo quản →',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTokens.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}