import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/menu_item_model.dart';
import '../../repositories/menu_item_repository.dart';

class AddEditMenuItemScreen extends StatefulWidget {
  final MenuItemModel? item;
  const AddEditMenuItemScreen({super.key, this.item});

  @override
  State<AddEditMenuItemScreen> createState() => _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends State<AddEditMenuItemScreen> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  final prepCtrl = TextEditingController();
  final ratingCtrl = TextEditingController();
  bool isSpicy = false;
  bool isAvailable = true;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      nameCtrl.text = widget.item!.name;
      priceCtrl.text = widget.item!.price.toString();
      imageCtrl.text = widget.item!.imageUrl;
      prepCtrl.text = widget.item!.preparationTime.toString();
      ratingCtrl.text = widget.item!.rating.toString();
      isSpicy = widget.item!.isSpicy;
      isAvailable = widget.item!.isAvailable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = MenuItemRepository();

    return Scaffold(
      appBar: AppBar(title: Text(widget.item == null ? 'Thêm món' : 'Sửa món')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PREVIEW IMAGE
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: imageCtrl.text.isEmpty
                  ? const Center(child: Text('Chưa có ảnh'))
                  : Image.network(
                      imageCtrl.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image)),
                    ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: imageCtrl,
              decoration: const InputDecoration(
                labelText: 'URL hình ảnh',
                prefixIcon: Icon(Icons.image),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên món',
                prefixIcon: Icon(Icons.restaurant),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(
                labelText: 'Giá',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: prepCtrl,
              decoration: const InputDecoration(
                labelText: 'Thời gian chế biến (phút)',
                prefixIcon: Icon(Icons.timer),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ratingCtrl,
              decoration: const InputDecoration(
                labelText: 'Đánh giá (0.0 - 5.0)',
                prefixIcon: Icon(Icons.star),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('Món cay'),
                  ],
                ),
                Switch(
                  value: isSpicy,
                  onChanged: (v) => setState(() => isSpicy = v),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Còn phục vụ'),
                Switch(
                  value: isAvailable,
                  onChanged: (v) => setState(() => isAvailable = v),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                child: const Text('Lưu món'),
                onPressed: () async {
                  if (widget.item == null) {
                    final newItem = MenuItemModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text,
                      description: '',
                      category: 'Main',
                      price: double.tryParse(priceCtrl.text) ?? 0,
                      imageUrl: imageCtrl.text.isEmpty
                          ? 'https://via.placeholder.com/300'
                          : imageCtrl.text,
                      ingredients: const [],
                      isVegetarian: false,
                      isSpicy: isSpicy,
                      isAvailable: isAvailable,
                      rating: double.tryParse(ratingCtrl.text) ?? 4.0,
                      preparationTime: int.tryParse(prepCtrl.text) ?? 10,
                      createdAt: Timestamp.now(),
                    );
                    await repo.addMenuItem(newItem);
                  } else {
                    await repo.updateMenuItem(widget.item!.id, {
                      'name': nameCtrl.text,
                      'price': double.tryParse(priceCtrl.text) ?? 0,
                      'imageUrl': imageCtrl.text,
                      'preparationTime':
                          int.tryParse(prepCtrl.text) ??
                          widget.item!.preparationTime,
                      'rating':
                          double.tryParse(ratingCtrl.text) ??
                          widget.item!.rating,
                      'isSpicy': isSpicy,
                      'isAvailable': isAvailable,
                    });
                  }

                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
