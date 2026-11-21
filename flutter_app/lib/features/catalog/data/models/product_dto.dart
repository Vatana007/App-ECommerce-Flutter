import '../../domain/entities/product.dart';

class ProductDto {
  final String id;
  final String name;
  final String nameKm;
  final String nameEn;
  final String description;
  final String descKm;
  final String descEn;
  final double price;
  final int stock;
  final List<String> images;
  final String categoryId;
  final String spiceLevel;
  final bool isFeatured;
  final double rating;
  final int reviewCount;

  ProductDto({
    required this.id,
    required this.name,
    required this.nameKm,
    required this.nameEn,
    required this.description,
    required this.descKm,
    required this.descEn,
    required this.price,
    required this.stock,
    required this.images,
    required this.categoryId,
    required this.spiceLevel,
    required this.isFeatured,
    required this.rating,
    required this.reviewCount,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameKm: json['name_km']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      description: json['description']?.toString() ?? json['desc_km']?.toString() ?? '',
      descKm: json['desc_km']?.toString() ?? '',
      descEn: json['desc_en']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 50,
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['image'] != null ? [json['image'].toString()] : []),
      categoryId: json['category_id']?.toString() ?? '',
      spiceLevel: json['spice_level']?.toString() ?? 'mild',
      isFeatured: json['featured'] == true,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 15,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_km': nameKm,
        'name_en': nameEn,
        'description': description,
        'desc_km': descKm,
        'desc_en': descEn,
        'price': price,
        'stock': stock,
        'images': images,
        'category_id': categoryId,
        'spice_level': spiceLevel,
        'featured': isFeatured,
        'rating': rating,
        'review_count': reviewCount,
      };

  Product toEntity() => Product(
        id: id,
        name: name,
        nameKm: nameKm,
        nameEn: nameEn,
        description: description,
        descKm: descKm,
        descEn: descEn,
        price: price,
        stock: stock,
        images: images,
        categoryId: categoryId,
        spiceLevel: spiceLevel,
        isFeatured: isFeatured,
        rating: rating,
        reviewCount: reviewCount,
      );
}
