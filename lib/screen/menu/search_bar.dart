import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pizza_ordering_app/widgets/custom_text_input.dart';

class MenuSearchBar extends StatelessWidget {
  final FocusNode focusNode;
  final bool isFocused;

  const MenuSearchBar({
    super.key,
    required this.focusNode,
    required this.isFocused,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 50.h,
        width: double.infinity,
        padding: EdgeInsets.only(right: 10.sp),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          border: BoxBorder.all(
            color: isFocused ? const Color(0xFFE87C1E) : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 15,
              child: Center(
                child: Icon(
                  Icons.search,
                  color: isFocused ? const Color(0xFFE87C1E) : Colors.grey,
                  size: 24.sp,
                ),
              ),
            ),
            Expanded(
              flex: 85,
              child: Focus(
                focusNode: focusNode,
                child: CustomTextInput(
                  placeholder: 'What are you craving?',
                  placeholderColor: Colors.grey,
                  hideTitle: true,
                  textColor: isFocused ? const Color(0xFFE87C1E) : Colors.grey,
                  height: 50.h,
                  backgroundColor: Colors.transparent,
                  borderRadius: BorderRadius.zero,
                  leftPadding: 0.sp,
                  cursorColor: isFocused
                      ? const Color(0xFFE87C1E)
                      : Colors.grey,
                  bottomPadding: 5.sp,
                  contentStyle: TextStyle(
                    fontSize: 16.sp,
                    color: isFocused ? const Color(0xFFE87C1E) : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
