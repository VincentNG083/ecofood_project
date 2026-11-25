import 'package:flutter/material.dart';
import '../main.dart';
import '../models/food_guide.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodGuide food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late int _selectedMethodIndex;

  @override
  void initState() {
    super.initState();
    final defaultIdx = widget.food.methods.indexWhere((m) => m.isDefault);
    _selectedMethodIndex = defaultIdx >= 0 ? defaultIdx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTokens.darkSurface : AppTokens.lightSurface;
    final border = isDark ? AppTokens.darkBorder : AppTokens.lightBorder;
    final subtext = isDark ? AppTokens.darkSubtext : AppTokens.lightSubtext;

    final hasMethods = widget.food.methods.isNotEmpty;
    final activeMethod =
        hasMethods ? widget.food.methods[_selectedMethodIndex] : null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.food.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (widget.food.thumbnailUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              child: SizedBox(
                height: 185,
                width: double.infinity,
                child: Image.network(
                  widget.food.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTokens.tint(AppTokens.primary, 0.15),
                    child: const Icon(Icons.restaurant_rounded,
                        size: 56, color: AppTokens.primary),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.food.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTokens.tint(AppTokens.primary, 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.food.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: AppTokens.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          if (widget.food.aliases != null &&
              widget.food.aliases!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Tên gọi khác: ${widget.food.aliases}',
              style: TextStyle(fontSize: 13, color: subtext),
            ),
          ],
          const SizedBox(height: 20),

          // CHỌN HÌNH THỨC BẢO QUẢN KHÁC (Ngăn mát / Ngăn đông...)
          if (widget.food.methods.length > 1) ...[
            const Text(
              'Chọn hình thức bảo quản:',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.food.methods.asMap().entries.map((entry) {
                final idx = entry.key;
                final m = entry.value;
                final selected = idx == _selectedMethodIndex;
                return ChoiceChip(
                  label: Text(m.methodLabel),
                  selected: selected,
                  selectedColor: AppTokens.primary,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : null,
                  ),
                  onSelected: (_) =>
                      setState(() => _selectedMethodIndex = idx),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
          ],

          // THÔNG TIN SỐ NGÀY BẢO QUẢN & MÔI TRƯỜNG LƯU TRỮ
          if (activeMethod != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTokens.tint(AppTokens.secondary, 0.14),
                    AppTokens.tint(AppTokens.primary, 0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border:
                    Border.all(color: AppTokens.tint(AppTokens.secondary, 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTokens.secondary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.timer_outlined,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'THỜI GIAN BẢO QUẢN TỐI ĐA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppTokens.secondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeMethod.shelfLifeText,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Vị trí: ${activeMethod.storageZone}',
                          style: TextStyle(fontSize: 13, color: subtext),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // CÁC BƯỚC HƯỚNG DẪN BẢO QUẢN KÈM HÌNH ẢNH / VIDEO
          const Text(
            '📋 Các bước thực hiện bảo quản',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (activeMethod == null || activeMethod.steps.isEmpty)
            const Text('Chưa có bước hướng dẫn chi tiết cho phương pháp này.')
          else
            ...activeMethod.steps.map(
              (step) => _buildStepCard(step, surface, border),
            ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
      PreservationStep step, Color surface, Color border) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTokens.primary,
                child: Text(
                  '${step.stepNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Bước ${step.stepNumber}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppTokens.primaryDark),
              ),
              const Spacer(),
              if (step.videoUrl != null && step.videoUrl!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTokens.tint(AppTokens.danger, 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.play_circle_fill_rounded,
                          size: 15, color: AppTokens.danger),
                      SizedBox(width: 4),
                      Text(
                        'Có video',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTokens.danger),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            step.instruction,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          if (step.imageUrl != null && step.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                step.imageUrl!,
                height: 165,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}