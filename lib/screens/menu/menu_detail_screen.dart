import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';

class MenuDetailScreen extends StatefulWidget {
  final MenuItemModel item;
  const MenuDetailScreen({super.key, required this.item});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  int qty = 1;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.imageUrl,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (item.isSpicy)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.red,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text('Cay', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.isAvailable
                        ? Colors.green.shade50
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.isAvailable ? 'Còn phục vụ' : 'Tạm hết',
                    style: TextStyle(
                      color: item.isAvailable ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 16),
                    const SizedBox(width: 4),
                    Text('${item.preparationTime} phút'),
                  ],
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(item.rating.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              'Nguyên liệu:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...item.ingredients.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('- $e'),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => qty = qty > 1 ? qty - 1 : 1),
                  icon: const Icon(Icons.remove),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text('$qty', style: const TextStyle(fontSize: 16)),
                ),
                IconButton(
                  onPressed: () => setState(() => qty++),
                  icon: const Icon(Icons.add),
                ),
                const Spacer(),
                Text(
                  '${item.price.toStringAsFixed(0)} đ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: item.isAvailable
                    ? () {
                        Navigator.pop(context, {'item': item, 'qty': qty});
                      }
                    : null,
                child: const Text('Thêm vào đơn'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
