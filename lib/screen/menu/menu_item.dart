import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pizza_ordering_app/widgets/folding_qty_control.dart';

class MenuItemWidget extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final String price;
  final int qty;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onCustomize;
  final VoidCallback? onDetails;
  final bool isSelected;

  const MenuItemWidget({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.qty = 0,
    this.onTap,
    this.onAdd,
    this.onRemove,
    this.onCustomize,
    this.onDetails,
    this.isSelected = false,
  });

  static const Color _bg = Color(0xFF2C2C2C);
  static const Color _card = Color(0xFF3C3C3C);
  static const Color _accent = Color(0xFFE87C1E);

  @override
  State<MenuItemWidget> createState() => _MenuItemWidgetState();
}

class _MenuItemWidgetState extends State<MenuItemWidget>
    with TickerProviderStateMixin {
  // controls whether extra buttons are actually rendered/enabled.
  // will be set true only after expansion animation finishes.
  bool _showExtraButtons = false;

  static const double collapsedHeight = 140;
  static const double expandedHeight = 190;

  // controller for the smooth +Add -> [ - | qty | + ] animation
  late final AnimationController _qtyController;
  late final Animation<double> _minusScale;
  late final Animation<double> _countScale;
  late final Animation<double> _plusScale;
  late final Animation<double> _widthFactor;

  @override
  void initState() {
    super.initState();
    // if already selected on mount, show extras after build (so buttons won't flash before animation)
    _showExtraButtons = widget.isSelected;

    _qtyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // staggered scales so pieces "merge"/"unfold" sequentially
    _minusScale = CurvedAnimation(
      parent: _qtyController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _countScale = CurvedAnimation(
      parent: _qtyController,
      curve: const Interval(0.15, 0.75, curve: Curves.easeOut),
    );
    _plusScale = CurvedAnimation(
      parent: _qtyController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    // width expands from 0 to 1 to reveal the three pieces
    _widthFactor = CurvedAnimation(
      parent: _qtyController,
      curve: Curves.easeOut,
    );

    if (widget.qty > 0) {
      _qtyController.value = 1.0;
    } else {
      _qtyController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant MenuItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      // when selection changes, hide extras immediately and wait for animation end to show them
      if (!mounted) return;
      setState(() {
        _showExtraButtons = false;
      });
    }

    // trigger qty animation when crossing between 0 and >0
    if (oldWidget.qty == 0 && widget.qty > 0) {
      _qtyController.forward();
    } else if (oldWidget.qty > 0 && widget.qty == 0) {
      _qtyController.reverse();
    } else if (oldWidget.qty != widget.qty && widget.qty > 0) {
      // keep controller completed but update UI (count text will update)
      if (!_qtyController.isCompleted) _qtyController.forward();
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _onAnimatedEnd() {
    if (!mounted) return;
    if (widget.isSelected && !_showExtraButtons) {
      setState(() => _showExtraButtons = true);
    } else if (!widget.isSelected && _showExtraButtons) {
      setState(() => _showExtraButtons = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // keep top area fixed so name/price/qty don't move when card expands
    const double topPadding = 12;
    const double bottomPadding = 12;
    final double topAreaHeight = collapsedHeight - (topPadding + bottomPadding);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        height: widget.isSelected ? expandedHeight : collapsedHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: MenuItemWidget._bg,
          borderRadius: BorderRadius.circular(12),
          border: widget.isSelected
              ? Border.all(color: MenuItemWidget._accent, width: 2)
              : null,
        ),
        onEnd: _onAnimatedEnd,
        child: Stack(
          children: [
            // fixed top area: image + info + price/qty controls
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: topAreaHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // image left
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: MenuItemWidget._card,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: SvgPicture.asset(
                          'assets/svg/pizza.svg',
                          width: 52,
                          height: 52,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            widget.isSelected
                                ? MenuItemWidget._accent
                                : Colors.grey,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // info + price/qty (kept inside fixed box so they don't move)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // top text info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: TextStyle(
                                  color: widget.isSelected
                                      ? MenuItemWidget._accent
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp, // tăng từ 16
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13.sp, // tăng từ 12
                                ),
                              ),
                            ],
                          ),

                          // bottom controls inside the top area (stable)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.price,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp, // tăng từ default
                                ),
                              ),

                              // smooth transition between "+ Add" and qty controls with merge animation
                              // we keep an AnimatedSwitcher to cross-fade between the single add button and the expanding three-piece control.
                              // use reusable FoldingQtyControl sized to match card controls
                              FoldingQtyControl(
                                // key is the reason that cause the reset
                                key: ValueKey('folding_${widget.id}'),
                                qty: widget.qty,
                                onAdd: widget.onAdd,
                                onRemove: widget.onRemove,
                                onQtyChanged: (n) {},
                                fontSize: 14.sp,
                                panelWidth: 35.sp,
                                panelHeight: 30.sp,
                                panelGap: 3.sp,
                                open: widget.isSelected || widget.qty > 0,
                                onOpenChanged: (isOpen) {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // extra buttons shown only after expansion animation finished
            if (_showExtraButtons &&
                (widget.onCustomize != null || widget.onDetails != null))
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.onCustomize != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: MenuItemWidget._accent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: widget.onCustomize,
                        child: const Text(
                          'Customize',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    if (widget.onDetails != null) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: widget.onDetails,
                        child: const Text(
                          'Details',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
