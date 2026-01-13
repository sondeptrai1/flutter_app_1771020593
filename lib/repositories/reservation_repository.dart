import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /* =====================================================
   * 1️⃣ ĐẶT BÀN
   * ===================================================== */
  Future<void> createReservation(
    String customerId,
    Timestamp reservationDate,
    int numberOfGuests,
    String? specialRequests, {
    String? paymentMethod,
  }) async {
    await _db.collection('reservations').add({
      'customerId': customerId, // FirebaseAuth UID
      'reservationDate': reservationDate,
      'numberOfGuests': numberOfGuests,
      'tableNumber': null,
      'status': 'pending',
      'specialRequests': specialRequests,
      'orderItems': [],
      'subtotal': 0.0,
      'serviceCharge': 0.0,
      'discount': 0.0,
      'total': 0.0,
      'paymentMethod': paymentMethod,
      'paymentStatus': 'pending',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  /* =====================================================
   * 2️⃣ THÊM MÓN VÀO ĐƠN
   * ===================================================== */
  Future<void> addItemToReservation(
    String reservationId,
    String itemId,
    String itemName,
    int quantity,
    double price,
  ) async {
    final ref = _db.collection('reservations').doc(reservationId);
    final snap = await ref.get();

    if (!snap.exists) throw Exception('Reservation not found');
    final data = snap.data() as Map<String, dynamic>;

    final List items = List.from(data['orderItems'] ?? []);
    final index = items.indexWhere((i) => i['itemId'] == itemId);

    if (index >= 0) {
      items[index]['quantity'] += quantity;
      items[index]['subtotal'] = items[index]['quantity'] * price;
    } else {
      items.add({
        'itemId': itemId,
        'itemName': itemName,
        'quantity': quantity,
        'price': price,
        'subtotal': quantity * price,
      });
    }

    final double subtotal = items.fold(
      0.0,
      (s, i) => s + (i['subtotal'] as num),
    );
    final double serviceCharge = subtotal * 0.1;
    final double total = subtotal + serviceCharge;

    await ref.update({
      'orderItems': items,
      'subtotal': subtotal,
      'serviceCharge': serviceCharge,
      'total': total,
      'updatedAt': Timestamp.now(),
    });
  }

  // Update quantity for an existing item (if quantity <= 0 it will be removed)
  Future<void> updateItemQuantity(
    String reservationId,
    String itemId,
    int quantity,
  ) async {
    final ref = _db.collection('reservations').doc(reservationId);
    final snap = await ref.get();
    if (!snap.exists) throw Exception('Reservation not found');

    final data = snap.data() as Map<String, dynamic>;
    final List items = List.from(data['orderItems'] ?? []);
    final index = items.indexWhere((i) => i['itemId'] == itemId);

    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index]['quantity'] = quantity;
        items[index]['subtotal'] =
            (items[index]['quantity'] as num) * (items[index]['price'] as num);
      }
    }

    final double subtotal = items.fold(
      0.0,
      (s, i) => s + (i['subtotal'] as num),
    );
    final double serviceCharge = subtotal * 0.1;
    final double total = subtotal + serviceCharge;

    await ref.update({
      'orderItems': items,
      'subtotal': subtotal,
      'serviceCharge': serviceCharge,
      'total': total,
      'updatedAt': Timestamp.now(),
    });
  }

  // Remove an item from a reservation
  Future<void> removeItemFromReservation(
    String reservationId,
    String itemId,
  ) async {
    return updateItemQuantity(reservationId, itemId, 0);
  }

  /* =====================================================
   * 3️⃣ XÁC NHẬN ĐẶT BÀN
   * ===================================================== */
  Future<void> confirmReservation(
    String reservationId,
    String tableNumber,
  ) async {
    await _db.collection('reservations').doc(reservationId).update({
      'status': 'confirmed',
      'tableNumber': tableNumber,
      'updatedAt': Timestamp.now(),
    });
  }

  /* =====================================================
   * 4️⃣ THANH TOÁN + LOYALTY POINTS
   * ===================================================== */
  Future<void> payReservation(
    String reservationId,
    String customerId,
    String paymentMethod,
  ) async {
    final reservationRef = _db.collection('reservations').doc(reservationId);
    final customerRef = _db.collection('customers').doc(customerId);

    final reservationSnap = await reservationRef.get();
    final customerSnap = await customerRef.get();

    if (!reservationSnap.exists || !customerSnap.exists) {
      throw Exception('Reservation or Customer not found');
    }

    final resData = reservationSnap.data() as Map<String, dynamic>;
    final cusData = customerSnap.data() as Map<String, dynamic>;

    final double total = (resData['total'] as num? ?? 0).toDouble();
    final int loyaltyPoints = (cusData['loyaltyPoints'] as num? ?? 0).toInt();

    // 1 point = 1000đ, tối đa 50%
    final double maxDiscount = total * 0.5;
    final double discount = (loyaltyPoints * 1000)
        .clamp(0, maxDiscount)
        .toDouble();

    final double finalTotal = total - discount;
    final int earnedPoints = (finalTotal * 0.01).floor();

    await reservationRef.update({
      'paymentMethod': paymentMethod,
      'paymentStatus': 'paid',
      'status': 'completed',
      'discount': discount,
      'total': finalTotal,
      'updatedAt': Timestamp.now(),
    });

    await customerRef.update({
      'loyaltyPoints': loyaltyPoints - (discount ~/ 1000) + earnedPoints,
    });
  }

  /* =====================================================
   * 5️⃣ LẤY ĐẶT BÀN THEO KHÁCH (REALTIME)
   * ===================================================== */
  Stream<QuerySnapshot> getReservationsByCustomer(String customerId) {
    return _db
        .collection('reservations')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /* =====================================================
   * 6️⃣ LẤY ĐẶT BÀN THEO NGÀY
   * ===================================================== */
  Future<List<QueryDocumentSnapshot>> getReservationsByDate(
    DateTime date,
  ) async {
    final start = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    final end = Timestamp.fromDate(
      DateTime(date.year, date.month, date.day, 23, 59, 59),
    );

    final snap = await _db
        .collection('reservations')
        .where('reservationDate', isGreaterThanOrEqualTo: start)
        .where('reservationDate', isLessThanOrEqualTo: end)
        .get();

    return snap.docs;
  }
}
