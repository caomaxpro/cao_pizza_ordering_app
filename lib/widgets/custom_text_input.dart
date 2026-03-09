import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String title;
  final String placeholder;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? placeholderColor;
  final TextEditingController? controller;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? leftPadding;
  final double? rightPadding;
  final double? topPadding;
  final double? bottomPadding;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final Color? cursorColor;
  final bool hideTitle;

  const CustomTextInput({
    super.key,
    required this.placeholder,
    this.title = "",
    this.titleStyle,
    this.contentStyle,
    this.backgroundColor,
    this.textColor,
    this.placeholderColor,
    this.controller,
    this.width,
    this.height,
    this.padding,
    this.leftPadding,
    this.rightPadding,
    this.topPadding,
    this.bottomPadding,
    this.border,
    this.borderRadius,
    this.cursorColor,
    this.hideTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool shouldShowTitle = !hideTitle && title.trim().isNotEmpty;

    final input = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade200,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: border,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: leftPadding ?? padding?.horizontal ?? 12,
          right: rightPadding ?? 12,
          bottom: bottomPadding ?? 0,
        ),
        child: Center(
          child: TextField(
            controller: controller,
            style: contentStyle ?? TextStyle(color: textColor ?? Colors.black),
            cursorColor: cursorColor ?? Colors.black,
            textAlignVertical: TextAlignVertical.center,
            expands: false,
            maxLines: 1,
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: placeholder,
              hintStyle:
                  contentStyle?.copyWith(
                    color:
                        placeholderColor ??
                        (textColor ?? Colors.black).withAlpha(120),
                  ) ??
                  TextStyle(
                    color:
                        placeholderColor ??
                        (textColor ?? Colors.black).withAlpha(120),
                    fontSize: 15,
                  ),
            ),
          ),
        ),
      ),
    );

    if (!shouldShowTitle) return input;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              titleStyle ??
              Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor ?? Colors.black,
              ),
        ),
        const SizedBox(height: 10),
        input,
      ],
    );
  }
}
