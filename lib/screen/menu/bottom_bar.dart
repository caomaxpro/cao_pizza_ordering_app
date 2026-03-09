import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // <-- thêm

class BottomBar extends StatefulWidget {
  final bool isOpen;
  final List<Map<String, dynamic>> cartItems;
  final double total;
  final int count;
  final VoidCallback onToggle;
  final VoidCallback? onCheckout;
  final void Function(String id, int delta) onChangeQty;
  final void Function(String id)? onItemDetails;

  const BottomBar({
    super.key,
    required this.isOpen,
    required this.cartItems,
    required this.total,
    required this.count,
    required this.onToggle,
    required this.onChangeQty,
    this.onCheckout,
    this.onItemDetails,
  });

  static const Color bg = Color(0xFF202020);
  static const Color card = Color(0xFF2B2B2B);
  static const Color accent = Color(0xFFE87C1E);
  static const Color accentSoft = Color(0x33E87C1E);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  bool _showContent = false;

  @override
  void didUpdateWidget(covariant BottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isOpen && oldWidget.isOpen) {
      setState(() => _showContent = false);
    }
  }

  void _onAnimationEnd() {
    if (widget.isOpen && !_showContent) {
      setState(() => _showContent = true);
    }
  }

  Future<void> _editQty(BuildContext context, String id, int currentQty) async {
    final controller = TextEditingController(text: currentQty.toString());

    final int? targetQty = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: BottomBar.card,
          title: const Text(
            'Set quantity',
            style: TextStyle(color: BottomBar.accent),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter quantity',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                Navigator.pop(context, parsed);
              },
              child: const Text(
                'Apply',
                style: TextStyle(color: BottomBar.accent),
              ),
            ),
          ],
        );
      },
    );

    if (targetQty == null) return;
    final safeQty = targetQty < 0 ? 0 : targetQty;
    final delta = safeQty - currentQty;
    if (delta != 0) {
      widget.onChangeQty(id, delta); // dùng delta để set về số mới
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      height: widget.isOpen ? 320.0 : 100.0,
      decoration: const BoxDecoration(
        color: BottomBar.bg,
        border: Border(top: BorderSide(color: BottomBar.accent, width: 2)),
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      onEnd: _onAnimationEnd,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: widget.onToggle,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: AnimatedRotation(
                      turns: widget.isOpen ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 260),
                      child: const Icon(
                        Icons.keyboard_arrow_up,
                        color: BottomBar.accent,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Item Total',
                        style: TextStyle(
                          color: BottomBar.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${widget.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: BottomBar.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: BottomBar.accentSoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: BottomBar.accent),
                    ),
                    child: Text(
                      'x${widget.count}',
                      style: const TextStyle(
                        color: BottomBar.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BottomBar.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onPressed: widget.onCheckout,
                    child: Text(
                      widget.count > 1 ? 'Grab them' : 'Grab it',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            if (_showContent) ...[
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedOpacity(
                  opacity: _showContent ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: widget.cartItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Cart is empty',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: widget.cartItems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final it = widget.cartItems[index];
                            final id = it['id'] as String;
                            final qty = (it['qty'] as int?) ?? 0;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: BottomBar.card,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: BottomBar.accentSoft),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: widget.onItemDetails == null
                                          ? null
                                          : () => widget.onItemDetails!(id),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            it['name'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            it['price'] ?? '',
                                            style: const TextStyle(
                                              color: BottomBar.accent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _QtyBtn(
                                        icon: Icons.remove,
                                        onTap: () => widget.onChangeQty(id, -1),
                                      ),
                                      GestureDetector(
                                        onTap: () => _editQty(context, id, qty),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: BottomBar.accentSoft,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: BottomBar.accent,
                                            ),
                                          ),
                                          child: Text(
                                            '$qty',
                                            style: const TextStyle(
                                              color: BottomBar.accent,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                      _QtyBtn(
                                        icon: Icons.add,
                                        onTap: () => widget.onChangeQty(id, 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0x33E87C1E),
          shape: BoxShape.circle,
          border: Border.all(color: BottomBar.accent),
        ),
        child: Icon(icon, size: 16, color: BottomBar.accent),
      ),
    );
  }
}
