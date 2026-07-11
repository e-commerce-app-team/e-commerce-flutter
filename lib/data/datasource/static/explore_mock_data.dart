import 'package:flutter/material.dart';
import 'package:e_commerce/data/models/explore/explore_models.dart';

class ExploreMockData {
  static const List<ExploreCategoryModel> categories = [
    ExploreCategoryModel(id: 'all', name: 'all', icon: Icons.apps_rounded),
    ExploreCategoryModel(
      id: 'electronics',
      name: 'cat_electronics',
      icon: Icons.devices_other_rounded,
      subCategories: [
        ExploreSubCategoryModel(id: 'phones', name: 'sub_phones'),
        ExploreSubCategoryModel(id: 'laptops', name: 'sub_laptops'),
        ExploreSubCategoryModel(id: 'accessories', name: 'sub_accessories'),
      ],
    ),
    ExploreCategoryModel(
      id: 'fashion',
      name: 'cat_fashion',
      icon: Icons.checkroom_rounded,
      subCategories: [
        ExploreSubCategoryModel(id: 'men', name: 'sub_men'),
        ExploreSubCategoryModel(id: 'women', name: 'sub_women'),
        ExploreSubCategoryModel(id: 'kids', name: 'sub_kids'),
      ],
    ),
    ExploreCategoryModel(id: 'home', name: 'cat_home', icon: Icons.chair_outlined),
    ExploreCategoryModel(id: 'beauty', name: 'cat_beauty', icon: Icons.face_retouching_natural_rounded),
    ExploreCategoryModel(id: 'grocery', name: 'cat_grocery', icon: Icons.local_grocery_store_outlined),
    ExploreCategoryModel(id: 'toys', name: 'cat_toys', icon: Icons.toys_rounded),
  ];

  static final List<ExploreProductModel> products = [
    const ExploreProductModel(id: 'p1', name: 'سماعات لاسلكية بلوتوث عالية الجودة', storeName: 'متجر التقنية الحديثة', storeId: 's1', categoryId: 'electronics', price: 185000, salePrice: 139000, rating: 4.6, reviewCount: 214, hasFreeShipping: true),
    const ExploreProductModel(id: 'p2', name: 'ساعة ذكية رياضية مقاومة للماء', storeName: 'متجر التقنية الحديثة', storeId: 's1', categoryId: 'electronics', price: 320000, rating: 4.8, reviewCount: 132, hasWholesalePrice: true),
    const ExploreProductModel(id: 'p3', name: 'قميص قطني رجالي كلاسيكي', storeName: 'أزياء الشام', storeId: 's2', categoryId: 'fashion', price: 65000, salePrice: 45000, rating: 4.3, reviewCount: 89, hasFreeShipping: true),
    const ExploreProductModel(id: 'p4', name: 'فستان سهرة نسائي أنيق', storeName: 'بوتيك دمشق', storeId: 's3', categoryId: 'fashion', price: 210000, rating: 4.9, reviewCount: 56),
    const ExploreProductModel(id: 'p5', name: 'طقم أواني طبخ سيراميك 12 قطعة', storeName: 'بيت الأناقة', storeId: 's4', categoryId: 'home', price: 450000, salePrice: 375000, rating: 4.5, reviewCount: 178, hasFreeShipping: true, hasWholesalePrice: true),
    const ExploreProductModel(id: 'p6', name: 'مصباح طاولة خشبي عصري', storeName: 'بيت الأناقة', storeId: 's4', categoryId: 'home', price: 95000, rating: 4.1, reviewCount: 34),
    const ExploreProductModel(id: 'p7', name: 'كريم مرطب للبشرة الحساسة', storeName: 'عالم الجمال', storeId: 's5', categoryId: 'beauty', price: 38000, rating: 4.7, reviewCount: 245, hasFreeShipping: true),
    const ExploreProductModel(id: 'p8', name: 'عطر فرنسي فاخر للرجال', storeName: 'عالم الجمال', storeId: 's5', categoryId: 'beauty', price: 165000, salePrice: 129000, rating: 4.8, reviewCount: 98),
    const ExploreProductModel(id: 'p9', name: 'سلة فواكه طازجة مشكلة', storeName: 'سوق الخضار الطازج', storeId: 's6', categoryId: 'grocery', price: 28000, rating: 4.2, reviewCount: 61, hasFreeShipping: true),
    const ExploreProductModel(id: 'p10', name: 'دراجة أطفال هوائية ملونة', storeName: 'عالم الألعاب', storeId: 's7', categoryId: 'toys', price: 145000, rating: 4.4, reviewCount: 41),
    const ExploreProductModel(id: 'p11', name: 'لابتوب محمول للألعاب والتصميم', storeName: 'متجر التقنية الحديثة', storeId: 's1', categoryId: 'electronics', price: 2850000, salePrice: 2490000, rating: 4.9, reviewCount: 27, hasWholesalePrice: true),
    const ExploreProductModel(id: 'p12', name: 'حقيبة ظهر جلدية للرحلات', storeName: 'أزياء الشام', storeId: 's2', categoryId: 'fashion', price: 88000, rating: 4.0, reviewCount: 19, hasFreeShipping: true),
  ];

  static final List<ExploreStoreModel> stores = [
    const ExploreStoreModel(id: 's1', name: 'متجر التقنية الحديثة', category: 'cat_electronics', rating: 4.7, reviewCount: 512, isOpen: true, productCount: 128),
    const ExploreStoreModel(id: 's2', name: 'أزياء الشام', category: 'cat_fashion', rating: 4.4, reviewCount: 289, isOpen: true, productCount: 76),
    const ExploreStoreModel(id: 's3', name: 'بوتيك دمشق', category: 'cat_fashion', rating: 4.9, reviewCount: 143, isOpen: false, productCount: 42),
    const ExploreStoreModel(id: 's4', name: 'بيت الأناقة', category: 'cat_home', rating: 4.5, reviewCount: 201, isOpen: true, productCount: 94),
    const ExploreStoreModel(id: 's5', name: 'عالم الجمال', category: 'cat_beauty', rating: 4.8, reviewCount: 356, isOpen: true, productCount: 65),
    const ExploreStoreModel(id: 's6', name: 'سوق الخضار الطازج', category: 'cat_grocery', rating: 4.1, reviewCount: 88, isOpen: true, productCount: 53, isFollowing: true),
  ];
}
