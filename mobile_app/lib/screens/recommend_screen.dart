import 'package:flutter/material.dart';
import '../main.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';

class RecommendScreen extends StatelessWidget {
  final ApiService apiService;

  const RecommendScreen({super.key, required this.apiService});

  static const List<RecipeItem> _recipes = [
    RecipeItem(
      id: 'r1',
      title: 'Thịt ba chỉ rang cháy cạnh & Rau muống luộc',
      description: 'Mâm cơm giải cứu nguyên liệu sắp hết hạn trong 15 phút.',
      cookTime: '15 phút',
      difficulty: 'Dễ',
      requiredIngredients: ['Thịt ba chỉ', 'Rau muống'],
      pantryStaples: ['Nước mắm', 'Hành tím', 'Tỏi'],
      steps: [
        'Nhặt sạch rau muống, luộc sôi 3 phút với chút muối rồi vớt ra.',
        'Thái mỏng thịt ba chỉ, rang lửa vừa đến khi xém vàng hai mặt.',
        'Phi thơm hành tím, nêm nước mắm và đường đảo đều 2 phút.',
      ],
    ),
    RecipeItem(
      id: 'r2',
      title: 'Trứng chiên cà chua bi & Sữa tươi ấm',
      description: 'Bữa sáng nhanh gọn tận dụng thực phẩm ngăn mát.',
      cookTime: '10 phút',
      difficulty: 'Rất dễ',
      requiredIngredients: ['Trứng gà ta', 'Cà chua bi'],
      pantryStaples: ['Hành lá', 'Hạt nêm'],
      steps: [
        'Bổ đôi cà chua bi, đánh tan 3 quả trứng gà với chút hạt nêm.',
        'Xào sơ cà chua bi cho mềm rồi đổ trứng vào chiên chín vàng.',
      ],
    ),
  ];

  void _showSteps(BuildContext context, RecipeItem recipe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...recipe.steps.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Bước ${e.key + 1}: ${e.value}'),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: apiService,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface =
            isDark ? AppTokens.darkSurface : AppTokens.lightSurface;
        final border = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;
        final fridgeNames =
            apiService.items.map((e) => e.name.toLowerCase()).toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Gợi ý món ăn')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: _recipes.map((recipe) {
              final matched = recipe.requiredIngredients
                  .where((req) =>
                      fridgeNames.any((f) => f.contains(req.toLowerCase())))
                  .toList();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⏱ ${recipe.cookTime} • Khớp ${matched.length}/${recipe.requiredIngredients.length} nguyên liệu có sẵn',
                      style: const TextStyle(
                        color: AppTokens.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(recipe.title,
                        style: const TextStyle(
                            fontSize: 16.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(recipe.description,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showSteps(context, recipe),
                            child: const Text('Xem cách làm'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTokens.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              apiService.consumeMatchingIngredients(matched);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Đã nấu xong & trừ nguyên liệu khỏi kho!')),
                              );
                            },
                            child: const Text('Nấu & Trừ kho'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}