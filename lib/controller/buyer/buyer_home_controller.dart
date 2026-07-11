import 'package:get/get.dart';
import 'package:e_commerce/data/models/buyer/home_models.dart';
import 'package:flutter/material.dart';

class BuyerHomeController extends GetxController {
  // --- State Variables ---
  int currentNavIndex = 0;
  String? selectedCategoryId;
  
  // These lists will eventually be fetched from an API
  List<BuyerBannerItem> banners = [];
  List<BuyerCategoryItem> categories = [];
  List<BuyerStoreItem> featuredStores = [];
  List<BuyerProductItem> trendingProducts = [];
  List<BuyerProductItem> flashSaleProducts = [];
  List<BuyerProductItem> recommendedProducts = [];
  
  Duration flashSaleRemaining = const Duration(hours: 5, minutes: 42, seconds: 18);
  
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    _loadDemoData();
  }

  void changeNavIndex(int index) {
    currentNavIndex = index;
    update();
  }

  void changeCategory(String categoryId) {
    selectedCategoryId = categoryId;
    update();
  }

  void toggleFavorite(int index, String section) {
    // Logic to toggle favorite status
    if (section == 'trending') {
      trendingProducts[index] = trendingProducts[index].copyWith(
        isFavorite: !trendingProducts[index].isFavorite,
      );
    } else if (section == 'flash') {
      flashSaleProducts[index] = flashSaleProducts[index].copyWith(
        isFavorite: !flashSaleProducts[index].isFavorite,
      );
    } else if (section == 'recommended') {
      recommendedProducts[index] = recommendedProducts[index].copyWith(
        isFavorite: !recommendedProducts[index].isFavorite,
      );
    }
    update();
  }

  void _loadDemoData() {
    // In the future this will be replaced with actual API calls to Laravel backend.
    
    categories = const [
      BuyerCategoryItem(id: 'all', label: 'الكل', icon: Icons.apps_rounded),
      BuyerCategoryItem(id: 'electronics', label: 'إلكترونيات', icon: Icons.headphones_outlined),
      BuyerCategoryItem(id: 'fashion', label: 'أزياء', icon: Icons.checkroom_outlined),
      BuyerCategoryItem(id: 'home', label: 'منزل ومطبخ', icon: Icons.chair_outlined),
      BuyerCategoryItem(id: 'beauty', label: 'جمال وعناية', icon: Icons.spa_outlined),
      BuyerCategoryItem(id: 'sports', label: 'رياضة', icon: Icons.sports_soccer_outlined),
      BuyerCategoryItem(id: 'kids', label: 'أطفال', icon: Icons.child_care_outlined),
      BuyerCategoryItem(id: 'grocery', label: 'سوبرماركت', icon: Icons.local_grocery_store_outlined),
    ];
    
    selectedCategoryId = categories.first.id;

    banners = const [
      BuyerBannerItem(
        imageUrl: 'https://picsum.photos/seed/souk-fashion/800/500',
        title: 'موسم التخفيضات',
        subtitle: 'حتى 50% على تشكيلة الخريف',
        badgeLabel: 'عرض حصري',
      ),
      BuyerBannerItem(
        imageUrl: 'https://picsum.photos/seed/souk-electronics/800/500',
        title: 'وصل حديثاً',
        subtitle: 'أحدث الإلكترونيات بين يديك',
      ),
      BuyerBannerItem(
        imageUrl: 'https://picsum.photos/seed/souk-home/800/500',
        title: 'عالم المنزل',
        subtitle: 'جهزي بيتك بلمسة أنيقة',
        badgeLabel: 'جديد',
      ),
    ];

    featuredStores = const [
      BuyerStoreItem(
        coverUrl: 'https://picsum.photos/seed/store-asala-cover/400/220',
        logoUrl: 'https://picsum.photos/seed/store-asala-logo/120/120',
        name: 'متجر الأصالة',
        category: 'أزياء رجالية ونسائية',
        rating: 4.8,
        isOpen: true,
        isFeatured: true,
      ),
      BuyerStoreItem(
        coverUrl: 'https://picsum.photos/seed/store-lamsa-cover/400/220',
        logoUrl: 'https://picsum.photos/seed/store-lamsa-logo/120/120',
        name: 'بوتيك لمسة',
        category: 'إكسسوارات وحقائب',
        rating: 4.6,
        isOpen: true,
      ),
      BuyerStoreItem(
        coverUrl: 'https://picsum.photos/seed/store-tech-cover/400/220',
        logoUrl: 'https://picsum.photos/seed/store-tech-logo/120/120',
        name: 'التقنية الذكية',
        category: 'إلكترونيات وأجهزة',
        rating: 4.9,
        isOpen: false,
        isFeatured: true,
      ),
      BuyerStoreItem(
        coverUrl: 'https://picsum.photos/seed/store-kids-cover/400/220',
        logoUrl: 'https://picsum.photos/seed/store-kids-logo/120/120',
        name: 'عالم الأطفال',
        category: 'ملابس وألعاب أطفال',
        rating: 4.5,
        isOpen: true,
      ),
    ];

    trendingProducts = const [
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/prod-headphones/400/400',
        name: 'سماعة لاسلكية بلوتوث',
        price: 45000,
        rating: 4.7,
        ratingCount: 128,
        badgeLabel: 'الأكثر مبيعاً',
      ),
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/prod-bag/400/400',
        name: 'حقيبة يد جلدية طبيعية',
        price: 68000,
        oldPrice: 85000,
        rating: 4.5,
        ratingCount: 64,
      ),
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/prod-watch/400/400',
        name: 'ساعة ذكية رياضية',
        price: 120000,
        rating: 4.8,
        ratingCount: 212,
      ),
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/prod-perfume/400/400',
        name: 'عطر فرنسي فاخر',
        price: 95000,
        oldPrice: 110000,
        rating: 4.6,
        ratingCount: 47,
      ),
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/prod-shoes/400/400',
        name: 'حذاء رياضي خفيف',
        price: 52000,
        rating: 4.4,
        ratingCount: 33,
      ),
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/prod-sunglasses/400/400',
        name: 'نظارة شمسية كلاسيك',
        price: 38000,
        oldPrice: 47000,
        rating: 4.3,
        ratingCount: 19,
      ),
    ];

    flashSaleProducts = const [
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/flash-makeup/400/400',
        name: 'طقم مكياج احترافي',
        price: 36000,
        oldPrice: 60000,
        rating: 4.6,
        ratingCount: 88,
      ),
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/flash-earbuds/400/400',
        name: 'سماعة أذن رياضية',
        price: 22000,
        oldPrice: 35000,
        rating: 4.4,
        ratingCount: 41,
      ),
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/flash-wallet/400/400',
        name: 'محفظة جلد رجالي',
        price: 18000,
        oldPrice: 28000,
        rating: 4.7,
        ratingCount: 56,
      ),
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/flash-charger/400/400',
        name: 'شاحن لاسلكي سريع',
        price: 15000,
        oldPrice: 24000,
        rating: 4.5,
        ratingCount: 29,
      ),
    ];

    recommendedProducts = const [
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/rec-scarf/400/400',
        name: 'وشاح صوف شتوي',
        price: 27000,
        rating: 4.5,
        ratingCount: 22,
      ),
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/rec-lamp/400/400',
        name: 'مصباح مكتب LED',
        price: 31000,
        rating: 4.3,
        ratingCount: 14,
      ),
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/rec-serveware/400/400',
        name: 'طقم أواني تقديم',
        price: 56000,
        rating: 4.6,
        ratingCount: 38,
      ),
      BuyerProductItem(
        imageUrl: 'https://picsum.photos/seed/rec-yogamat/400/400',
        name: 'سجادة يوغا مانعة انزلاق',
        price: 24000,
        rating: 4.4,
        ratingCount: 17,
      ),
    ];

    isLoading = false;
    update();
  }
}
