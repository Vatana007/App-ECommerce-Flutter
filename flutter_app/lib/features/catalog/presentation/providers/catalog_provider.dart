import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'package:flutter_app/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:flutter_app/features/catalog/domain/entities/category.dart';
import 'package:flutter_app/features/catalog/domain/entities/product.dart';
import 'package:flutter_app/features/catalog/domain/repositories/catalog_repository.dart';

final catalogRemoteDataSourceProvider = Provider<CatalogRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return CatalogRemoteDataSourceImpl(dio);
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final remoteDataSource = ref.watch(catalogRemoteDataSourceProvider);
  return CatalogRepositoryImpl(remoteDataSource);
});

// Categories list provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getCategories();
});

// Search query notifier
class ProductSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final productSearchQueryProvider =
    NotifierProvider<ProductSearchNotifier, String>(ProductSearchNotifier.new);

// Category filter notifier (default: 'all')
class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void select(String categoryId) => state = categoryId;
}

final selectedCategoryIdProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(SelectedCategoryNotifier.new);

// Products list provider that auto-refreshes when search or category changes
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(catalogRepositoryProvider);
  final search = ref.watch(productSearchQueryProvider);
  final categoryId = ref.watch(selectedCategoryIdProvider);

  return repository.getProducts(
    search: search.isEmpty ? null : search,
    categoryId: categoryId == 'all' ? null : categoryId,
  );
});

// Featured chef specials provider
final featuredDishesProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getProducts(featured: true, limit: 10);
});

// Product detail provider by ID
final productDetailProvider =
    FutureProvider.family<Product, String>((ref, productId) async {
  final repository = ref.watch(catalogRepositoryProvider);
  return repository.getProductDetail(productId);
});
