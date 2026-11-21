import '../../../../core/config/app_config.dart';

class Product {
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

  const Product({
    required this.id,
    required this.name,
    this.nameKm = '',
    this.nameEn = '',
    required this.description,
    this.descKm = '',
    this.descEn = '',
    required this.price,
    required this.stock,
    required this.images,
    required this.categoryId,
    this.spiceLevel = 'mild',
    this.isFeatured = false,
    this.rating = 5.0,
    this.reviewCount = 0,
  });

  bool get isOutOfStock => stock <= 0;

  String get displayName => nameKm.isNotEmpty ? nameKm : name;
  String get displaySubtitle => nameEn.isNotEmpty ? nameEn : '';

  String get primaryImage {
    if (images.isNotEmpty && images.first.isNotEmpty) {
      final img = images.first;
      if (img.startsWith('http://') || img.startsWith('https://')) {
        return img;
      }
      final baseUrl = AppConfig.instance.apiBaseUrl.replaceAll('/api/v1', '');
      return '$baseUrl$img';
    }
    return 'https://placehold.co/400x400.png?text=Phum+Yeung+Food';
  }
}
