import 'dart:convert';
import 'dart:io';
import 'package:e_commerce/link_api.dart';

// ─── Variant Attribute Type ───────────────────────────────────────────────────

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

// ─── Product Variant Model ────────────────────────────────────────────────────

class ProductVariantModel {
  final int? id;              // Backend field: id
  final String combinationKey;
  final Map<String, String> attributes;
  int stock;                  // Backend field: quantity
  int? price;
  String? sku;
  bool isActive;              // Backend field: is_active
  File? localImage;
  String? serverImageUrl;     // Backend field: image_url

  ProductVariantModel({
    this.id,
    required this.combinationKey,
    required this.attributes,
    required this.stock,
    this.price,
    this.sku,
    this.isActive = true,
    this.localImage,
    this.serverImageUrl,
  });

  factory ProductVariantModel.fromJson(Map json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? 0;
      return 0;
    }
    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return false;
    }
    
    // Server might return attributes as a JSON string
    dynamic rawAttrs = json['attributes'];
    if (rawAttrs is String) {
      try {
        rawAttrs = jsonDecode(rawAttrs);
      } catch (_) {
        rawAttrs = {};
      }
    }
    
    final attrs = rawAttrs is Map
        ? Map<String, String>.fromEntries(
            rawAttrs.entries.map(
              (e) => MapEntry(e.key.toString(), e.value.toString()),
            ),
          )
        : <String, String>{};
    final combinationKey = attrs.values.join(' / ');
    return ProductVariantModel(
      id: parseInt(json['id']),
      combinationKey:
          combinationKey.isNotEmpty ? combinationKey : 'variant-${json['id']}',
      attributes: attrs,
      stock: parseInt(json['quantity']),   // Backend uses 'quantity'
      price: json['price'] != null ? parseInt(json['price']) : null,
      sku: json['sku']?.toString(),
      isActive: json['is_active'] != null ? parseBool(json['is_active']) : true,
      serverImageUrl: json['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'combination_key': combinationKey,
        'attributes': attributes,
        'quantity': stock,              // Backend uses 'quantity'
        if (price != null) 'price': price,
        if (sku != null && sku!.isNotEmpty) 'sku': sku,
        'is_active': isActive,
      };

  ProductVariantModel copyWith({
    int? stock,
    int? price,
    String? sku,
    bool? isActive,
    File? localImage,
    String? serverImageUrl,
  }) =>
      ProductVariantModel(
        id: id,
        combinationKey: combinationKey,
        attributes: Map.from(attributes),
        stock: stock ?? this.stock,
        price: price ?? this.price,
        sku: sku ?? this.sku,
        isActive: isActive ?? this.isActive,
        localImage: localImage ?? this.localImage,
        serverImageUrl: serverImageUrl ?? this.serverImageUrl,
      );
}

// ─── Product Model ────────────────────────────────────────────────────────────

class ProductModel {
  final int id;
  final String name;
  final String description;
  final String sku;
  final int price;            // Backend field: original_price
  final int? salePrice;       // Backend field: offer_price
  final String? saleEndsAt;   // Backend field: offer_expires_at
  final int stock;            // Backend field: quantity
  final int lowStockAlert;    // Backend field: alert_threshold
  final String category;
  final int categoryId;
  final String status;
  final String? thumbnail;
  final List<String> serverImages;
  final bool hasVariants;
  final bool wholesaleEnabled;
  final int? wholesalePrice;
  final int? minWholesaleQty;
  final bool isFreeShipping;
  final int weightGrams;      // Backend field: weight
  final List<WarehouseStockEntry> warehouseStock;
  final List<VariantAttributeType> attributeTypes;
  final List<ProductVariantModel> variants;
  // ─── Tax fields ───────────────────────────────────────────────────────────
  final bool    taxExempt;
  final String? taxExemptReason;
  final double  effectiveTaxRate; // e.g. 5.0, 10.0, 0.0

  const ProductModel({
    required this.id,
    required this.name,
    this.description = '',
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
    this.serverImages = const [],
    required this.hasVariants,
    required this.wholesaleEnabled,
    this.wholesalePrice,
    this.minWholesaleQty,
    required this.isFreeShipping,
    required this.weightGrams,
    this.warehouseStock = const [],
    this.attributeTypes = const [],
    this.variants = const [],
    this.taxExempt = false,
    this.taxExemptReason,
    this.effectiveTaxRate = 5.0,
  });

  bool get isLowStock => stock > 0 && stock <= lowStockAlert;
  bool get isOutOfStock => stock == 0;
  bool get hasDiscount => salePrice != null && salePrice! < price;
  int get discountPercent =>
      hasDiscount ? (((price - salePrice!) / price) * 100).round() : 0;

  factory ProductModel.fromJson(Map json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? 0;
      return 0;
    }

    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return false;
    }

    // Parse warehouse_stock: can be a List, a JSON string, or null
    List<WarehouseStockEntry> parseWarehouseStock(dynamic ws) {
      if (ws == null) return [];
      if (ws is List) {
        return ws.map((w) => WarehouseStockEntry.fromJson(w as Map)).toList();
      }
      if (ws is String) {
        try {
          return (jsonDecode(ws) as List)
              .map((w) => WarehouseStockEntry.fromJson(w as Map))
              .toList();
        } catch (_) {
          return [];
        }
      }
      return [];
    }

    // Build thumbnail from the first image path stored on the server
    String? buildThumbnail(dynamic images) {
      if (images is List && images.isNotEmpty) {
        return AppLink.storageUrl(images.first.toString());
      }
      if (images is String) {
        try {
          final decoded = jsonDecode(images);
          if (decoded is List && decoded.isNotEmpty) {
            return AppLink.storageUrl(decoded.first.toString());
          }
        } catch (_) {}
      }
      return null;
    }

    List<String> buildServerImages(dynamic images) {
      if (images is List) {
        return images.map((e) => AppLink.storageUrl(e.toString())).toList();
      }
      if (images is String) {
        try {
          final decoded = jsonDecode(images);
          if (decoded is List) {
            return decoded.map((e) => AppLink.storageUrl(e.toString())).toList();
          }
        } catch (_) {}
      }
      return [];
    }

    final variants = (json['variants'] as List? ?? [])
        .map((v) => ProductVariantModel.fromJson(v as Map))
        .toList();

    return ProductModel(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      price: parseInt(json['original_price']),
      salePrice: json['offer_price'] != null ? parseInt(json['offer_price']) : null,
      saleEndsAt: json['offer_expires_at']?.toString(),
      stock: parseInt(json['quantity']),
      lowStockAlert: parseInt(json['alert_threshold']),
      category: '',
      categoryId: parseInt(json['department_id'] ?? json['category_id']),
      status: json['status']?.toString() ?? 'active',
      thumbnail: buildThumbnail(json['images']),
      serverImages: buildServerImages(json['images']),
      hasVariants: variants.isNotEmpty,
      wholesaleEnabled: json['wholesale_price'] != null,
      wholesalePrice: json['wholesale_price'] != null ? parseInt(json['wholesale_price']) : null,
      minWholesaleQty: json['min_wholesale_qty'] != null ? parseInt(json['min_wholesale_qty']) : null,
      isFreeShipping: parseBool(json['is_free_shipping']),
      weightGrams: parseInt(json['weight']),
      warehouseStock: parseWarehouseStock(json['warehouse_stock']),
      attributeTypes: [],
      variants: variants,
      taxExempt:        parseBool(json['tax_exempt']),
      taxExemptReason:  json['tax_exempt_reason']?.toString(),
      effectiveTaxRate: (json['effective_tax_rate'] ?? 5.0).toDouble(),
    );
  }

  ProductModel copyWith({
    String? status,
    int? stock,
    String? category,
    String? description,
    bool? taxExempt,
    String? taxExemptReason,
    double? effectiveTaxRate,
  }) =>
      ProductModel(
        id: id,
        name: name,
        description: description ?? this.description,
        sku: sku,
        price: price,
        salePrice: salePrice,
        saleEndsAt: saleEndsAt,
        stock: stock ?? this.stock,
        lowStockAlert: lowStockAlert,
        category: category ?? this.category,
        categoryId: categoryId,
        status: status ?? this.status,
        thumbnail: thumbnail,
        serverImages: serverImages,
        hasVariants: hasVariants,
        wholesaleEnabled: wholesaleEnabled,
        wholesalePrice: wholesalePrice,
        minWholesaleQty: minWholesaleQty,
        isFreeShipping: isFreeShipping,
        weightGrams: weightGrams,
        warehouseStock: warehouseStock,
        attributeTypes: attributeTypes,
        variants: variants,
        taxExempt:        taxExempt        ?? this.taxExempt,
        taxExemptReason:  taxExemptReason  ?? this.taxExemptReason,
        effectiveTaxRate: effectiveTaxRate  ?? this.effectiveTaxRate,
      );

  // Mock data (used as fallback only — real data comes from API)
  static List<ProductModel> mockList() => const [
        ProductModel(id: 1, name: 'لابتب غيمنغ', sku: 'SKU-0041', price: 45000, stock: 12, lowStockAlert: 5, category: 'الكترونيات', categoryId: 5, status: 'active', hasVariants: true, wholesaleEnabled: false, isFreeShipping: false, weightGrams: 900),
        ProductModel(id: 2, name: 'ساعة يد', sku: 'SKU-0038', price: 14000, stock: 8, lowStockAlert: 5, category: 'اكسسوارات', categoryId: 7, status: 'active', hasVariants: false, wholesaleEnabled: false, isFreeShipping: false, weightGrams: 1200),
        ProductModel(id: 3, name: 'سوار فضة', sku: 'SKU-0036', price: 15000, salePrice: 11000, stock: 2, lowStockAlert: 5, category: 'اكسسوارات', categoryId: 8, status: 'active', hasVariants: false, wholesaleEnabled: false, isFreeShipping: false, weightGrams: 800),
        ProductModel(id: 4, name: 'كنزة صيفية', sku: 'SKU-0029', price: 32000, stock: 20, lowStockAlert: 3, category: 'ملابس', categoryId: 3, status: 'active', hasVariants: true, wholesaleEnabled: true, isFreeShipping: false, weightGrams: 150),
        ProductModel(id: 5, name: 'كنزة شتوية', sku: 'SKU-0025', price: 8500, stock: 0, lowStockAlert: 5, category: 'ملابس', categoryId: 4, status: 'draft', hasVariants: false, wholesaleEnabled: false, isFreeShipping: true, weightGrams: 400),
        ProductModel(id: 6, name: 'شورت', sku: 'SKU-0021', price: 22000, stock: 5, lowStockAlert: 5, category: 'ملابس', categoryId: 8, status: 'active', hasVariants: false, wholesaleEnabled: false, isFreeShipping: false, weightGrams: 600),
        ProductModel(id: 7, name: 'سشوار', sku: 'SKU-0018', price: 38000, stock: 7, lowStockAlert: 3, category: 'ديكور المنزل', categoryId: 8, status: 'active', hasVariants: false, wholesaleEnabled: true, isFreeShipping: false, weightGrams: 2100),
        ProductModel(id: 8, name: 'ايفوم اسود', sku: 'SKU-0015', price: 5500, stock: 30, lowStockAlert: 10, category: 'مبايلات', categoryId: 4, status: 'hidden', hasVariants: false, wholesaleEnabled: false, isFreeShipping: false, weightGrams: 200),
      ];
}

// ─── Warehouse Stock Entry ────────────────────────────────────────────────────

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

  factory WarehouseStockEntry.fromJson(Map json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? 0;
      return 0;
    }
    return WarehouseStockEntry(
      warehouseId: parseInt(json['warehouse_id']),
      warehouseName: json['warehouse_name']?.toString() ?? '',
      warehouseType: json['warehouse_type']?.toString() ?? 'warehouse',
      qty: parseInt(json['qty']),
    );
  }

  Map<String, dynamic> toMap() => {'warehouse_id': warehouseId, 'qty': qty};
}

// ─── Warehouse Model ──────────────────────────────────────────────────────────

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
        city: json['address'] ?? json['city'] ?? '',
        isActive: json['is_active'] ?? true,
      );

  // Static mock — no warehouse endpoint in backend yet
  static List<WarehouseModel> mockList() => const [
        WarehouseModel(id: 1, name: 'المستودع الرئيسي — دمشق', type: 'warehouse', city: 'دمشق', isActive: true),
        WarehouseModel(id: 2, name: 'فرع حلب', type: 'branch', city: 'حلب', isActive: true),
        WarehouseModel(id: 3, name: 'مستودع حمص', type: 'warehouse', city: 'حمص', isActive: true),
      ];
}

// ─── Category Model ───────────────────────────────────────────────────────────

class CategoryModel {
  final int id;
  final String name;
  final int? parentId;
  final int productCount;
  final bool isVisible;
  final String? imageUrl;
  final String? iconUrl;
  final int orderPosition;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    required this.productCount,
    this.isVisible = true,
    this.imageUrl,
    this.iconUrl,
    this.orderPosition = 0,
    this.children = const [],
  });

  bool get isLeaf => children.isEmpty;
  bool get hasChildren => children.isNotEmpty;
  bool get isRoot => parentId == null;

  factory CategoryModel.fromJson(Map json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? 0;
      return 0;
    }
    bool parseBool(dynamic val) {
      if (val == null) return true; // default visible
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return true;
    }
    return CategoryModel(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      parentId: json['parent_id'] != null ? parseInt(json['parent_id']) : null,
      productCount: parseInt(json['product_count'] ?? json['products_count']),
      isVisible: parseBool(json['is_visible']),
      imageUrl: json['image_url']?.toString(),
      iconUrl: json['icon_url']?.toString(),
      orderPosition: parseInt(json['order_position']),
      children: ((json['recursive_children'] ?? json['recursiveChildren'] ?? json['children']) as List? ?? [])
          .map((c) => CategoryModel.fromJson(c as Map))
          .toList(),
    );
  }

  CategoryModel copyWithName(String newName) => CategoryModel(
        id: id,
        name: newName,
        parentId: parentId,
        productCount: productCount,
        isVisible: isVisible,
        imageUrl: imageUrl,
        iconUrl: iconUrl,
        orderPosition: orderPosition,
        children: children,
      );

  static List<CategoryModel> mockTree() => [
        CategoryModel(id: 1, name: 'إكسسوارات', productCount: 3, children: [
          CategoryModel(id: 5, name: 'حقائب', parentId: 1, productCount: 2),
          CategoryModel(id: 6, name: 'أحذية', parentId: 1, productCount: 1),
        ]),
        CategoryModel(id: 2, name: 'ملابس', productCount: 7, children: [
          CategoryModel(id: 7, name: 'شتوية', parentId: 2, productCount: 2, children: [
            CategoryModel(id: 10, name: 'رجالي', parentId: 7, productCount: 1),
            CategoryModel(id: 11, name: 'اطفال', parentId: 7, productCount: 1),
          ]),
          CategoryModel(id: 8, name: 'أثاث', parentId: 2, productCount: 5),
        ]),
        CategoryModel(id: 3, name: 'مجوهرات', productCount: 2),
        CategoryModel(id: 4, name: 'الكترونيات', productCount: 2),
      ];
}

// ─── Product Filter ───────────────────────────────────────────────────────────

class ProductFilter {
  final int? categoryId;
  final String? status;
  final String? stock;
  final String sort;

  const ProductFilter({
    this.categoryId,
    this.status,
    this.stock,
    this.sort = 'latest',
  });

  ProductFilter copyWith({
    int? categoryId,
    String? status,
    String? stock,
    String? sort,
    bool clearCategory = false,
    bool clearStatus = false,
    bool clearStock = false,
  }) =>
      ProductFilter(
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
        status: clearStatus ? null : (status ?? this.status),
        stock: clearStock ? null : (stock ?? this.stock),
        sort: sort ?? this.sort,
      );

  bool get hasActiveFilters =>
      categoryId != null || status != null || stock != null;
  int get activeCount =>
      [categoryId, status, stock].where((e) => e != null).length;
}

// ─── Product Form Data ────────────────────────────────────────────────────────

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

  /// Returns a map with the correct backend field names.
  /// Note: the controller's _buildProductFields() is the authoritative
  /// source for multipart form submission (includes files & variants).
  Map<String, String> toMap() => {
        'name': name,
        'description': description,
        'category_id': categoryId.toString(),
        'original_price': price,                    // was 'price'
        if (salePrice.isNotEmpty) 'offer_price': salePrice,      // was 'sale_price'
        if (saleEndsAt != null) 'offer_expires_at': saleEndsAt!, // was 'sale_ends_at'
        'sku': sku,
        'quantity': stock,                          // was 'stock'
        'alert_threshold': lowStockAlert,           // was 'low_stock_alert'
        if (weightGrams.isNotEmpty) 'weight': weightGrams,       // was 'weight_grams'
        'status': status,
        'is_free_shipping': isFreeShipping ? '1' : '0',
        if (wholesaleEnabled && wholesalePrice.isNotEmpty)
          'wholesale_price': wholesalePrice,
        if (wholesaleEnabled && minWholesaleQty.isNotEmpty)
          'min_wholesale_qty': minWholesaleQty,
      };
}