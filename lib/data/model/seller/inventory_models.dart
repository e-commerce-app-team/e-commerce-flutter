import 'dart:io';

class VariantAttributeType {
  final String uid;
  String name;
  List<String> values;

  VariantAttributeType({
    required this.uid,
    required this.name,
    List<String>? values,
  }) : values = values ?? [];

  bool get isValid => name.trim().isNotEmpty && values.isNotEmpty;

  static VariantAttributeType create() => VariantAttributeType(
    uid: DateTime.now().microsecondsSinceEpoch.toString(),
    name: '',
  );

  VariantAttributeType copyWith({String? name, List<String>? values}) =>
      VariantAttributeType(
        uid: uid,
        name: name ?? this.name,
        values: values ?? List.from(this.values),
      );
}

class ProductVariantModel {
  final String combinationKey;
  final Map<String, String> attributes;
  int stock;
  int? price;
  File? localImage;
  String? serverImageUrl;

  ProductVariantModel({
    required this.combinationKey,
    required this.attributes,
    required this.stock,
    this.price,
    this.localImage,
    this.serverImageUrl,
  });

  factory ProductVariantModel.fromJson(Map json) => ProductVariantModel(
    combinationKey: json['combination_key'] ?? '',
    attributes: Map<String, String>.from(json['attributes'] ?? {}),
    stock: json['stock'] ?? 0,
    price: json['price'],
    serverImageUrl: json['image_url'],
  );

  Map<String, dynamic> toMap() => {
    'combination_key': combinationKey,
    'attributes': attributes,
    'stock': stock,
    if (price != null) 'price': price,
  };

  ProductVariantModel copyWith({
    int? stock,
    int? price,
    File? localImage,
    String? serverImageUrl,
  }) =>
      ProductVariantModel(
        combinationKey: combinationKey,
        attributes: Map.from(attributes),
        stock: stock ?? this.stock,
        price: price ?? this.price,
        localImage: localImage ?? this.localImage,
        serverImageUrl: serverImageUrl ?? this.serverImageUrl,
      );
}

class ProductModel {
  final int id;
  final String name;
  final String sku;
  final int price;
  final int? salePrice;
  final String? saleEndsAt;
  final int stock;
  final int lowStockAlert;
  final String category;
  final int categoryId;
  final String status;
  final String? thumbnail;
  final bool hasVariants;
  final bool wholesaleEnabled;
  final bool isFreeShipping;
  final int weightGrams;
  final List<WarehouseStockEntry> warehouseStock;
  final List<VariantAttributeType> attributeTypes;
  final List<ProductVariantModel> variants;

  const ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    this.salePrice,
    this.saleEndsAt,
    required this.stock,
    required this.lowStockAlert,
    required this.category,
    required this.categoryId,
    required this.status,
    this.thumbnail,
    required this.hasVariants,
    required this.wholesaleEnabled,
    required this.isFreeShipping,
    required this.weightGrams,
    this.warehouseStock = const [],
    this.attributeTypes = const [],
    this.variants = const [],
  });

  bool get isLowStock => stock > 0 && stock <= lowStockAlert;
  bool get isOutOfStock => stock == 0;
  bool get hasDiscount => salePrice != null && salePrice! < price;
  int get discountPercent =>
      hasDiscount ? (((price - salePrice!) / price) * 100).round() : 0;

  factory ProductModel.fromJson(Map json) => ProductModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    sku: json['sku'] ?? '',
    price: json['price'] ?? 0,
    salePrice: json['sale_price'],
    saleEndsAt: json['sale_ends_at'],
    stock: json['stock'] ?? 0,
    lowStockAlert: json['low_stock_alert'] ?? 5,
    category: json['category'] ?? '',
    categoryId: json['category_id'] ?? 0,
    status: json['status'] ?? 'active',
    thumbnail: json['thumbnail'],
    hasVariants: json['has_variants'] ?? false,
    wholesaleEnabled: json['wholesale_enabled'] ?? false,
    isFreeShipping: json['is_free_shipping'] ?? false,
    weightGrams: json['weight_grams'] ?? 0,
    warehouseStock: (json['warehouse_stock'] as List? ?? [])
        .map((w) => WarehouseStockEntry.fromJson(w))
        .toList(),
    attributeTypes: [],
    variants: (json['variants'] as List? ?? [])
        .map((v) => ProductVariantModel.fromJson(v))
        .toList(),
  );

  ProductModel copyWith({String? status, int? stock}) => ProductModel(
    id: id, name: name, sku: sku, price: price,
    salePrice: salePrice, saleEndsAt: saleEndsAt,
    stock: stock ?? this.stock, lowStockAlert: lowStockAlert,
    category: category, categoryId: categoryId,
    status: status ?? this.status, thumbnail: thumbnail,
    hasVariants: hasVariants, wholesaleEnabled: wholesaleEnabled,
    isFreeShipping: isFreeShipping, weightGrams: weightGrams,
    warehouseStock: warehouseStock, attributeTypes: attributeTypes,
    variants: variants,
  );

  static List<ProductModel> mockList() => const [
    ProductModel(id: 1, name: 'حقيبة جلدية يدوية', sku: 'SKU-0041', price: 45000, stock: 12, lowStockAlert: 5, category: 'إكسسوارات', categoryId: 5, status: 'active', hasVariants: true, wholesaleEnabled: false, isFreeShipping: false, weightGrams: 900),
    ProductModel(id: 2, name: 'ساعة حائط خشبية', sku: 'SKU-0038', price: 14000, stock: 8, lowStockAlert: 5, category: 'ديكور المنزل', categoryId: 7, status: 'active', hasVariants: false, wholesaleEnabled: false, isFreeShipping: false, weightGrams: 1200),
    ProductModel(id: 3, name: 'إناء خزفي للزهور', sku: 'SKU-0036', price: 15000, salePrice: 11000, stock: 2, lowStockAlert: 5, category: 'ديكور المنزل', categoryId: 8, status: 'active', hasVariants: false, wholesaleEnabled: false, isFreeShipping: false, weightGrams: 800),
    ProductModel(id: 4, name: 'سوار فضي', sku: 'SKU-0029', price: 32000, stock: 20, lowStockAlert: 3, category: 'مجوهرات', categoryId: 3, status: 'active', hasVariants: true, wholesaleEnabled: true, isFreeShipping: false, weightGrams: 150),
    ProductModel(id: 5, name: 'طقم شموع يدوية', sku: 'SKU-0025', price: 8500, stock: 0, lowStockAlert: 5, category: 'نمط الحياة', categoryId: 4, status: 'draft', hasVariants: false, wholesaleEnabled: false, isFreeShipping: true, weightGrams: 400),
    ProductModel(id: 6, name: 'سلة تخزين منسوجة', sku: 'SKU-0021', price: 22000, stock: 5, lowStockAlert: 5, category: 'ديكور المنزل', categoryId: 8, status: 'active', hasVariants: false, wholesaleEnabled: false, isFreeShipping: false, weightGrams: 600),
    ProductModel(id: 7, name: 'مرآة إطار خشبي', sku: 'SKU-0018', price: 38000, stock: 7, lowStockAlert: 3, category: 'ديكور المنزل', categoryId: 8, status: 'active', hasVariants: false, wholesaleEnabled: true, isFreeShipping: false, weightGrams: 2100),
    ProductModel(id: 8, name: 'طفاية شمع ذهبية', sku: 'SKU-0015', price: 5500, stock: 30, lowStockAlert: 10, category: 'نمط الحياة', categoryId: 4, status: 'hidden', hasVariants: false, wholesaleEnabled: false, isFreeShipping: false, weightGrams: 200),
  ];
}

class WarehouseStockEntry {
  final int warehouseId;
  final String warehouseName;
  final String warehouseType;
  final int qty;

  const WarehouseStockEntry({
    required this.warehouseId,
    required this.warehouseName,
    required this.warehouseType,
    required this.qty,
  });

  factory WarehouseStockEntry.fromJson(Map json) => WarehouseStockEntry(
    warehouseId: json['warehouse_id'] ?? 0,
    warehouseName: json['warehouse_name'] ?? '',
    warehouseType: json['warehouse_type'] ?? 'warehouse',
    qty: json['qty'] ?? 0,
  );

  Map<String, dynamic> toMap() => {'warehouse_id': warehouseId, 'qty': qty};
}

class WarehouseModel {
  final int id;
  final String name;
  final String type;
  final String city;
  final bool isActive;

  const WarehouseModel({
    required this.id,
    required this.name,
    required this.type,
    required this.city,
    required this.isActive,
  });

  factory WarehouseModel.fromJson(Map json) => WarehouseModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    type: json['type'] ?? 'warehouse',
    city: json['city'] ?? '',
    isActive: json['is_active'] ?? true,
  );

  static List<WarehouseModel> mockList() => const [
    WarehouseModel(id: 1, name: 'المستودع الرئيسي — دمشق', type: 'warehouse', city: 'دمشق', isActive: true),
    WarehouseModel(id: 2, name: 'فرع حلب', type: 'branch', city: 'حلب', isActive: true),
    WarehouseModel(id: 3, name: 'مستودع حمص', type: 'warehouse', city: 'حمص', isActive: true),
  ];
}

class CategoryModel {
  final int id;
  final String name;
  final int? parentId;
  final int productCount;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    required this.productCount,
    this.children = const [],
  });

  bool get isLeaf => children.isEmpty;
  bool get hasChildren => children.isNotEmpty;
  bool get isRoot => parentId == null;

  factory CategoryModel.fromJson(Map json) => CategoryModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    parentId: json['parent_id'],
    productCount: json['product_count'] ?? 0,
    children: (json['children'] as List? ?? [])
        .map((c) => CategoryModel.fromJson(c))
        .toList(),
  );

  CategoryModel copyWithName(String newName) => CategoryModel(
    id: id, name: newName, parentId: parentId,
    productCount: productCount, children: children,
  );

  static List<CategoryModel> mockTree() => [
    CategoryModel(id: 1, name: 'إكسسوارات', productCount: 3, children: [
      CategoryModel(id: 5, name: 'حقائب', parentId: 1, productCount: 2),
      CategoryModel(id: 6, name: 'أحذية', parentId: 1, productCount: 1),
    ]),
    CategoryModel(id: 2, name: 'ديكور المنزل', productCount: 7, children: [
      CategoryModel(id: 7, name: 'إضاءة', parentId: 2, productCount: 2, children: [
        CategoryModel(id: 10, name: 'طاولة', parentId: 7, productCount: 1),
        CategoryModel(id: 11, name: 'حائطية', parentId: 7, productCount: 1),
      ]),
      CategoryModel(id: 8, name: 'أثاث', parentId: 2, productCount: 5),
    ]),
    CategoryModel(id: 3, name: 'مجوهرات', productCount: 2),
    CategoryModel(id: 4, name: 'نمط الحياة', productCount: 2),
  ];
}

class ProductFilter {
  final int? categoryId;
  final String? status;
  final String? stock;
  final String sort;

  const ProductFilter({
    this.categoryId, this.status, this.stock, this.sort = 'latest',
  });

  ProductFilter copyWith({
    int? categoryId, String? status, String? stock, String? sort,
    bool clearCategory = false, bool clearStatus = false, bool clearStock = false,
  }) =>
      ProductFilter(
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
        status: clearStatus ? null : (status ?? this.status),
        stock: clearStock ? null : (stock ?? this.stock),
        sort: sort ?? this.sort,
      );

  bool get hasActiveFilters => categoryId != null || status != null || stock != null;
  int get activeCount => [categoryId, status, stock].where((e) => e != null).length;
}

class ProductFormData {
  String name = '';
  String description = '';
  int? categoryId;
  String price = '';
  String salePrice = '';
  String? saleEndsAt;
  String sku = '';
  String stock = '';
  String lowStockAlert = '5';
  String weightGrams = '';
  String status = 'active';
  bool isFreeShipping = false;
  bool wholesaleEnabled = false;
  String wholesalePrice = '';
  String minWholesaleQty = '';
  Map<int, String> warehouseQty = {};
  bool variantsEnabled = false;
  List<VariantAttributeType> attributeTypes = [];
  List<ProductVariantModel> variants = [];

  int get totalWarehouseQty =>
      warehouseQty.values.fold(0, (sum, q) => sum + (int.tryParse(q) ?? 0));

  Map<String, String> toMap() => {
    'name': name, 'description': description,
    'category_id': categoryId.toString(), 'price': price,
    if (salePrice.isNotEmpty) 'sale_price': salePrice,
    if (saleEndsAt != null) 'sale_ends_at': saleEndsAt!,
    'sku': sku, 'stock': stock, 'low_stock_alert': lowStockAlert,
    'weight_grams': weightGrams, 'status': status,
    'is_free_shipping': isFreeShipping ? '1' : '0',
    'has_variants': variantsEnabled ? '1' : '0',
    if (wholesaleEnabled && wholesalePrice.isNotEmpty) 'wholesale_price': wholesalePrice,
    if (wholesaleEnabled && minWholesaleQty.isNotEmpty) 'min_wholesale_qty': minWholesaleQty,
  };
}