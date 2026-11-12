import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'manual_add_screen.dart';

class StorageDetailScreen extends StatefulWidget {
  final ApiService apiService;
  final String initialZone;
  final bool showBackButton;

  const StorageDetailScreen({
    super.key,
    required this.apiService,
    this.initialZone = 'Tất cả',
    this.showBackButton = true,
  });

  @override
  State<StorageDetailScreen> createState() => _StorageDetailScreenState();
}

class _StorageDetailScreenState extends State<StorageDetailScreen> {
  late String _selectedZone;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedZone = widget.initialZone;
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

        final items = widget.apiService
            .itemsByZone(_selectedZone)
            .where((e) =>
                e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: widget.showBackButton,
            title: Text('Kho lưu trữ (${items.length})'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Tìm tên món ăn trong kho...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: ['Tất cả', 'Ngăn mát', 'Ngăn đông', 'Tủ khô']
                      .map((zone) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(zone),
                        selected: _selectedZone == zone,
                        selectedColor: AppTokens.tint(AppTokens.primary, 0.2),
                        onSelected: (_) =>
                            setState(() => _selectedZone = zone),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: items.isEmpty
                    ? const Center(
                        child: Text('Không có thực phẩm nào trong ngăn này.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: items.length,
                        itemBuilder: (context, idx) {
                          final item = items[idx];
                          final badgeColor = item.daysLeft <= 1
                              ? AppTokens.danger
                              : (item.daysLeft <= 3
                                  ? AppTokens.warning
                                  : AppTokens.primary);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radiusMd),
                              border: Border.all(color: border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15.5)),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${item.quantityDisplay} • ${item.zone} • HSD: ${item.formattedDate}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTokens.tint(badgeColor, 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Còn ${item.daysLeft}d',
                                    style: TextStyle(
                                        color: badgeColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12),
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 20),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ManualAddScreen(
                                          apiService: widget.apiService,
                                          existingItem: item,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: AppTokens.primary),
                                  onPressed: () =>
                                      widget.apiService.consumeItem(item.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}