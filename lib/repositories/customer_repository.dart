import '../models/customer_model.dart';
import '../services/firebase_service.dart';

class CustomerRepository {
  final _collection =
      FirebaseService.firestore.collection('customers');

  Future<void> addCustomer(CustomerModel customer) async {
    await _collection.doc(customer.id).set(customer.toMap());
  }

  Future<CustomerModel?> getCustomerById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return CustomerModel.fromMap(doc.id, doc.data()!);
  }

  Future<List<CustomerModel>> getAllCustomers() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((d) => CustomerModel.fromMap(d.id, d.data()))
        .toList();
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _collection.doc(customer.id).update(customer.toMap());
  }

  Future<void> updateLoyaltyPoints(String customerId, int points) async {
    await _collection.doc(customerId).update({
      'loyaltyPoints': points,
    });
  }
}
