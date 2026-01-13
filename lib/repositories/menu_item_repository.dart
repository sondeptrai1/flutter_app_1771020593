import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';
import '../services/firebase_service.dart';

class MenuItemRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseService.firestore.collection('menu_items');

  // CREATE
  Future<void> addMenuItem(MenuItemModel item) async {
    await _col.doc(item.id).set(item.toMap());
  }

  // READ (Realtime)
  Stream<List<MenuItemModel>> getAllMenuItems() {
    return _col.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => MenuItemModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // UPDATE
  Future<void> updateMenuItem(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  // DELETE
  Future<void> deleteMenuItem(String id) async {
    await _col.doc(id).delete();
  }
}
