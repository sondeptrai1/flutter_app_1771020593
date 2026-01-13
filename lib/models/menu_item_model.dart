import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final List<String> ingredients;
  final bool isVegetarian;
  final bool isSpicy;
  final bool isAvailable;
  final double rating;
  final int preparationTime;
  final Timestamp createdAt;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.ingredients,
    required this.isVegetarian,
    required this.isSpicy,
    required this.isAvailable,
    required this.rating,
    required this.preparationTime,
    required this.createdAt,
  });

  factory MenuItemModel.fromMap(String id, Map<String, dynamic> map) {
    return MenuItemModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      isVegetarian: map['isVegetarian'] ?? false,
      isSpicy: map['isSpicy'] ?? false,
      isAvailable: map['isAvailable'] ?? true,
      rating: (map['rating'] ?? 0).toDouble(),
      preparationTime: map['preparationTime'] ?? 0,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'isVegetarian': isVegetarian,
      'isSpicy': isSpicy,
      'isAvailable': isAvailable,
      'rating': rating,
      'preparationTime': preparationTime,
      'createdAt': createdAt,
    };
  }
}
