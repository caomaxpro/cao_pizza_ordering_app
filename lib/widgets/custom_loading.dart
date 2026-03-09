import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _LoadingClipper extends CustomClipper<Path> {
  final double clipHeight;

  _LoadingClipper({required this.clipHeight});

  @override
  Path getClip(Size size) {
    // rect bắt đầu ở đáy, cao = clipHeight
    return Path()..addRect(
      Rect.fromLTWH(0, size.height - clipHeight, size.width, clipHeight),
    );
  }

  @override
  bool shouldReclip(_LoadingClipper oldClipper) {
    return oldClipper.clipHeight != clipHeight;
  }
}

class CustomLoadingWidget extends StatefulWidget {
  final int loadingTime; // milliseconds
  final VoidCallback? onLoadingStart;
  final VoidCallback? onLoadingEnd;

  const CustomLoadingWidget({
    super.key,
    this.loadingTime = 60000,
    this.onLoadingStart,
    this.onLoadingEnd,
  });

  @override
  State<CustomLoadingWidget> createState() => _CustomLoadingWidgetState();
}

class _CustomLoadingWidgetState extends State<CustomLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _clipHeight;

  static const double _svgHeight = 186; // chiều cao SVG

  @override
  void initState() {
    super.initState();
    widget.onLoadingStart?.call();
    debugPrint('Animation started at: ${DateTime.now()}');
    debugPrint("Loading time: ${widget.loadingTime}");

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.loadingTime),
      vsync: this,
    );

    // bắt đầu từ 0 (không nhìn thấy), kết thúc lên đến toàn bộ chiều cao
    _clipHeight = Tween<double>(
      begin: 0,
      end: _svgHeight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        debugPrint('Animation ended at: ${DateTime.now()}');
        widget.onLoadingEnd?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _clipHeight,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // cái thứ hai không bị clip
              SvgPicture.asset(
                'assets/svg/pizza.svg',
                width: 159,
                height: _svgHeight,
                fit: BoxFit.cover,
              ),

              // cái đầu tiên được clip/slide
              ClipPath(
                clipper: _LoadingClipper(clipHeight: _clipHeight.value),
                child: SvgPicture.asset(
                  'assets/svg/pizza.svg',
                  width: 159,
                  height: _svgHeight,
                  fit: BoxFit.cover,
                  color: Colors.red.withOpacity(1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
