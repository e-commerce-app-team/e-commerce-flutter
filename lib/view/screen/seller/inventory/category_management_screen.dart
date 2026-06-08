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
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text('إدارة الأقسام', style: AppTextStyle.appBarTitle),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 24),
              onPressed: () =>
                  _showAddEditSheet(context, ctrl, null),
            ),
          ],
        ),
        body: ctrl.categories.isEmpty
            ? _EmptyCategories(ctrl: ctrl)
            : _CategoriesList(ctrl: ctrl),
      ),
    );
  }

  void _showAddEditSheet(
    BuildContext context,
    SellerInventoryController ctrl,
    CategoryModel? existing,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEditCategorySheet(
        ctrl: ctrl,
        existing: existing,
      ),
    );
  }
}

class _CategoriesList extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _CategoriesList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: ctrl.categories.length,
      onReorder: ctrl.reorderCategory,
      proxyDecorator: (child, index, animation) => Material(
        elevation: 6,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: child,
      ),
      itemBuilder: (_, i) {
        final cat = ctrl.categories[i];
        return _CategoryTile(
          key: ValueKey(cat.id),
          category: cat,
          index: i,
          onEdit:   () => _showAddEditSheet(context, ctrl, cat),
          onToggle: () => ctrl.toggleCategoryVisibility(cat),
          onDelete: () => _confirmDelete(context, ctrl, cat),
        );
      },
    );
  }

  void _showAddEditSheet(
    BuildContext context,
    SellerInventoryController ctrl,
    CategoryModel? existing,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEditCategorySheet(
        ctrl: ctrl,
        existing: existing,
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    SellerInventoryController ctrl,
    CategoryModel cat,
  ) {
    if (cat.productCount > 0) {
      Get.snackbar(
        'تنبيه',
        'لا يمكن حذف قسم يحتوي على ${cat.productCount} منتج',
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('حذف القسم', style: AppTextStyle.heading3),
        content: Text(
          'هل أنت متأكد من حذف قسم "${cat.name}"؟',
          style: AppTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء',
                style: AppTextStyle.buttonSmall
                    .copyWith(color: AppColor.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.deleteCategory(cat);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('حذف', style: AppTextStyle.buttonSmall),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final int           index;
  final VoidCallback  onEdit;
  final VoidCallback  onToggle;
  final VoidCallback  onDelete;

  const _CategoryTile({
    required super.key,
    required this.category,
    required this.index,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColor.cardShadow,
        border: Border.all(color: AppColor.greyBorder, width: 0.8),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: const Icon(Icons.drag_handle_rounded,
            color: AppColor.greyLight, size: 22),

        title: Text(
          category.name,
          style: AppTextStyle.labelLarge.copyWith(fontSize: 14),
        ),
        subtitle: Text(
          '${category.productCount} منتج',
          style: AppTextStyle.labelSmall.copyWith(fontSize: 11),
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColor.secondBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: AppColor.grey,
                ),
              ),
            ),
            const SizedBox(width: 8),

            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColor.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_outlined,
                    size: 18, color: AppColor.primaryColor),
              ),
            ),
            const SizedBox(width: 8),

            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColor.errorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColor.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  final SellerInventoryController ctrl;
  const _EmptyCategories({required this.ctrl});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.category_outlined,
          size: 60, color: AppColor.greyLight),
      const SizedBox(height: 14),
      Text('لا توجد أقسام بعد',
          style: AppTextStyle.heading3.copyWith(color: AppColor.grey)),
      const SizedBox(height: 8),
      Text('اضغط + لإضافة قسم جديد',
          style: AppTextStyle.bodyMedium),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _AddEditCategorySheet(ctrl: ctrl, existing: null),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('إضافة قسم', style: AppTextStyle.buttonMedium),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor, elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 12),
        ),
      ),
    ]),
  );
}

class _AddEditCategorySheet extends StatefulWidget {
  final SellerInventoryController ctrl;
  final CategoryModel?            existing;
  const _AddEditCategorySheet({required this.ctrl, this.existing});

  @override
  State<_AddEditCategorySheet> createState() =>
      _AddEditCategorySheetState();
}

class _AddEditCategorySheetState extends State<_AddEditCategorySheet> {
  final _nameCtrl = TextEditingController();
  int?  _parentId;
  bool  _isLoading = false;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameCtrl.text = widget.existing!.name;
      _parentId      = widget.existing!.parentId;
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
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
              child: const Icon(Icons.category_outlined,
                  size: 18, color: AppColor.primaryColor),
            ),
            const SizedBox(width: 10),
            Text(
              isEdit ? 'تعديل القسم' : 'إضافة قسم جديد',
              style: AppTextStyle.heading3,
            ),
          ]),
          const SizedBox(height: 20),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('اسم القسم *', style: AppTextStyle.inputLabel),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              style: AppTextStyle.inputText,
              decoration: InputDecoration(
                hintText: 'مثال: إكسسوارات',
                hintStyle: AppTextStyle.inputHint,
                filled: true, fillColor: AppColor.secondBackground,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColor.greyBorder)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColor.greyBorder)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColor.primaryColor, width: 1.5)),
              ),
            ),
          ]),
          const SizedBox(height: 14),

          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('قسم رئيسي (اختياري)',
                style: AppTextStyle.inputLabel),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColor.secondBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.greyBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<int?>(
                    value: _parentId,
                    isExpanded: true,
                    hint: Text('بدون قسم رئيسي',
                        style: AppTextStyle.inputHint),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColor.grey),
                    borderRadius: BorderRadius.circular(12),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('بدون قسم رئيسي'),
                      ),
                      ...widget.ctrl.categories
                          .where((c) => c.id != widget.existing?.id)
                          .map((c) => DropdownMenuItem<int?>(
                                value: c.id,
                                child: Text(c.name),
                              )),
                    ],
                    onChanged: (v) => setState(() => _parentId = v),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Text(
                      isEdit ? 'حفظ التعديلات' : 'إضافة القسم',
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
      Get.snackbar('تنبيه', 'اسم القسم مطلوب',
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16));
      return;
    }
    setState(() => _isLoading = true);
    if (isEdit) {
      await widget.ctrl.updateCategory(widget.existing!, name, _parentId);
    } else {
      await widget.ctrl.addCategory(name, _parentId);
    }
    if (mounted) Get.back();
  }
}
