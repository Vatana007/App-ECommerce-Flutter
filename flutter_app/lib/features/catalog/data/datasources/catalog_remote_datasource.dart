import 'package:dio/dio.dart';
import '../../domain/entities/category.dart';
import '../models/product_dto.dart';

abstract class CatalogRemoteDataSource {
  Future<List<ProductDto>> fetchProducts({
    int limit = 50,
    String? cursor,
    String? categoryId,
    String? search,
    bool? featured,
  });

  Future<ProductDto> fetchProductDetail(String id);

  Future<List<Category>> fetchCategories();
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final Dio dio;

  CatalogRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ProductDto>> fetchProducts({
    int limit = 50,
    String? cursor,
    String? categoryId,
    String? search,
    bool? featured,
  }) async {
    final Map<String, dynamic> queryParams = {'limit': limit};
    if (cursor != null) queryParams['cursor'] = cursor;
    if (categoryId != null && categoryId != 'all') {
      queryParams['category_id'] = categoryId;
      queryParams['category'] = categoryId;
    }
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (featured != null) queryParams['featured'] = featured;

    try {
      final response = await dio.get('/products', queryParameters: queryParams);
      final data = response.data;
      final List list = data['data'] ?? [];
      if (list.isNotEmpty) {
        return list.map((json) => ProductDto.fromJson(json)).toList();
      }
    } catch (_) {}

    // Fallback to /dishes (compatible with hosted Render cloud backend)
    try {
      final response = await dio.get('/dishes', queryParameters: queryParams);
      final data = response.data;
      final List list = data['data'] ?? [];
      return list.map((json) => ProductDto.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<ProductDto> fetchProductDetail(String id) async {
    try {
      final response = await dio.get('/products/$id');
      return ProductDto.fromJson(response.data['data']);
    } catch (_) {
      final response = await dio.get('/dishes/$id');
      return ProductDto.fromJson(response.data['data']);
    }
  }

  @override
  Future<List<Category>> fetchCategories() async {
    final response = await dio.get('/categories');
    final List list = response.data['data'] ?? [];
    return list.map((json) => Category.fromJson(json)).toList();
  }
}
