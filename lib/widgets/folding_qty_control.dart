import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// FoldingQtyControl
/// Reusable widget: nhấn "Add" để unfold thành [− | qty (TextField) | +]
/// - onAdd / onRemove callbacks
/// - onQtyChanged khi submit hoặc thay đổi trong text field
class FoldingQtyControl extends StatefulWidget {
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onQtyChanged;
  final int qty;
  // new field: control font size for both the Add label and the textfield content
  final double? fontSize;
  // sizing overrides to allow reuse in different UIs
  final double? panelWidth;
  final double? panelHeight;
  final double? panelGap;
  // parent can control open/close (null = internal control)
  final bool? open;
  // notify parent when widget opens/closes (optional)
  final ValueChanged<bool>? onOpenChanged;

  const FoldingQtyControl({
    super.key,
    this.onAdd,
    this.onRemove,
    this.onQtyChanged,
    this.qty = 0,
    this.fontSize,
    this.panelWidth,
    this.panelHeight,
    this.panelGap,
    this.open,
    this.onOpenChanged,
  });

  @override
  State<FoldingQtyControl> createState() => _FoldingQtyControlState();
}

class _FoldingQtyControlState extends State<FoldingQtyControl>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _foldLeft;
  late final Animation<double> _foldRight;
  late final Animation<double> _contentFade;

  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  int _localQty = 0;

  static const Color _accent = Color(0xFFE87C1E);
  static const Color _bg = Color(0xFF3C3C3C);

  @override
  void initState() {
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _localQty = widget.qty;
    _textController.text = '$_localQty';
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _foldLeft = Tween<double>(begin: math.pi / 2, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _foldRight = Tween<double>(begin: -math.pi / 2, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.value = 0.0;

    // nếu parent đã truyền open == true ngay từ đầu, bật animation sau frame đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.open == true) {
        if (!_controller.isAnimating && !_controller.isCompleted) {
          _controller.forward();
        }
      } else if (widget.open == false) {
        if (!_controller.isAnimating && !_controller.isDismissed) {
          _controller.reverse();
        }
      } else {
        // fallback: nếu parent không control và qty > 0 thì mở
        if (widget.qty > 0 && !_controller.isCompleted) {
          _controller.forward();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant FoldingQtyControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint(
      'FoldingQtyControl(${widget.key ?? widget}): open prop changed old=${oldWidget.open} new=${widget.open}',
    );
    if (widget.qty != _localQty) {
      _localQty = widget.qty;
      _textController.text = '$_localQty';
    }
    // parent-controlled open/close
    if (widget.open != null && widget.open != oldWidget.open) {
      if (widget.open == true) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    } else {
      // internal behaviour: when qty goes >0 -> 0, close
      if (oldWidget.qty > 0 && widget.qty == 0) {
        _controller.reverse();
        widget.onOpenChanged?.call(false);
      }
      // when qty crosses 0 -> >0 and parent didn't control open, open
      if (oldWidget.qty == 0 && widget.qty > 0 && widget.open == null) {
        _controller.forward();
        widget.onOpenChanged?.call(true);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onAdd() {
    if (!_controller.isCompleted) {
      _controller.forward().then((_) {
        if (mounted) FocusScope.of(context).requestFocus(_focusNode);
        widget.onOpenChanged?.call(true);
      });
    } else {
      // if already open, still notify parent that an "add" occurred
      widget.onOpenChanged?.call(true);
    }
    widget.onAdd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final double panelWidth = widget.panelWidth ?? 100.sp;
    final double panelHeight = widget.panelHeight ?? 70.sp;
    final double panelGap = widget.panelGap ?? 12.sp;
    debugPrint(
      'FoldingQtyControl(${widget.key ?? widget}): widget.open=${widget.open} controller=${_controller.value}',
    );
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final bool isOpen = _controller.value > 0.01;

        return SizedBox(
          height: panelHeight,
          width:
              panelWidth + _controller.value * (panelWidth * 2 + panelGap * 2),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // middle panel (Add / TextField)
              Positioned(
                left: (panelWidth + panelGap) * _controller.value,
                child: GestureDetector(
                  onTap: isOpen ? null : _onAdd,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: panelWidth,
                    height: panelHeight,
                    decoration: BoxDecoration(
                      color: isOpen ? Colors.transparent : _accent,
                      borderRadius: BorderRadius.circular(8),
                      border: isOpen
                          ? Border.all(color: _accent, width: 1)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: anim, child: child),
                      ),
                      child: isOpen
                          ? SizedBox(
                              key: const ValueKey('field'),
                              width: panelWidth - 16.sp,
                              height: panelHeight - 16.sp,
                              child: TextField(
                                controller: _textController,
                                focusNode: _focusNode,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: widget.fontSize ?? 22.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                                onChanged: (v) {
                                  final n = int.tryParse(v) ?? 0;
                                  setState(() => _localQty = n);
                                  widget.onQtyChanged?.call(n);
                                },
                                onSubmitted: (v) {
                                  final n = int.tryParse(v) ?? 0;
                                  widget.onQtyChanged?.call(n);
                                  setState(() => _localQty = n);
                                },
                              ),
                            )
                          : SizedBox(
                              key: const ValueKey('add'),
                              child: Text(
                                'Add',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: widget.fontSize ?? 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              // left panel (−)
              Positioned(
                left: 0,
                child: Transform(
                  alignment: Alignment.centerRight,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_foldLeft.value),
                  child: GestureDetector(
                    onTap: isOpen ? widget.onRemove : null,
                    child: Container(
                      width: panelWidth,
                      height: panelHeight,
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _accent, width: 1),
                      ),
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // right panel (+)
              Positioned(
                left: (panelWidth + panelGap) * 2 * _controller.value,
                child: Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_foldRight.value),
                  child: GestureDetector(
                    onTap: _onAdd,
                    child: Container(
                      width: panelWidth,
                      height: panelHeight,
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Demo screen để test ──
class PaperFoldDemo extends StatefulWidget {
  const PaperFoldDemo({super.key});

  @override
  State<PaperFoldDemo> createState() => _PaperFoldDemoState();
}

class _PaperFoldDemoState extends State<PaperFoldDemo> {
  int _qty = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Folding Qty Control'),
        backgroundColor: const Color(0xFF202020),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'qty: $_qty',
              style: TextStyle(color: Colors.white, fontSize: 18.sp),
            ),
            SizedBox(height: 32.sp),
            FoldingQtyControl(
              qty: _qty,
              onAdd: () => setState(() => _qty++),
              onRemove: () => setState(() {
                if (_qty > 0) _qty--;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
