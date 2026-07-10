import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce/controller/seller/seller_chat_controller.dart';
import 'package:e_commerce/core/constant/app_text_style.dart';
import 'package:e_commerce/core/constant/color.dart';
import 'package:e_commerce/data/model/seller/chat_models.dart';
import 'package:e_commerce/link_api.dart';

// ─────────────────────────────────────────────────────────────────────────────
// شاشة إعدادات الدردشة (ردود سريعة + ردود آلية)
// ─────────────────────────────────────────────────────────────────────────────
class ChatSettingsScreen extends StatelessWidget {
  final SellerChatController ctrl;
  const ChatSettingsScreen({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColor.secondBackground,
        appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text('chat_settings'.tr,
              style: AppTextStyle.appBarTitle),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: AppTextStyle.labelLarge.copyWith(
                color: Colors.white, fontSize: 13),
            unselectedLabelStyle: AppTextStyle.labelMedium.copyWith(
                color: Colors.white60, fontSize: 13),
            tabs: [
              Tab(text: 'quick_replies_tab'.tr),
              Tab(text: 'auto_replies_tab'.tr),
              Tab(text: 'blocked_users_tab'.tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _QuickRepliesTab(ctrl: ctrl),
            _AutoRepliesTab(ctrl: ctrl),
            _BlockedUsersTab(ctrl: ctrl),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1 — الردود السريعة
// ═════════════════════════════════════════════════════════════════════════════
class _QuickRepliesTab extends StatelessWidget {
  final SellerChatController ctrl;
  const _QuickRepliesTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerChatController>(
      builder: (c) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddSheet(context, c),
          backgroundColor: AppColor.primaryColor,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('add_quick_reply'.tr,
              style: AppTextStyle.buttonSmall),
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        body: c.quickReplies.isEmpty
            ? _EmptyQuickReplies(onAdd: () => _showAddSheet(context, c))
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  // بطاقة إرشادية
                  Container(
                    padding: const EdgeInsets.all(13),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColor.primarySurface,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                          color: AppColor.primaryColor.withOpacity(0.2)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.bolt_rounded,
                          size: 18, color: AppColor.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'quick_replies_hint'.tr,
                          style: AppTextStyle.labelSmall.copyWith(
                              color: AppColor.primaryColor,
                              fontSize: 11,
                              height: 1.5),
                        ),
                      ),
                    ]),
                  ),

                  ...c.quickReplies.asMap().entries.map((e) =>
                      _QuickReplyCard(
                        reply: e.value,
                        index: e.key,
                        ctrl: c,
                        onEdit: () => _showEditSheet(context, c, e.value),
                      )),
                ],
              ),
      ),
    );
  }

  void _showAddSheet(BuildContext context, SellerChatController c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickReplyFormSheet(ctrl: c),
    );
  }

  void _showEditSheet(BuildContext context, SellerChatController c,
      QuickReplyModel reply) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickReplyFormSheet(ctrl: c, existing: reply),
    );
  }
}

// ── Quick Reply Card ──────────────────────────────────────────────────────────
class _QuickReplyCard extends StatelessWidget {
  final QuickReplyModel reply;
  final int             index;
  final SellerChatController ctrl;
  final VoidCallback    onEdit;

  const _QuickReplyCard({
    required this.reply, required this.index,
    required this.ctrl,  required this.onEdit,
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 0),
          child: Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColor.primarySurface,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.bolt_rounded,
                  size: 16, color: AppColor.primaryColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(reply.title,
                  style: AppTextStyle.labelLarge.copyWith(
                      color: AppColor.primaryColor, fontSize: 13)),
            ),
            // Edit
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: AppColor.grey),
              onPressed: onEdit,
              splashRadius: 18,
            ),
            // Delete
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColor.error),
              onPressed: () => _confirmDelete(context),
              splashRadius: 18,
            ),
          ]),
        ),
        const Divider(height: 12, indent: 14, endIndent: 14,
            color: AppColor.greyBorder),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Text(reply.content,
              style: AppTextStyle.bodySmall.copyWith(
                  fontSize: 12.5, height: 1.5)),
        ),
      ]),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('delete_quick_reply'.tr,
            style: AppTextStyle.heading3),
        content: Text('"${reply.title}"',
            style: AppTextStyle.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr,
                style: TextStyle(color: AppColor.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.error, elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Get.back();
              ctrl.deleteQuickReply(reply.id);
            },
            child: Text('delete'.tr, style: AppTextStyle.buttonSmall),
          ),
        ],
      ),
    );
  }
}

// ── Quick Reply Form Sheet ────────────────────────────────────────────────────
class _QuickReplyFormSheet extends StatefulWidget {
  final SellerChatController ctrl;
  final QuickReplyModel?     existing;
  const _QuickReplyFormSheet({required this.ctrl, this.existing});

  @override
  State<_QuickReplyFormSheet> createState() => _QuickReplyFormSheetState();
}

class _QuickReplyFormSheetState extends State<_QuickReplyFormSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  bool _loading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl   = TextEditingController(text: widget.existing?.title   ?? '');
    _contentCtrl = TextEditingController(text: widget.existing?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: AppColor.greyBorder,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 16),

        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bolt_rounded,
                size: 18, color: AppColor.primaryColor),
          ),
          const SizedBox(width: 10),
          Text(
            _isEdit ? 'edit_quick_reply'.tr : 'add_quick_reply'.tr,
            style: AppTextStyle.heading3,
          ),
        ]),
        const SizedBox(height: 18),

        _FieldLabel('quick_reply_title'.tr),
        const SizedBox(height: 6),
        TextField(
          controller: _titleCtrl,
          style: AppTextStyle.inputText,
          decoration: _inputDeco('quick_reply_title_hint'.tr,
              Icons.title_rounded),
        ),
        const SizedBox(height: 14),

        _FieldLabel('quick_reply_content'.tr),
        const SizedBox(height: 6),
        TextField(
          controller: _contentCtrl,
          maxLines: 4,
          style: AppTextStyle.inputText,
          decoration: _inputDeco('quick_reply_content_hint'.tr,
              Icons.message_outlined),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _loading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text(
                    _isEdit ? 'save_changes'.tr : 'add_quick_reply'.tr,
                    style: AppTextStyle.buttonLarge),
          ),
        ),
      ]),
    );
  }

  Future<void> _save() async {
    final title   = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) {
      Get.snackbar('warning'.tr, 'fill_all_fields'.tr,
          backgroundColor: AppColor.errorLight,
          colorText: AppColor.errorDark,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
      return;
    }
    setState(() => _loading = true);
    if (_isEdit) {
      await widget.ctrl.updateQuickReply(widget.existing!.id, title, content);
    } else {
      await widget.ctrl.addQuickReply(title, content);
    }
    if (mounted) { setState(() => _loading = false); Get.back(); }
  }
}

// ── Empty Quick Replies ───────────────────────────────────────────────────────
class _EmptyQuickReplies extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyQuickReplies({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 76, height: 76,
        decoration: BoxDecoration(
          color: AppColor.primarySurface,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.bolt_rounded,
            size: 36, color: AppColor.primaryColor),
      ),
      const SizedBox(height: 16),
      Text('no_quick_replies'.tr,
          style: AppTextStyle.heading3.copyWith(color: AppColor.grey)),
      const SizedBox(height: 6),
      Text('add_quick_reply_hint'.tr,
          style: AppTextStyle.bodyMedium, textAlign: TextAlign.center),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('add_quick_reply'.tr, style: AppTextStyle.buttonMedium),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    ]),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2 — الردود الآلية
// ═════════════════════════════════════════════════════════════════════════════
class _AutoRepliesTab extends StatelessWidget {
  final SellerChatController ctrl;
  const _AutoRepliesTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerChatController>(
      builder: (c) => ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // بطاقة إرشادية
          Container(
            padding: const EdgeInsets.all(13),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColor.infoLight,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColor.info.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 17, color: AppColor.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'auto_replies_hint'.tr,
                    style: AppTextStyle.labelSmall.copyWith(
                        color: AppColor.infoDark, fontSize: 11, height: 1.5),
                  ),
                ),
              ],
            ),
          ),

          ...c.autoReplies.map((ar) => _AutoReplyCard(
            autoReply: ar,
            ctrl: c,
            onEdit: () => _showEditSheet(context, c, ar),
          )),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, SellerChatController c,
      AutoReplyModel ar) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AutoReplyFormSheet(ctrl: c, autoReply: ar),
    );
  }
}

// ── Auto Reply Card ───────────────────────────────────────────────────────────
class _AutoReplyCard extends StatelessWidget {
  final AutoReplyModel       autoReply;
  final SellerChatController ctrl;
  final VoidCallback         onEdit;

  const _AutoReplyCard({
    required this.autoReply, required this.ctrl, required this.onEdit,
  });

  IconData get _icon {
    switch (autoReply.trigger) {
      case 'welcome':      return Icons.waving_hand_rounded;
      case 'away':         return Icons.access_time_rounded;
      case 'instant_ack':  return Icons.check_circle_outline_rounded;
      default:             return Icons.auto_awesome_rounded;
    }
  }

  Color get _color {
    switch (autoReply.trigger) {
      case 'welcome':     return AppColor.success;
      case 'away':        return AppColor.warning;
      case 'instant_ack': return AppColor.info;
      default:            return AppColor.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColor.cardShadow,
        border: Border.all(
          color: autoReply.isEnabled
              ? _color.withOpacity(0.25)
              : AppColor.greyBorder,
          width: autoReply.isEnabled ? 1.2 : 0.8,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 0),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: autoReply.isEnabled
                    ? _color.withOpacity(0.12)
                    : AppColor.secondBackground,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(_icon,
                  size: 20,
                  color: autoReply.isEnabled ? _color : AppColor.greyLight),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('auto_reply_${autoReply.trigger}'.tr,
                    style: AppTextStyle.labelLarge.copyWith(fontSize: 14)),
                Text('auto_reply_${autoReply.trigger}_desc'.tr,
                    style: AppTextStyle.labelSmall.copyWith(fontSize: 11)),
              ]),
            ),
            Switch.adaptive(
              value: autoReply.isEnabled,
              onChanged: (v) => ctrl.toggleAutoReply(autoReply.id, v),
              activeColor: _color,
            ),
          ]),
        ),

        if (autoReply.isEnabled) ...[
          const Divider(
              height: 14, indent: 14, endIndent: 14,
              color: AppColor.greyBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Text(autoReply.content,
                style: AppTextStyle.bodySmall.copyWith(
                    fontSize: 12.5, height: 1.5, color: AppColor.grey)),
          ),

          if (autoReply.trigger == 'away' &&
              autoReply.startTime != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Row(children: [
                const Icon(Icons.schedule_rounded,
                    size: 13, color: AppColor.greyLight),
                const SizedBox(width: 5),
                Text(
                  '${'working_hours'.tr}: ${autoReply.startTime} — ${autoReply.endTime}',
                  style: AppTextStyle.labelSmall.copyWith(fontSize: 11),
                ),
              ]),
            ),
          ],

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _color.withOpacity(0.2)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.edit_outlined, size: 14, color: _color),
                  const SizedBox(width: 6),
                  Text('edit_reply'.tr,
                      style: AppTextStyle.chip.copyWith(
                          color: _color, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
        ] else
          const SizedBox(height: 13),
      ]),
    );
  }
}

// ── Auto Reply Form Sheet ─────────────────────────────────────────────────────
class _AutoReplyFormSheet extends StatefulWidget {
  final SellerChatController ctrl;
  final AutoReplyModel       autoReply;
  const _AutoReplyFormSheet({required this.ctrl, required this.autoReply});

  @override
  State<_AutoReplyFormSheet> createState() => _AutoReplyFormSheetState();
}

class _AutoReplyFormSheetState extends State<_AutoReplyFormSheet> {
  late TextEditingController _contentCtrl;
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _contentCtrl = TextEditingController(text: widget.autoReply.content);
    _startCtrl   = TextEditingController(
        text: widget.autoReply.startTime ?? '09:00');
    _endCtrl     = TextEditingController(
        text: widget.autoReply.endTime   ?? '21:00');
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isAway = widget.autoReply.trigger == 'away';

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: AppColor.greyBorder,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 16),

        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColor.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 18, color: AppColor.primaryColor),
          ),
          const SizedBox(width: 10),
          Text('edit_auto_reply'.tr, style: AppTextStyle.heading3),
        ]),
        const SizedBox(height: 18),

        _FieldLabel('auto_reply_content_label'.tr),
        const SizedBox(height: 6),
        TextField(
          controller: _contentCtrl,
          maxLines: 4,
          style: AppTextStyle.inputText,
          decoration: _inputDeco('auto_reply_content_hint'.tr,
              Icons.message_outlined),
        ),

        if (isAway) ...[
          const SizedBox(height: 14),
          _FieldLabel('working_hours'.tr),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _startCtrl,
                style: AppTextStyle.inputText,
                keyboardType: TextInputType.datetime,
                decoration: _inputDeco('from'.tr, Icons.schedule_rounded),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('—', style: TextStyle(color: AppColor.grey)),
            ),
            Expanded(
              child: TextField(
                controller: _endCtrl,
                style: AppTextStyle.inputText,
                keyboardType: TextInputType.datetime,
                decoration: _inputDeco('to'.tr, Icons.schedule_outlined),
              ),
            ),
          ]),
        ],

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor, elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _loading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                : Text('save_changes'.tr, style: AppTextStyle.buttonLarge),
          ),
        ),
      ]),
    );
  }

  Future<void> _save() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      Get.snackbar('warning'.tr, 'fill_all_fields'.tr,
          backgroundColor: AppColor.errorLight,
          colorText: AppColor.errorDark,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
      return;
    }
    setState(() => _loading = true);
    final updated = widget.autoReply.copyWith(
      content:   content,
      startTime: _startCtrl.text.trim().isEmpty ? null : _startCtrl.text.trim(),
      endTime:   _endCtrl.text.trim().isEmpty   ? null : _endCtrl.text.trim(),
    );
    await widget.ctrl.updateAutoReply(updated);
    if (mounted) { setState(() => _loading = false); Get.back(); }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(label,
      style: AppTextStyle.inputLabel.copyWith(fontWeight: FontWeight.w600));
}

InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
  hintText: hint,
  hintStyle: AppTextStyle.inputHint,
  prefixIcon: Icon(icon, size: 18, color: AppColor.grey),
  filled: true,
  fillColor: AppColor.secondBackground,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColor.greyBorder)),
  enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColor.greyBorder)),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColor.primaryColor, width: 1.5)),
);

// QuickReplyModel & AutoReplyModel are imported from chat_models.dart

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — المستخدمين المحظورين
// ─────────────────────────────────────────────────────────────────────────────
class _BlockedUsersTab extends StatelessWidget {
  final SellerChatController ctrl;
  const _BlockedUsersTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerChatController>(
      builder: (c) => Scaffold(
        backgroundColor: AppColor.secondBackground,
        body: c.blockedUsers.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block_rounded, size: 64, color: AppColor.greyLight.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    Text(
                      'no_blocked_users'.tr,
                      style: AppTextStyle.bodyMedium.copyWith(color: AppColor.greyLight),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: c.blockedUsers.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColor.greyBorder),
                itemBuilder: (context, index) {
                  final blockedRecord = c.blockedUsers[index];
                  final blockedUser = blockedRecord['blocked'] ?? {};
                  final firstName = blockedUser['first_name'] ?? '';
                  final lastName = blockedUser['last_name'] ?? '';
                  final name = '$firstName $lastName'.trim().isNotEmpty ? '$firstName $lastName' : 'User #${blockedRecord['blocked_id']}';
                  final email = blockedUser['email'] ?? '';
                  final avatar = blockedUser['profile_photo'];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppColor.primarySurface,
                      backgroundImage: avatar != null ? NetworkImage(AppLink.storageUrl(avatar)) : null,
                      child: avatar == null ? const Icon(Icons.person_rounded, color: AppColor.primaryColor) : null,
                    ),
                    title: Text(name, style: AppTextStyle.labelLarge.copyWith(fontSize: 14)),
                    subtitle: email.isNotEmpty ? Text(email, style: AppTextStyle.labelSmall.copyWith(color: AppColor.greyLight)) : null,
                    trailing: TextButton(
                      onPressed: () => _confirmUnblock(context, c, blockedRecord['blocked_id']),
                      child: Text('unblock'.tr, style: AppTextStyle.labelLarge.copyWith(fontSize: 14, color: Colors.red)),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _confirmUnblock(BuildContext context, SellerChatController c, dynamic userId) {
    int id = int.tryParse(userId.toString()) ?? 0;
    if (id == 0) return;
    Get.defaultDialog(
      title: 'Alert'.tr,
      middleText: 'unblock_confirm'.tr,
      textCancel: 'cancel'.tr,
      textConfirm: 'confirm'.tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        c.unblockUser(id);
        Get.back();
        Get.snackbar('success'.tr, 'unblocked_success'.tr, backgroundColor: Colors.green, colorText: Colors.white);
      },
    );
  }
}

