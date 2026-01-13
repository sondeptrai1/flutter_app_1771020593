import 'package:flutter/material.dart';
import 'package:flutter_app_1771020440/models/menu_item_model.dart';

class OrderItemsWidget extends StatelessWidget {
  /// items = [{ 'item': MenuItemModel, 'qty': int }]
  final List<Map<String, dynamic>> items;

  const OrderItemsWidget({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    double subtotal = items.fold(0.0, (sum, item) {
      final MenuItemModel menuItem = item['item'] as MenuItemModel;
      final int qty = item['qty'] as int;
      return sum + (menuItem.price * qty);
    });

    double serviceCharge = subtotal * 0.1;
    double total = subtotal + serviceCharge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.map((item) {
          final MenuItemModel menuItem = item['item'] as MenuItemModel;
          final int qty = item['qty'] as int;

          return ListTile(
            title: Text(menuItem.name),
            subtitle: Text(
              '${menuItem.price.toStringAsFixed(0)} đ',
            ),
            trailing: Text('x$qty'),
          );
        }),
        const Divider(),
        Text('Subtotal: ${subtotal.toStringAsFixed(0)} đ'),
        Text('Service (10%): ${serviceCharge.toStringAsFixed(0)} đ'),
        Text(
          'Total: ${total.toStringAsFixed(0)} đ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
