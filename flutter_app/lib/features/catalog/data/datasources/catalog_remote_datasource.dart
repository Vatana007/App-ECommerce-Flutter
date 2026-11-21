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
    if (categoryId != null && categoryId != 'all') queryParams['category_id'] = categoryId;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (featured != null) queryParams['featured'] = featured;

    final response = await dio.get('/products', queryParameters: queryParams);

    final data = response.data;
    final List list = data['data'] ?? [];
    return list.map((json) => ProductDto.fromJson(json)).toList();
  }

  @override
  Future<ProductDto> fetchProductDetail(String id) async {
    final response = await dio.get('/products/$id');
    return ProductDto.fromJson(response.data['data']);
  }

  @override
  Future<List<Category>> fetchCategories() async {
    final response = await dio.get('/categories');
    final List list = response.data['data'] ?? [];
    return list.map((json) => Category.fromJson(json)).toList();
  }
}
