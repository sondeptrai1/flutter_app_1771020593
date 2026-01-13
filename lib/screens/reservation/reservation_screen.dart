import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app_1771020440/models/menu_item_model.dart';
import 'package:flutter_app_1771020440/repositories/reservation_repository.dart';
import 'order_items_widget.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  DateTime? date;
  TimeOfDay? time;
  int guests = 1;
  final noteCtrl = TextEditingController();
  String paymentMethod = 'cash';

  List<Map<String, dynamic>> orderItems = [];

  void addItem(MenuItemModel item) {
    final index = orderItems.indexWhere((e) => e['item'].id == item.id);
    setState(() {
      if (index >= 0) {
        orderItems[index]['qty']++;
      } else {
        orderItems.add({'item': item, 'qty': 1});
      }
    });
  }

  void increase(int i) => setState(() => orderItems[i]['qty']++);
  void decrease(int i) => setState(() {
    if (orderItems[i]['qty'] > 1) {
      orderItems[i]['qty']--;
    }
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt bàn')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(
                date == null ? 'Chọn ngày' : date!.toString().split(' ')[0],
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                setState(() {});
              },
            ),
            ListTile(
              title: Text(time == null ? 'Chọn giờ' : time!.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                setState(() {});
              },
            ),
            Row(
              children: [
                const Text('Số khách'),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: guests > 1
                            ? () => setState(() => guests--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text('$guests'),
                      IconButton(
                        onPressed: () => setState(() => guests++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Yêu cầu đặc biệt'),
            ),
            const SizedBox(height: 16),

            // Payment method selection
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phương thức thanh toán',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    RadioListTile<String>(
                      value: 'cash',
                      groupValue: paymentMethod,
                      title: const Text('Tiền mặt (cash)'),
                      onChanged: (v) =>
                          setState(() => paymentMethod = v ?? 'cash'),
                    ),
                    RadioListTile<String>(
                      value: 'card',
                      groupValue: paymentMethod,
                      title: const Text('Thẻ (card)'),
                      onChanged: (v) =>
                          setState(() => paymentMethod = v ?? 'card'),
                    ),
                    RadioListTile<String>(
                      value: 'online',
                      groupValue: paymentMethod,
                      title: const Text('Trực tuyến (online)'),
                      onChanged: (v) =>
                          setState(() => paymentMethod = v ?? 'online'),
                    ),
                  ],
                ),
              ),
            ),

            // ORDER ITEMS
            OrderItemsWidget(items: orderItems),

            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text('Xác nhận đặt bàn'),
              onPressed: () async {
                if (date == null || time == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn ngày và giờ')),
                  );
                  return;
                }
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng đăng nhập')),
                  );
                  return;
                }
                final dt = DateTime(
                  date!.year,
                  date!.month,
                  date!.day,
                  time!.hour,
                  time!.minute,
                );

                await ReservationRepository().createReservation(
                  FirebaseAuth.instance.currentUser!.uid,
                  Timestamp.fromDate(dt),
                  guests,
                  noteCtrl.text,
                  paymentMethod: paymentMethod,
                );

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đặt bàn thành công')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
