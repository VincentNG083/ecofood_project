import 'package:flutter/material.dart';
import '../main.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';
import '../services/food_classifier_service.dart';

class ManualAddScreen extends StatefulWidget {
  final ApiService apiService;
  final FoodItem? existingItem;

  const ManualAddScreen({
    super.key,
    required this.apiService,
    this.existingItem,
  });

  @override
  State<ManualAddScreen> createState() => _ManualAddScreenState();
}

class _ManualAddScreenState extends State<ManualAddScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _qtyCtrl;
  String _unit = 'g';
  String _zone = 'Ngăn mát';
  bool _userPickedZone = false;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _qtyCtrl = TextEditingController(
        text: item != null ? item.quantity.toInt().toString() : '300');
    _unit = item?.unit ?? 'g';
    _zone = item?.zone ?? 'Ngăn mát';
    _userPickedZone = item != null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  String get _autoCategory =>
      FoodClassifierService.classifyCategory(_nameCtrl.text.trim());

  int get _autoShelfLifeDays => FoodClassifierService.calculateShelfLifeDays(
        category: _autoCategory,
        zone: _zone,
      );

  DateTime get _autoExpiryDate => FoodClassifierService.calculateExpiryDate(
        category: _autoCategory,
        zone: _zone,
      );

  void _onNameChanged(String value) {
    setState(() {
      if (!_userPickedZone && value.trim().isNotEmpty) {
        _zone = FoodClassifierService.suggestDefaultZone(value, _autoCategory);
      }
    });
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) return;
    final item = FoodItem(
      id: widget.existingItem?.id ??
          'f_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      category: _autoCategory,
      quantity: double.tryParse(_qtyCtrl.text) ?? 1,
      unit: _unit,
      expiryDate: _autoExpiryDate,
      zone: _zone,
    );
    widget.apiService.saveItem(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final exp = _autoExpiryDate;
    final formattedExp =
        '${exp.day.toString().padLeft(2, '0')}/${exp.month.toString().padLeft(2, '0')}/${exp.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingItem == null
            ? 'Nhập thực phẩm'
            : 'Chỉnh sửa thực phẩm'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              onChanged: _onNameChanged,
              decoration: const InputDecoration(
                labelText: 'Tên thực phẩm (VD: Thịt bò, Rau cải, Sữa tươi...)',
                prefixIcon: Icon(Icons.fastfood_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Số lượng'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _unit,
                    decoration: const InputDecoration(labelText: 'Đơn vị'),
                    items: ['g', 'kg', 'bó', 'quả', 'hộp', 'gói', 'phần']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) => setState(() => _unit = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Chọn ngăn lưu trữ:',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: ['Ngăn mát', 'Ngăn đông', 'Tủ khô'].map((z) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(z),
                      selected: _zone == z,
                      onSelected: (_) => setState(() {
                        _zone = z;
                        _userPickedZone = true;
                      }),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Thẻ hiển thị kết quả hệ thống tự động phân loại & tính HSD theo giờ máy
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTokens.tint(AppTokens.primary, 0.12),
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(color: AppTokens.tint(AppTokens.primary, 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: AppTokens.primary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Hệ thống tự động phân loại & tính HSD',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTokens.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('• Nhóm phân loại tự động: $_autoCategory'),
                  Text(
                      '• Thời gian bảo quản tại $_zone: +$_autoShelfLifeDays ngày'),
                  Text(
                    '• Hạn sử dụng dự kiến (theo giờ máy): $formattedExp',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                ),
                onPressed: _save,
                child: const Text('Lưu vào kho',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}