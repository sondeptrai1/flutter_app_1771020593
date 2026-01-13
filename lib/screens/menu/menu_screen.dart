import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../repositories/reservation_repository.dart';
import 'package:flutter_app_1771020440/screens/cart/cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String keyword = '';
  bool vegetarianOnly = false;
  bool spicyOnly = false;

  final repo = ReservationRepository();

  Future<void> _addToOrder(
    BuildContext context,
    String itemId,
    String name,
    double price,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 👉 Lấy hoặc tạo reservation pending
    final snap = await FirebaseFirestore.instance
        .collection('reservations')
        .where('customerId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    String reservationId;
    if (snap.docs.isNotEmpty) {
      reservationId = snap.docs.first.id;
    } else {
      final doc = await FirebaseFirestore.instance
          .collection('reservations')
          .add({
            'customerId': uid,
            'reservationDate': Timestamp.now(),
            'numberOfGuests': 1,
            'tableNumber': null,
            'status': 'pending',
            'specialRequests': '',
            'orderItems': [],
            'subtotal': 0.0,
            'serviceCharge': 0.0,
            'discount': 0.0,
            'total': 0.0,
            'paymentMethod': 'cash',
            'paymentStatus': 'pending',
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
      reservationId = doc.id;
    }

    await repo.addItemToReservation(reservationId, itemId, name, 1, price);

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã thêm $name vào đơn')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Tìm món ăn...',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => keyword = v),
            ),
          ),

          // 🧩 FILTER
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterChip(
                label: const Text('Chay'),
                selected: vegetarianOnly,
                onSelected: (v) => setState(() => vegetarianOnly = v),
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: const Text('Cay'),
                selected: spicyOnly,
                onSelected: (v) => setState(() => spicyOnly = v),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 📋 MENU LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('menu_items')
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs.where((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final name = d['name'].toString().toLowerCase();

                  if (keyword.isNotEmpty &&
                      !name.contains(keyword.toLowerCase())) {
                    return false;
                  }
                  if (vegetarianOnly && d['isVegetarian'] != true) {
                    return false;
                  }
                  if (spicyOnly && d['isSpicy'] != true) {
                    return false;
                  }
                  return true;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('Không có món phù hợp'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final d = doc.data() as Map<String, dynamic>;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      d['imageUrl'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                                child: Icon(
                                                  Icons.fastfood,
                                                  size: 60,
                                                ),
                                              ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade600,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            ((d['rating'] as num?) ?? 0)
                                                .toStringAsFixed(1),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          d['name'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          d['category'] ?? '',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        '${(d['price'] as num).toDouble()} đ',
                                        style: const TextStyle(
                                          color: Colors.deepOrange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.schedule, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${d['preparationTime']} phút',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      if (d['isVegetarian'] == true)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.eco,
                                                size: 14,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Chay',
                                                style: TextStyle(fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (d['isSpicy'] == true)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(
                                                  Icons.local_fire_department,
                                                  size: 14,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Cay',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 40,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            d['isAvailable'] == true
                                            ? Colors.orange
                                            : Colors.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed: d['isAvailable'] == true
                                          ? () => _addToOrder(
                                              context,
                                              doc.id,
                                              d['name'],
                                              (d['price'] as num).toDouble(),
                                            )
                                          : null,
                                      child: Text(
                                        d['isAvailable'] == true
                                            ? 'Thêm vào đơn'
                                            : 'Hết món',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
