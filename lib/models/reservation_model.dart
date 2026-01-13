import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String customerId;
  final Timestamp reservationDate;
  final int numberOfGuests;
  final String status;
  final String? tableNumber;
  final String? specialRequests;
  final List<Map<String, dynamic>> orderItems;
  final double subtotal;
  final double serviceCharge;
  final double discount;
  final double total;
  final String paymentStatus;
  final String? paymentMethod;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ReservationModel({
    required this.id,
    required this.customerId,
    required this.reservationDate,
    required this.numberOfGuests,
    required this.status,
    this.tableNumber,
    this.specialRequests,
    required this.orderItems,
    required this.subtotal,
    required this.serviceCharge,
    required this.discount,
    required this.total,
    required this.paymentStatus,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReservationModel.fromMap(String id, Map<String, dynamic> map) {
    return ReservationModel(
      id: id,
      customerId: map['customerId'],
      reservationDate: map['reservationDate'],
      numberOfGuests: map['numberOfGuests'],
      status: map['status'],
      tableNumber: map['tableNumber'],
      specialRequests: map['specialRequests'],
      orderItems: List<Map<String, dynamic>>.from(map['orderItems'] ?? []),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      serviceCharge: (map['serviceCharge'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      paymentStatus: map['paymentStatus'],
      paymentMethod: map['paymentMethod'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}
