import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_datasource.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remoteDataSource;

  CatalogRepositoryImpl(this.remoteDataSource);

  static final List<Category> _defaultCategories = [
    const Category(id: 'all', nameKm: 'ទាំងអស់', nameEn: 'All Dishes', icon: 'utensils'),
    const Category(id: 'specials', nameKm: 'មុខម្ហូបពិសេស', nameEn: 'Chef Specials', icon: 'sparkles'),
    const Category(id: 'duck-goose', nameKm: 'ទា និង ក្ងាន', nameEn: 'Duck & Poultry', icon: 'utensils'),
    const Category(id: 'chicken', nameKm: 'មាន់ស្រែ', nameEn: 'Chicken', icon: 'drumstick'),
    const Category(id: 'pork', nameKm: 'សាច់ជ្រូក', nameEn: 'Pork', icon: 'utensils'),
    const Category(id: 'beef', nameKm: 'សាច់គោ', nameEn: 'Beef', icon: 'flame'),
    const Category(id: 'eel-frog', nameKm: 'អន្ទង់ និង កង្កែប', nameEn: 'Eel & Frog', icon: 'fish'),
    const Category(id: 'fish-crab', nameKm: 'ត្រី និង ក្តាម', nameEn: 'Fish & Crab', icon: 'fish'),
    const Category(id: 'seafood', nameKm: 'គ្រឿងសមុទ្រ', nameEn: 'Seafood', icon: 'shrimp'),
    const Category(id: 'soups', nameKm: 'សម្ល និង ស៊ុប', nameEn: 'Soups', icon: 'soup'),
    const Category(id: 'beverages', nameKm: 'ភេសជ្ជៈ', nameEn: 'Beverages', icon: 'coffee'),
  ];

  static final List<Product> _mockFallbackDishes = [
    const Product(
      id: 'cmt1krpbt00180aj7e18d2xp6',
      name: 'កង្កែបចំបើងពិសេស (Special Fried Straw Frog Legs)',
      nameKm: 'កង្កែបចំបើងពិសេស',
      nameEn: 'Special Fried Straw Frog Legs',
      description: 'ម្ហូបឆ្ងាញ់ប្រចាំហាងភូមិយើង រសជាតិដើមបែបខ្មែរពិតៗ។',
      descKm: 'ម្ហូបឆ្ងាញ់ប្រចាំហាងភូមិយើង រសជាតិដើមបែបខ្មែរពិតៗ។',
      descEn: 'Authentic Cambodian dish made fresh daily with traditional local seasoning.',
      price: 4.50,
      stock: 45,
      images: ['/images/foods/cmt1krpbt00180aj7e18d2xp6.jpg'],
      categoryId: 'specials',
      spiceLevel: 'mild',
      isFeatured: true,
      rating: 5.0,
      reviewCount: 35,
    ),
    const Product(
      id: 'cmst1x5c200060akgz6pjzvxr',
      name: 'ឡាបសាច់មាន់ពិសេស (Special Minced Chicken Larb)',
      nameKm: 'ឡាបសាច់មាន់ពិសេស',
      nameEn: 'Special Minced Chicken Larb',
      description: 'ម្ហូបឆ្ងាញ់ប្រចាំហាងភូមិយើង រសជាតិដើមបែបខ្មែរពិតៗ។',
      descKm: 'ម្ហូបឆ្ងាញ់ប្រចាំហាងភូមិយើង រសជាតិដើមបែបខ្មែរពិតៗ។',
      descEn: 'Authentic Cambodian dish made fresh daily with traditional local seasoning.',
      price: 4.30,
      stock: 30,
      images: ['/images/foods/cmst1x5c200060akgz6pjzvxr.jpg'],
      categoryId: 'specials',
      spiceLevel: 'mild',
      isFeatured: true,
      rating: 5.0,
      reviewCount: 28,
    ),
    const Product(
      id: 'cmt1kjgux000409koqhepcykd',
      name: 'ឡាបសាច់ទាពិសេស (Special Duck Larb Salad)',
      nameKm: 'ឡាបសាច់ទាពិសេស',
      nameEn: 'Special Duck Larb Salad',
      description: 'ម្ហូបឆ្ងាញ់ប្រចាំហាងភូមិយើង រសជាតិដើមបែបខ្មែរពិតៗ។',
      descKm: 'ម្ហូបឆ្ងាញ់ប្រចាំហាងភូមិយើង រសជាតិដើមបែបខ្មែរពិតៗ។',
      descEn: 'Authentic Cambodian dish made fresh daily with traditional local seasoning.',
      price: 4.30,
      stock: 25,
      images: ['/images/foods/cmt1kjgux000409koqhepcykd.jpg'],
      categoryId: 'duck-goose',
      spiceLevel: 'mild',
      isFeatured: true,
      rating: 4.8,
      reviewCount: 29,
    ),
    const Product(
      id: 'cmtuypwop00020agm2ef3d0yx',
      name: 'កង្កែបបំពងអំបិលម្ទេស (Crispy Frog Legs with Chili Salt)',
      nameKm: 'កង្កែបបំពងអំបិលម្ទេស',
      nameEn: 'Crispy Frog Legs with Chili Salt',
      description: 'កង្កែបស្រស់បំពងស្រួយ ជាមួយអំបិលម្រេចកំពត និងម្ទេសហិរឈ្ងុយ។',
      descKm: 'កង្កែបស្រស់បំពងស្រួយ ជាមួយអំបិលម្រេចកំពត និងម្ទេសហិរឈ្ងុយ។',
      descEn: 'Crispy deep-fried fresh frog legs tossed in Kampot pepper & chili salt.',
      price: 4.50,
      stock: 35,
      images: ['/images/foods/cmtuypwop00020agm2ef3d0yx.jpg'],
      categoryId: 'specials',
      spiceLevel: 'hot',
      isFeatured: true,
      rating: 4.9,
      reviewCount: 42,
    ),
    const Product(
      id: 'clyd2ywom000c3m93rjfp38ql',
      name: 'ឆាអន្ទង់ម្ទេសខ្ទឹមជ្រក់ (Stir-Fried Eel with Chili & Pickled Garlic)',
      nameKm: 'ឆាអន្ទង់ម្ទេសខ្ទឹមជ្រក់',
      nameEn: 'Stir-Fried Eel with Chili & Pickled Garlic',
      description: 'អន្ទង់ទន្លេស្រស់ឆាជាមួយខ្ទឹមជ្រក់ និងម្ទេសក្រៀមហិរឈ្ងុយឆ្ងាញ់។',
      descKm: 'អន្ទង់ទន្លេស្រស់ឆាជាមួយខ្ទឹមជ្រក់ និងម្ទេសក្រៀមហិរឈ្ងុយឆ្ងាញ់។',
      descEn: 'Fresh freshwater eel wok-tossed with pickled garlic and aromatic chili.',
      price: 4.90,
      stock: 20,
      images: ['/images/foods/clyd2ywom000c3m93rjfp38ql.jpg'],
      categoryId: 'eel-frog',
      spiceLevel: 'hot',
      isFeatured: true,
      rating: 4.9,
      reviewCount: 64,
    ),
  ];

  @override
  Future<List<Product>> getProducts({
    int limit = 50,
    String? cursor,
    String? categoryId,
    String? search,
    bool? featured,
  }) async {
    try {
      final dtos = await remoteDataSource.fetchProducts(
        limit: limit,
        cursor: cursor,
        categoryId: categoryId,
        search: search,
        featured: featured,
      );
      if (dtos.isNotEmpty) {
        return dtos.map((dto) => dto.toEntity()).toList();
      }
    } catch (_) {
      // Fallback
    }

    var list = _mockFallbackDishes;
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }
    if (search != null && search.isNotEmpty) {
      list = list.where((p) =>
          p.name.toLowerCase().contains(search.toLowerCase()) ||
          p.nameKm.toLowerCase().contains(search.toLowerCase()) ||
          p.nameEn.toLowerCase().contains(search.toLowerCase())).toList();
    }
    if (featured != null) {
      list = list.where((p) => p.isFeatured == featured).toList();
    }
    return list;
  }

  @override
  Future<Product> getProductDetail(String id) async {
    try {
      final dto = await remoteDataSource.fetchProductDetail(id);
      return dto.toEntity();
    } catch (_) {
      return _mockFallbackDishes.firstWhere(
        (p) => p.id == id,
        orElse: () => _mockFallbackDishes.first,
      );
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final categories = await remoteDataSource.fetchCategories();
      if (categories.isNotEmpty) {
        return [
          const Category(id: 'all', nameKm: 'ទាំងអស់', nameEn: 'All Dishes', icon: 'utensils'),
          ...categories,
        ];
      }
    } catch (_) {
      // Fallback
    }
    return _defaultCategories;
  }
}
