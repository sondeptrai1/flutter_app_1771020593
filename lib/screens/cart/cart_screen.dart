import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../repositories/reservation_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? reservationId;
  Map<String, dynamic>? reservationData;
  bool loading = false;
  String paymentMethod = 'cash';

  Stream<QuerySnapshot<Map<String, dynamic>>>? _reservationQueryStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // Listen to the user's pending reservation (query snapshot). We'll pick the first doc if present.
    _reservationQueryStream = FirebaseFirestore.instance
        .collection('reservations')
        .where('customerId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>?>(
        stream: _reservationQueryStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data == null || snap.data!.docs.isEmpty) {
            return const Center(child: Text('Giỏ hàng trống'));
          }

          final doc = snap.data!.docs.first;
          final data = doc.data();
          final items = List.from(data['orderItems'] ?? []);
          reservationId = doc.id;
          paymentMethod = (data['paymentMethod'] as String?) ?? paymentMethod;

          double subtotal = (data['subtotal'] as num?)?.toDouble() ?? 0;
          double service =
              (data['serviceCharge'] as num?)?.toDouble() ?? subtotal * 0.1;
          double total =
              (data['total'] as num?)?.toDouble() ?? (subtotal + service);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (items.isEmpty) const Text('Giỏ hàng trống'),

                ...items.map((i) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(i['itemName']),
                      subtitle: Text('${i['price']} đ'),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () async {
                              final newQty = (i['quantity'] as int) - 1;
                              await ReservationRepository().updateItemQuantity(
                                reservationId!,
                                i['itemId'],
                                newQty,
                              );
                            },
                          ),
                          Text('${i['quantity']}'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () async {
                              final newQty = (i['quantity'] as int) + 1;
                              await ReservationRepository().updateItemQuantity(
                                reservationId!,
                                i['itemId'],
                                newQty,
                              );
                            },
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_forever),
                        onPressed: () async {
                          await ReservationRepository()
                              .removeItemFromReservation(
                                reservationId!,
                                i['itemId'],
                              );
                        },
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 12),
                Text('Tạm tính: ${subtotal.toStringAsFixed(0)} đ'),
                Text('Phí phục vụ (10%): ${service.toStringAsFixed(0)} đ'),
                const Divider(),
                Text(
                  'Tổng: ${total.toStringAsFixed(0)} đ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                          title: const Text('Tiền mặt'),
                          onChanged: (v) async {
                            setState(() => paymentMethod = v ?? 'cash');
                            if (reservationId != null) {
                              await FirebaseFirestore.instance
                                  .collection('reservations')
                                  .doc(reservationId)
                                  .update({'paymentMethod': paymentMethod});
                            }
                          },
                        ),
                        RadioListTile<String>(
                          value: 'card',
                          groupValue: paymentMethod,
                          title: const Text('Thẻ'),
                          onChanged: (v) async {
                            setState(() => paymentMethod = v ?? 'card');
                            if (reservationId != null) {
                              await FirebaseFirestore.instance
                                  .collection('reservations')
                                  .doc(reservationId)
                                  .update({'paymentMethod': paymentMethod});
                            }
                          },
                        ),
                        RadioListTile<String>(
                          value: 'online',
                          groupValue: paymentMethod,
                          title: const Text('Online'),
                          onChanged: (v) async {
                            setState(() => paymentMethod = v ?? 'online');
                            if (reservationId != null) {
                              await FirebaseFirestore.instance
                                  .collection('reservations')
                                  .doc(reservationId)
                                  .update({'paymentMethod': paymentMethod});
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Thanh toán'),
                    onPressed: loading || reservationId == null
                        ? null
                        : () async {
                            setState(() => loading = true);
                            try {
                              await ReservationRepository().payReservation(
                                reservationId!,
                                user.uid,
                                paymentMethod,
                              );
                            } finally {
                              if (!context.mounted) return;
                              setState(() => loading = false);
                              Navigator.pop(context);
                            }
                          },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
