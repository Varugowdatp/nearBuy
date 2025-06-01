class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> images;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.images,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      name: map['name'] ?? '',
      price: (map['price'] as num).toDouble(),
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
    );
  }
}
