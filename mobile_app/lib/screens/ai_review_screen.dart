import 'package:flutter/material.dart';
import '../main.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';
import '../services/food_classifier_service.dart';

class AiReviewScreen extends StatefulWidget {
  final ApiService apiService;
  final String sourceLabel;
  final List<DraftFoodItem> draftItems;

  const AiReviewScreen({
    super.key,
    required this.apiService,
    required this.sourceLabel,
    required this.draftItems,
  });

  @override
  State<AiReviewScreen> createState() => _AiReviewScreenState();
}

class _AiReviewScreenState extends State<AiReviewScreen> {
  void _confirmAndSave() {
    final chosen = widget.draftItems
        .where((e) => e.selected)
        .map((e) => e.toFoodItem())
        .toList();
    if (chosen.isEmpty) return;

    widget.apiService.addMultipleItems(chosen);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lưu ${chosen.length} thực phẩm vào kho!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTokens.darkSurface : AppTokens.lightSurface;
    final border = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;
    final selectedCount = widget.draftItems.where((e) => e.selected).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm tra & Xác nhận')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTokens.tint(AppTokens.primary, 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.sourceLabel}: Hệ thống đã tự động phân loại nhóm và tính HSD theo ngăn lưu trữ & đồng hồ máy.',
                style: const TextStyle(fontSize: 12.5),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: widget.draftItems.isEmpty
                  ? const Center(
                      child: Text('Không nhận diện được thực phẩm nào.'))
                  : ListView.builder(
                      itemCount: widget.draftItems.length,
                      itemBuilder: (context, idx) {
                        final item = widget.draftItems[idx];
                        final expDate =
                            FoodClassifierService.calculateExpiryDate(
                          category: item.category,
                          zone: item.zone,
                        );
                        final expText =
                            '${expDate.day.toString().padLeft(2, '0')}/${expDate.month.toString().padLeft(2, '0')}/${expDate.year}';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusMd),
                            border: Border.all(
                              color: item.selected ? AppTokens.primary : border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    activeColor: AppTokens.primary,
                                    value: item.selected,
                                    onChanged: (v) => setState(
                                        () => item.selected = v ?? false),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15)),
                                        Text('Phân loại: ${item.category}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${item.qty % 1 == 0 ? item.qty.toInt() : item.qty} ${item.unit}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppTokens.primary),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  DropdownButton<String>(
                                    value: item.zone,
                                    underline: const SizedBox.shrink(),
                                    items: ['Ngăn mát', 'Ngăn đông', 'Tủ khô']
                                        .map((z) => DropdownMenuItem(
                                            value: z, child: Text(z)))
                                        .toList(),
                                    onChanged: (newZone) {
                                      if (newZone == null) return;
                                      setState(() {
                                        item.zone = newZone;
                                        item.days = FoodClassifierService
                                            .calculateShelfLifeDays(
                                          category: item.category,
                                          zone: newZone,
                                        );
                                      });
                                    },
                                  ),
                                  Text(
                                    'HSD: $expText (+${item.days}d)',
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppTokens.primaryDark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
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
                onPressed: selectedCount == 0 ? null : _confirmAndSave,
                icon: const Icon(Icons.check_circle_rounded),
                label: Text(
                  'Xác nhận lưu ($selectedCount món)',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}