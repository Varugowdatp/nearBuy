class ShopModel {
  final String id;
  final String shopName;
  final String ownerName;
  final String address;
  final String mobile;
  final String image;

  ShopModel({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.address,
    required this.mobile,
    required this.image,
  });

  factory ShopModel.fromMap(Map<String, dynamic> map, String docId) {
    return ShopModel(
      id: docId,
      shopName: map['shopName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      address: map['address'] ?? '',
      mobile: map['mobile'] ?? '',
      image: map['image'] ?? '',
    );
  }
}
