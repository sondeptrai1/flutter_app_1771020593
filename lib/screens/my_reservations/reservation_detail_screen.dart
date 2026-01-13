import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../repositories/reservation_repository.dart';

class ReservationDetailScreen extends StatefulWidget {
  final String reservationId;
  final Map<String, dynamic> data;

  const ReservationDetailScreen({
    super.key,
    required this.reservationId,
    required this.data,
  });

  @override
  State<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  String paymentMethod = 'cash';
  bool loading = false;

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
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = List.from(widget.data['orderItems'] ?? []);
    final status = widget.data['status'] ?? 'pending';
    final paymentStatus = widget.data['paymentStatus'] ?? 'pending';

    final double subtotal = (widget.data['subtotal'] as num?)?.toDouble() ?? 0;
    final double service =
        (widget.data['serviceCharge'] as num?)?.toDouble() ?? 0;
    final double discount = (widget.data['discount'] as num?)?.toDouble() ?? 0;
    final double total = (widget.data['total'] as num?)?.toDouble() ?? 0;

    final bool canPay = paymentStatus != 'paid' && items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết đặt bàn'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== STATUS =====
            Row(
              children: [
                const Text(
                  'Trạng thái: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(status),
                  backgroundColor: _statusColor(status).withValues(alpha: 0.2),
                  labelStyle: TextStyle(color: _statusColor(status)),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(paymentStatus),
                  backgroundColor: paymentStatus == 'paid'
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                ),
              ],
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ngày: ${(widget.data['reservationDate'] as Timestamp).toDate()}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.data['tableNumber'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.table_bar,
                            color: Colors.blue,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text('Bàn ${widget.data['tableNumber']}'),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== ORDER ITEMS =====
            const Text(
              'Danh sách món đã đặt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            if (items.isEmpty) const Text('Chưa có món nào trong đơn'),

            ...items.map((i) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(i['itemName']),
                  subtitle: Text('${i['price']} đ'),
                  trailing: Text(
                    'x${i['quantity']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),

            const Divider(thickness: 1.2),

            // ===== BILL =====
            _buildRow('Tạm tính', subtotal),
            _buildRow('Phí phục vụ (10%)', service),
            _buildRow('Giảm giá (loyalty)', -discount),
            const Divider(thickness: 1.2),
            _buildRow('TỔNG CỘNG', total, bold: true),

            const SizedBox(height: 24),

            // ===== PAYMENT METHOD =====
            if (canPay) ...[
              const Text(
                'Phương thức thanh toán',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: paymentMethod,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Tiền mặt')),
                      DropdownMenuItem(value: 'card', child: Text('Thẻ')),
                      DropdownMenuItem(value: 'online', child: Text('Online')),
                    ],
                    onChanged: (v) => setState(() => paymentMethod = v!),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ===== PAY BUTTON =====
            if (canPay)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('XÁC NHẬN THANH TOÁN'),
                  onPressed: loading
                      ? null
                      : () async {
                          setState(() => loading = true);

                          await ReservationRepository().payReservation(
                            widget.reservationId,
                            FirebaseAuth.instance.currentUser!.uid,
                            paymentMethod,
                          );

                          if (!context.mounted) return;
                          Navigator.pop(context);
                        },
                ),
              ),

            // ===== PAID INFO =====
            if (paymentStatus == 'paid')
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Đơn hàng đã được thanh toán',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)} đ',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
