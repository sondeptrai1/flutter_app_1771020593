import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../repositories/reservation_repository.dart';
import 'reservation_detail_screen.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'seated':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Bạn chưa đăng nhập')),
      );
    }

    final repo = ReservationRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt bàn của tôi'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: repo.getReservationsByCustomer(user.uid),
        builder: (context, snapshot) {
          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Không có dữ liệu
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chưa có đặt bàn nào'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final status = data['status'] ?? 'pending';
              final statusColor = _statusColor(status);

              return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withValues(alpha: 0.15),
                      child: Icon(Icons.event_seat, color: statusColor),
                    ),
                  title: Text(
                    'Ngày: ${(data['reservationDate'] as Timestamp).toDate()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Số khách: ${data['numberOfGuests']}'),
                      Text(
                        'Trạng thái: $status',
                        style: TextStyle(color: statusColor),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_forward_ios, size: 14),
                      const SizedBox(height: 4),
                      Text(
                        '${data['total']} đ',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservationDetailScreen(
                          reservationId: doc.id,
                          data: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
