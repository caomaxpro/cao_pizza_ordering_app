import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddressBar extends StatefulWidget {
  final String address;
  final ValueChanged<String>? onAddressChanged;

  const AddressBar({
    Key? key,
    this.address = '12 Eldorado Ct, Toronto, ON, Canada',
    this.onAddressChanged,
  }) : super(key: key);

  @override
  State<AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> {
  late String _address;

  @override
  void initState() {
    super.initState();
    _address = widget.address;
  }

  Future<void> _editAddress() async {
    final controller = TextEditingController(text: _address);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text(
          'Change address',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new address',
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Color(0xFF3C3C3C),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.white),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFFE87C1E)),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != _address) {
      setState(() => _address = result);
      widget.onAddressChanged?.call(_address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _editAddress,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF3C3C3C),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE87C1E), width: 1.2),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: const Color(0xFFE87C1E),
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Delivery Address",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _address,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.edit, color: Colors.white, size: 18.sp),
          ],
        ),
      ),
    );
  }
}
