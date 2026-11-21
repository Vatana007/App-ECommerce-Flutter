class Category {
  final String id;
  final String nameKm;
  final String nameEn;
  final String? icon;
  final int productsCount;

  const Category({
    required this.id,
    required this.nameKm,
    required this.nameEn,
    this.icon,
    this.productsCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      nameKm: json['name_km']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      icon: json['icon']?.toString(),
      productsCount: (json['products_count'] as num?)?.toInt() ?? 0,
    );
  }
}
