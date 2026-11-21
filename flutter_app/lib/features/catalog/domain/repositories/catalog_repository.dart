import '../entities/category.dart';
import '../entities/product.dart';

abstract class CatalogRepository {
  Future<List<Product>> getProducts({
    int limit = 50,
    String? cursor,
    String? categoryId,
    String? search,
    bool? featured,
  });

  Future<Product> getProductDetail(String id);

  Future<List<Category>> getCategories();
}
