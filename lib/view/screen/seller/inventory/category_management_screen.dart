import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_inventory_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/inventory_models.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerInventoryController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text('category_management'.tr, style: AppTextStyle.appBarTitle),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              onPressed: () => _showSheet(context, ctrl, null, null),
            ),
          ],
        ),
        body: ctrl.categoryTree.isEmpty
            ? _EmptyView(ctrl: ctrl)
            : _CategoryTreeView(ctrl: ctrl),
      ),
    );
  }

  static void _showSheet(
      BuildContext context,
      SellerInventoryController ctrl,
      CategoryModel? existing,
      int? parentId,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEditSheet(ctrl: ctrl, existing: existing, parentId: parentId),
    );
  }
}

class _CategoryTreeView extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _CategoryTreeView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: ctrl.refreshCategories,
      color: AppColor.primaryColor,
      backgroundColor: Colors.white,
      child: ReorderableListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        itemCount: ctrl.categoryTree.length,
        onReorder: (oldIndex, newIndex) {
          ctrl.reorderRootCategories(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final cat = ctrl.categoryTree[index];
          return _TreeNode(
            key: ValueKey(cat.id),
            ctrl: ctrl,
            category: cat,
            depth: 0,
          );
        },
      ),
    );
  }
}

class _TreeNode extends StatefulWidget {
  final SellerInventoryController ctrl;
  final CategoryModel category;
  final int depth;
  const _TreeNode({super.key,
    required this.ctrl,
    required this.category,
    required this.depth});

  @override
  State<_TreeNode> createState() => _TreeNodeState();
}

class _TreeNodeState extends State<_TreeNode> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final d = widget.depth;
    final hasChildren = cat.hasChildren;
    final maxDepth = d < 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(
            bottom: 8,
            left: d * 20.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: d == 0
                  ? AppColor.primaryColor.withOpacity(0.2)
                  : d == 1
                  ? AppColor.greyBorder
                  : AppColor.greyBorder.withOpacity(0.5),
              width: d == 0 ? 1 : 0.8,
            ),
            boxShadow: d == 0 ? AppColor.cardShadow : null,
          ),
          child: Column(children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: hasChildren ? () => setState(() => _expanded = !_expanded) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: d == 0
                          ? AppColor.primarySurface
                          : d == 1
                          ? AppColor.secondBackground
                          : AppColor.greyBorder.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hasChildren ? Icons.folder_outlined : Icons.label_outline_rounded,
                      size: 16,
                      color: d == 0 ? AppColor.primaryColor : AppColor.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(cat.name, style: AppTextStyle.labelLarge.copyWith(fontSize: 13)),
                      Text(
                        hasChildren
                            ? '${cat.children.length} ${'subcategories_lbl'.tr}'
                            : '${cat.productCount} ${'products_count'.tr}',
                        style: AppTextStyle.labelSmall.copyWith(fontSize: 10),
                      ),
                    ]),
                  ),
                  if (hasChildren)
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18, color: AppColor.grey),
                    ),
                  const SizedBox(width: 4),
                  _NodeActions(
                    ctrl: widget.ctrl,
                    category: cat,
                    canAddChild: maxDepth,
                  ),
              if (d == 0) ...[
             const SizedBox(width: 8),
             const Icon(Icons.drag_indicator_rounded, color: AppColor.greyLight, size: 20),]
                ]),
              ),
            ),
          ]),
        ),
        if (hasChildren && _expanded)
          ...cat.children.map((child) => _TreeNode(
            key: ValueKey(child.id),
            ctrl: widget.ctrl,
            category: child,
            depth: d + 1,
          )),
      ],
    );
  }
}

class _NodeActions extends StatelessWidget {
  final SellerInventoryController ctrl;
  final CategoryModel category;
  final bool canAddChild;
  const _NodeActions({
    required this.ctrl,
    required this.category,
    required this.canAddChild,
  });

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    if (canAddChild)
      _ActionBtn(
        icon: Icons.add_rounded,
        color: AppColor.success,
        bg: AppColor.successLight,
        onTap: () => CategoryManagementScreen._showSheet(
            context, ctrl, null, category.id),
      ),
    const SizedBox(width: 4),
    _ActionBtn(
      icon: Icons.edit_outlined,
      color: AppColor.primaryColor,
      bg: AppColor.primarySurface,
      onTap: () =>
          CategoryManagementScreen._showSheet(context, ctrl, category, category.parentId),
    ),
    const SizedBox(width: 4),
    _ActionBtn(
      icon: Icons.delete_outline_rounded,
      color: AppColor.error,
      bg: AppColor.errorLight,
      onTap: () => _confirmDelete(context, ctrl, category),
    ),
  ]);

  void _confirmDelete(
      BuildContext context, SellerInventoryController ctrl, CategoryModel cat) {
    if (cat.productCount > 0) {
      Get.snackbar(
        'warning'.tr,
        'cannot_delete_with_products'.tr,
        backgroundColor: AppColor.warningLight,
        colorText: AppColor.warningDark,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('delete_category_title'.tr, style: AppTextStyle.heading3),
        content: Text(
          '"${cat.name}"',
          style: AppTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr,
                style: AppTextStyle.buttonSmall.copyWith(color: AppColor.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.deleteCategory(cat);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('delete'.tr, style: AppTextStyle.buttonSmall),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.bg, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
      child: Icon(icon, size: 14, color: color),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _EmptyView({required this.ctrl});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.category_outlined, size: 56, color: AppColor.greyLight),
      const SizedBox(height: 14),
      Text('add_first_category'.tr,
          style: AppTextStyle.heading3.copyWith(color: AppColor.grey)),
      const SizedBox(height: 8),
      Text('tap_plus_to_add'.tr, style: AppTextStyle.bodyMedium),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: () => CategoryManagementScreen._showSheet(context, ctrl, null, null),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('add_category_btn'.tr, style: AppTextStyle.buttonMedium),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    ]),
  );
}

class _AddEditSheet extends StatefulWidget {
  final SellerInventoryController ctrl;
  final CategoryModel? existing;
  final int? parentId;
  const _AddEditSheet({required this.ctrl, this.existing, this.parentId});

  @override
  State<_AddEditSheet> createState() => _AddEditSheetState();
}

class _AddEditSheetState extends State<_AddEditSheet> {
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _nameCtrl.text = widget.existing!.name;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColor.greyBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColor.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.category_outlined, size: 18, color: AppColor.primaryColor),
            ),
            const SizedBox(width: 10),
            Text(
              _isEdit
                  ? 'edit_category'.tr
                  : widget.parentId != null
                  ? 'add_subcategory'.tr
                  : 'add_main_category'.tr,
              style: AppTextStyle.heading3,
            ),
          ]),
          const SizedBox(height: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('category_name_label'.tr, style: AppTextStyle.inputLabel),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              style: AppTextStyle.inputText,
              decoration: InputDecoration(
                hintText: 'category_name_hint_text'.tr,
                hintStyle: AppTextStyle.inputHint,
                filled: true,
                fillColor: AppColor.secondBackground,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColor.greyBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColor.greyBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColor.primaryColor, width: 1.5),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text(
                _isEdit ? 'save_category_btn'.tr : 'add_category_submit'.tr,
                style: AppTextStyle.buttonLarge,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        'warning'.tr, 'category_name_required'.tr,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    setState(() => _loading = true);
    if (_isEdit) {
      await widget.ctrl.updateCategory(widget.existing!.id, name);
    } else {
      await widget.ctrl.addCategory(name, widget.parentId);
    }
    if (mounted) Get.back();
  }
}
