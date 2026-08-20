import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/core/functions/format_price.dart' as price_fmt;
import 'package:e_commerce/link_api.dart';
import 'package:e_commerce/controller/buyer/cart_controller.dart';
import 'package:e_commerce/view/screen/buyer/chat/buyer_chat_room_screen.dart';
import 'package:e_commerce/view/widget/buyer/shared/buyer_network_image.dart';

String _productImageUrl(dynamic value) {
  final raw = value is Map
      ? (value['url'] ??
            value['image_url'] ??
            value['image'] ??
            value['path'] ??
            value['filename'])
      : value;
  final path = raw?.toString().trim() ?? '';
  if (path.isEmpty || path.startsWith('http')) return path;
  if (path.startsWith('/storage/')) {
    return '${AppLink.server.replaceFirst('/api', '')}$path';
  }
  if (path.startsWith('storage/')) {
    return '${AppLink.server.replaceFirst('/api', '')}/$path';
  }
  return AppLink.storageUrl(path);
}

class BuyerProductDetailScreen extends StatefulWidget {
  const BuyerProductDetailScreen({super.key});

  @override
  State<BuyerProductDetailScreen> createState() =>
      _BuyerProductDetailScreenState();
}

class _BuyerProductDetailScreenState extends State<BuyerProductDetailScreen> {
  final Crud _crud = Crud();
  Map<String, dynamic>? _product;
  bool _loading = true;
  bool _favorite = false;
  int _quantity = 1;
  String? _selectedVariantId;
  double? _myRating;
  String _myComment = '';
  String? _error;

  String get _id =>
      (Get.arguments is Map ? Get.arguments['product_id'] : Get.arguments)
          .toString();
  String? get _token {
    try {
      return Get.find<MyServices>().sharedPreferences.getString('token');
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController(), permanent: true);
    }
    _load();
  }

  Future<void> _load() async {
    final result = await _crud.getData(AppLink.buyerProductDetails(_id));
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _loading = false;
        _error = 'product_load_failed'.tr;
      }),
      (response) {
        final raw = response['data'];
        final data = raw is Map && raw['product'] is Map ? raw['product'] : raw;
        setState(() {
          _loading = false;
          _product = data is Map ? Map<String, dynamic>.from(data) : null;
          _favorite =
              _product?['is_favorite'] == true || _product?['is_favorite'] == 1;
          _error = _product == null ? 'product_not_available'.tr : null;
        });
      },
    );
    _crud.postData(AppLink.buyerProductView(_id), {});
  }

  Future<void> _toggleFavorite() async {
    if (_token == null) {
      Get.snackbar('signin_required_title'.tr, 'signin_required_cart'.tr);
      return;
    }
    final result = await _crud.postData(
      AppLink.buyerToggleFavorite(_id),
      {},
      headers: {'Authorization': 'Bearer $_token'},
    );
    result.fold((_) {}, (response) {
      if (response['success'] != true) return;
      if (mounted) setState(() => _favorite = response['is_favorite'] == true);
    });
  }

  Future<void> _addToCart() async {
    final variants = _product?['variants'];
    if (variants is List && variants.isNotEmpty && _selectedVariantId == null) {
      Get.snackbar('choose_variant_title'.tr, 'choose_variant_body'.tr);
      return;
    }
    Map? selectedVariant;
    if (variants is List && _selectedVariantId != null) {
      for (final value in variants) {
        if (value is Map &&
            '${value['id'] ?? value['combination_key'] ?? ''}' ==
                _selectedVariantId) {
          selectedVariant = value;
          break;
        }
      }
    }
    final variantStock =
        selectedVariant?['quantity'] ?? selectedVariant?['stock'];
    final stock = variantStock is num
        ? variantStock.toInt()
        : (_product?['stock'] as num?)?.toInt() ??
              (_product?['quantity'] as num?)?.toInt();
    await Get.find<CartController>().addToCart(
      _id,
      qty: _quantity,
      variantId: _selectedVariantId,
      maxStock: stock,
    );
  }

  void _openChat() {
    final p = _product ?? {};
    Get.to(
      () => const BuyerChatRoomScreen(),
      arguments: {
        'seller_id': p['store_id'] ?? p['seller_id'] ?? 0,
        'store_name': p['store_name'] ?? p['seller_name'] ?? 'Store',
        'store_logo': p['store_logo'] ?? '',
      },
    );
  }

  Future<void> _writeReview() async {
    final result = await showModalBottomSheet<_ReviewDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewSheet(
        initialRating: _myRating ?? 0,
        initialComment: _myComment,
      ),
    );
    if (result != null && mounted) {
      final token = _token;
      if (token == null || token.isEmpty) {
        Get.snackbar('signin_required_title'.tr, 'signin_required_cart'.tr);
        return;
      }
      final response = await _crud.postData(
        '${AppLink.server}/buyer/reviews',
        {
          'product_id': int.tryParse(_id) ?? _id,
          'rating': result.rating.round(),
          'comment': result.comment,
        },
        headers: {'Authorization': 'Bearer $token'},
      );
      final failed = response.fold((_) => true, (body) => body['success'] != true);
      if (failed) {
        Get.snackbar('error'.tr, 'server_error'.tr);
        return;
      }
      setState(() {
        _myRating = result.rating;
        _myComment = result.comment;
      });
      Get.snackbar(
        'review_sent_title'.tr,
        'review_sent_body'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundScaffold,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundScaffold,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'product_details'.tr,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _favorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _favorite ? AppColor.error : AppColor.black,
            ),
          ),
          IconButton(
            onPressed: () => Get.find<CartController>().loadCart(),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorState(message: _error!, onRetry: _load)
          : _ProductBody(
              product: _product!,
              quantity: _quantity,
              selectedVariantId: _selectedVariantId,
              favorite: _favorite,
              myRating: _myRating,
              myComment: _myComment,
              onQuantityChanged: (v) => setState(() => _quantity = v),
              onVariantSelected: (v) => setState(() => _selectedVariantId = v),
              onAddToCart: _addToCart,
              onChat: _openChat,
              onReview: _writeReview,
            ),
    );
  }
}

class _ProductBody extends StatelessWidget {
  final Map<String, dynamic> product;
  final int quantity;
  final String? selectedVariantId;
  final bool favorite;
  final double? myRating;
  final String myComment;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<String> onVariantSelected;
  final VoidCallback onAddToCart, onChat, onReview;
  const _ProductBody({
    required this.product,
    required this.quantity,
    required this.selectedVariantId,
    required this.favorite,
    required this.myRating,
    required this.myComment,
    required this.onQuantityChanged,
    required this.onVariantSelected,
    required this.onAddToCart,
    required this.onChat,
    required this.onReview,
  });

  List<String> get images {
    final values = product['images'] ?? product['gallery'] ?? product['photos'];
    final urls = values is List
        ? values.map(_productImageUrl).where((e) => e.isNotEmpty).toList()
        : <String>[];
    final cover = _productImageUrl(
      product['image'] ?? product['image_url'] ?? product['thumbnail'],
    );
    if (cover.isNotEmpty && !urls.contains(cover)) urls.insert(0, cover);
    return urls.isEmpty ? [''] : urls;
  }

  double _number(dynamic value) => double.tryParse('$value') ?? 0;
  String _price(double value) =>
      '${price_fmt.formatPrice(value)} ${'currency'.tr}';

  @override
  Widget build(BuildContext context) {
    final price = _number(
      product['offer_price'] ??
          product['sale_price'] ??
          product['price'] ??
          product['original_price'],
    );
    final oldPrice = _number(product['original_price'] ?? product['old_price']);
    final rating = _number(product['rating']);
    final reviews =
        int.tryParse(
          '${product['review_count'] ?? product['reviews_count'] ?? 0}',
        ) ??
        0;
    final stock =
        int.tryParse('${product['stock'] ?? product['quantity'] ?? 0}') ?? 0;
    final name = product['name']?.toString() ?? 'Product';
    final description = product['description']?.toString() ?? '';
    final store =
        product['store_name']?.toString() ??
        product['seller_name']?.toString() ??
        'Store';

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Gallery(images: images),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ),
                  if (product['discount_percent'] != null)
                    _Badge(text: '-${product['discount_percent']}%'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Stars(rating: rating),
                  const SizedBox(width: 8),
                  Text(
                    '${rating.toStringAsFixed(1)} ($reviews ${'reviews'.tr})',
                    style: const TextStyle(
                      color: AppColor.greyText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _price(price),
                    style: const TextStyle(
                      color: AppColor.primaryColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (oldPrice > price) ...[
                    const SizedBox(width: 10),
                    Text(
                      _price(oldPrice),
                      style: const TextStyle(
                        color: AppColor.greyText,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              _StoreCard(
                name: store,
                logo: _productImageUrl(product['store_logo']),
                onChat: onChat,
              ),
              const SizedBox(height: 18),
              _InfoStrip(
                stock: stock,
                freeShipping:
                    product['free_shipping'] == true ||
                    product['free_shipping'] == 1,
              ),
              if (product['variants'] is List &&
                  (product['variants'] as List).isNotEmpty) ...[
                const SizedBox(height: 20),
                _VariantSelector(
                  variants: (product['variants'] as List)
                      .whereType<Map>()
                      .map((e) => Map<String, dynamic>.from(e))
                      .toList(),
                  selectedId: selectedVariantId,
                  onSelected: onVariantSelected,
                ),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 22),
                Text(
                  'description'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColor.greyText,
                    height: 1.65,
                    fontSize: 15,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'customer_reviews'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onReview,
                    icon: const Icon(Icons.edit_rounded, size: 17),
                    label: Text(
                      myRating == null ? 'write_review'.tr : 'edit_review'.tr,
                    ),
                  ),
                ],
              ),
              _ReviewCard(
                rating: rating,
                reviews: reviews,
                myRating: myRating,
                myComment: myComment,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 18,
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                _QuantityPicker(value: quantity, onChanged: onQuantityChanged),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    final adding =
                        Get.find<CartController>().isAddingToCart.value;
                    return FilledButton.icon(
                      onPressed: adding ? null : onAddToCart,
                      icon: adding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.shopping_bag_rounded),
                      label: Text(
                        adding ? 'adding_to_cart'.tr : 'add_to_cart'.tr,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VariantSelector extends StatelessWidget {
  final List<Map<String, dynamic>> variants;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const _VariantSelector({
    required this.variants,
    required this.selectedId,
    required this.onSelected,
  });

  String _label(Map<String, dynamic> variant) {
    final attrs = variant['attributes'];
    if (attrs is Map && attrs.isNotEmpty) {
      return attrs.values.map((value) => value.toString()).join(' / ');
    }
    return (variant['combination_key'] ?? variant['name'] ?? '').toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'choose_variant'.tr,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 9),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: variants.map((variant) {
            final id = '${variant['id'] ?? variant['combination_key'] ?? ''}';
            final selected = id == selectedId;
            final stock =
                int.tryParse(
                  '${variant['quantity'] ?? variant['stock'] ?? 0}',
                ) ??
                0;
            return ChoiceChip(
              label: Text(_label(variant)),
              selected: selected,
              onSelected: stock > 0 ? (_) => onSelected(id) : null,
              selectedColor: AppColor.primaryColor,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColor.black,
                fontWeight: FontWeight.w700,
              ),
              backgroundColor: stock > 0
                  ? Colors.white
                  : AppColor.greyBorder.withValues(alpha: 0.5),
              side: BorderSide(
                color: selected ? AppColor.primaryColor : AppColor.greyBorder,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _Gallery extends StatefulWidget {
  final List<String> images;
  const _Gallery({required this.images});
  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int current = 0;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 315,
        child: PageView.builder(
          itemCount: widget.images.length,
          onPageChanged: (v) => setState(() => current = v),
          itemBuilder: (_, i) => ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BuyerNetworkImage(
              url: widget.images[i],
              backgroundColor: AppColor.primarySurface,
              fallbackIcon: Icons.shopping_bag_outlined,
              fallbackIconSize: 58,
            ),
          ),
        ),
      ),
      if (widget.images.length > 1) ...[
        const SizedBox(height: 12),
        SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => current = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: current == i
                        ? AppColor.primaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BuyerNetworkImage(
                    url: widget.images[i],
                    backgroundColor: AppColor.primarySurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ],
  );
}

class _StoreCard extends StatelessWidget {
  final String name, logo;
  final VoidCallback onChat;
  const _StoreCard({
    required this.name,
    required this.logo,
    required this.onChat,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: AppColor.cardShadow,
    ),
    child: Row(
      children: [
        ClipOval(
          child: SizedBox(
            width: 46,
            height: 46,
            child: BuyerNetworkImage(
              url: logo,
              fallbackIcon: Icons.storefront_rounded,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'sold_by'.tr,
                style: const TextStyle(color: AppColor.greyText, fontSize: 11),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: onChat,
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
          label: Text('message_seller'.tr),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColor.primaryColor,
            side: const BorderSide(color: AppColor.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ),
  );
}

class _InfoStrip extends StatelessWidget {
  final int stock;
  final bool freeShipping;
  const _InfoStrip({required this.stock, required this.freeShipping});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _InfoItem(
          icon: Icons.local_shipping_outlined,
          title: freeShipping ? 'free_shipping'.tr : 'fast_delivery'.tr,
          color: AppColor.success,
        ),
      ),
      Expanded(
        child: _InfoItem(
          icon: Icons.inventory_2_outlined,
          title: stock > 0 ? '${'in_stock'.tr} ($stock)' : 'out_of_stock'.tr,
          color: stock > 0 ? AppColor.info : AppColor.error,
        ),
      ),
      Expanded(
        child: _InfoItem(
          icon: Icons.verified_user_outlined,
          title: 'secure_purchase'.tr,
          color: AppColor.primaryColor,
        ),
      ),
    ],
  );
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: color, size: 23),
      const SizedBox(height: 5),
      Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 2,
        style: const TextStyle(
          fontSize: 11,
          color: AppColor.greyText,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _ReviewCard extends StatelessWidget {
  final double rating;
  final int reviews;
  final double? myRating;
  final String myComment;
  const _ReviewCard({
    required this.rating,
    required this.reviews,
    required this.myRating,
    required this.myComment,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: AppColor.cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Stars(rating: rating),
                Text(
                  '$reviews ${'reviews'.tr}',
                  style: const TextStyle(
                    color: AppColor.greyText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (myRating != null) ...[
          const Divider(height: 24),
          Row(
            children: [
              _Stars(rating: myRating!),
              const SizedBox(width: 8),
              Text(
                'your_review'.tr,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          if (myComment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                myComment,
                style: const TextStyle(color: AppColor.greyText),
              ),
            ),
        ],
      ],
    ),
  );
}

class _Stars extends StatelessWidget {
  final double rating;
  const _Stars({required this.rating});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(
      5,
      (i) => Icon(
        i < rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
        color: AppColor.warning,
        size: 18,
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: AppColor.errorLight,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColor.error,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _QuantityPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _QuantityPicker({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    height: 54,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColor.greyBorder),
    ),
    child: Row(
      children: [
        IconButton(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_rounded, size: 19),
        ),
        Text(
          '$value',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add_rounded, size: 19),
        ),
      ],
    ),
  );
}

class _ReviewDraft {
  final double rating;
  final String comment;
  const _ReviewDraft(this.rating, this.comment);
}

class _ReviewSheet extends StatefulWidget {
  final double initialRating;
  final String initialComment;
  const _ReviewSheet({
    required this.initialRating,
    required this.initialComment,
  });
  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  late double rating;
  late final TextEditingController controller;
  @override
  void initState() {
    super.initState();
    rating = widget.initialRating == 0 ? 5 : widget.initialRating;
    controller = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColor.greyBorder,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'rate_product'.tr,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (i) => IconButton(
                  onPressed: () => setState(() => rating = i + 1.0),
                  icon: Icon(
                    i < rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColor.warning,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'review_hint'.tr,
              filled: true,
              fillColor: AppColor.secondBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => Get.back(
                result: _ReviewDraft(rating, controller.text.trim()),
              ),
              child: Text('publish_review'.tr),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: Text('retry'.tr)),
      ],
    ),
  );
}
