import 'package:dartz/dartz.dart' show Either;
import 'package:e_commerce/core/class/crud.dart';
import 'package:e_commerce/core/class/status_request.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/core/services/services.dart';
import 'package:e_commerce/link_api.dart';
import 'package:e_commerce/view/widget/buyer/shared/buyer_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuyerProductDetailScreen extends StatefulWidget {
  const BuyerProductDetailScreen({super.key});

  @override
  State<BuyerProductDetailScreen> createState() => _BuyerProductDetailScreenState();
}

class _BuyerProductDetailScreenState extends State<BuyerProductDetailScreen> {
  final Crud _crud = Crud();
  Map<String, dynamic>? _product;
  bool _loading = true;
  bool _favorite = false;
  String? _error;

  String get _id => (Get.arguments is Map
          ? Get.arguments['product_id']
          : Get.arguments)
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
    _load();
  }

  Future<void> _load() async {
    final Either<StatusRequest, Map> result =
        await _crud.getData(AppLink.buyerProductDetails(_id));
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _loading = false;
        _error = 'Product data could not be loaded.';
      }),
      (response) {
        final raw = response['data'];
        final data = raw is Map && raw['product'] is Map ? raw['product'] : raw;
        setState(() {
          _loading = false;
          _product = data is Map ? Map<String, dynamic>.from(data) : null;
          _favorite = _product?['is_favorite'] == true;
          _error = _product == null ? 'Product is not available.' : null;
        });
      },
    );
    _crud.postData(AppLink.buyerProductView(_id), {});
  }

  Future<void> _toggleFavorite() async {
    final token = _token;
    if (token == null) {
      Get.snackbar('Sign in required', 'Sign in to save products.');
      return;
    }
    final result = await _crud.postData(
      AppLink.buyerToggleFavorite(_id),
      {},
      headers: {'Authorization': 'Bearer $token'},
    );
    result.fold((_) {}, (response) {
      if (!mounted) return;
      setState(() => _favorite = response['is_favorite'] == true);
    });
  }

  Future<void> _addToCart() async {
    final token = _token;
    if (token == null) {
      Get.snackbar('Sign in required', 'Sign in to add products to your cart.');
      return;
    }
    final result = await _crud.postData(
      AppLink.buyerCartAdd,
      {'product_id': _id, 'qty': 1},
      headers: {'Authorization': 'Bearer $token'},
    );
    result.fold(
      (_) => Get.snackbar('Cart', 'The product could not be added.'),
      (_) => Get.snackbar('Cart', 'Product added to your cart.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundScaffold,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundScaffold,
        elevation: 0,
        leading: IconButton(onPressed: Get.back, icon: const Icon(Icons.arrow_back)),
        actions: [
          IconButton(
            tooltip: 'Save product',
            onPressed: _toggleFavorite,
            icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border,
                color: _favorite ? AppColor.error : AppColor.black),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : _ProductBody(product: _product!, onAddToCart: _addToCart),
    );
  }
}

class _ProductBody extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAddToCart;
  const _ProductBody({required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final image = product['image']?.toString() ?? product['image_url']?.toString();
    final price = product['offer_price'] ?? product['price'] ?? product['original_price'] ?? 0;
    final oldPrice = product['original_price'];
    final name = product['name']?.toString() ?? 'Product';
    final description = product['description']?.toString() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 320,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BuyerNetworkImage(url: image ?? ''),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$price',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColor.primaryColor,
                ),
              ),
              if (oldPrice != null && oldPrice.toString() != price.toString()) ...[
                const SizedBox(width: 10),
                Text(
                  '$oldPrice',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: AppColor.greyText,
                  ),
                ),
              ],
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              description,
              style: const TextStyle(color: AppColor.greyText, height: 1.6),
            ),
          ],
          const SizedBox(height: 26),
          SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAddToCart,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Add to cart'),
            ),
          ),
        ],
      ),
    );
  }
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
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
}
