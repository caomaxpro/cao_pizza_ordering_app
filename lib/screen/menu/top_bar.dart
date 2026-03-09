import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuTopBar extends StatelessWidget {
  final ValueChanged<bool>? onMenuTap;
  final ValueChanged<String>? onOptionTap;
  final bool isLoggedIn;
  final bool isExpanded; // <-- controlled by parent

  const MenuTopBar({
    super.key,
    this.onMenuTap,
    this.onOptionTap,
    this.isLoggedIn = false,
    this.isExpanded = false,
  });

  static const Map<String, Map<String, dynamic>> _optionMap = {
    'menu': {'title': 'Menu', 'loginRequired': false, 'audience': 'both'},
    'promotions': {
      'title': 'Promotions',
      'loginRequired': false,
      'audience': 'guest',
    },
    'track_order': {
      'title': 'Track Order',
      'loginRequired': false,
      'audience': 'guest',
    },
    'nearby_stores': {
      'title': 'Nearby Stores',
      'loginRequired': false,
      'audience': 'guest',
    },
    'help_faq': {
      'title': 'Help / FAQ',
      'loginRequired': false,
      'audience': 'guest',
    },
    'language': {
      'title': 'Language',
      'loginRequired': false,
      'audience': 'both',
    },
    'sign_in_up': {
      'title': 'Sign In / Sign Up',
      'loginRequired': false,
      'audience': 'guest',
    },
    'personalized_offers': {
      'title': 'Personalized Offers',
      'loginRequired': true,
      'audience': 'user',
    },
    'my_orders': {
      'title': 'My Orders',
      'loginRequired': true,
      'audience': 'user',
    },
    'favorites': {
      'title': 'Favorites',
      'loginRequired': true,
      'audience': 'user',
    },
    'delivery_addresses': {
      'title': 'Delivery Addresses',
      'loginRequired': true,
      'audience': 'user',
    },
    'wallet_payment': {
      'title': 'Wallet / Payment Methods',
      'loginRequired': true,
      'audience': 'user',
    },
    'rewards_membership': {
      'title': 'Rewards / Membership',
      'loginRequired': true,
      'audience': 'user',
    },
    'notifications': {
      'title': 'Notifications',
      'loginRequired': true,
      'audience': 'user',
    },
    'account_profile': {
      'title': 'Account Profile',
      'loginRequired': true,
      'audience': 'user',
    },
    'log_out': {'title': 'Log Out', 'loginRequired': true, 'audience': 'user'},
  };

  List<MapEntry<String, Map<String, dynamic>>> _visibleOptions() {
    return _optionMap.entries.where((entry) {
      final audience = entry.value['audience'] as String? ?? 'both';
      if (audience == 'both') return true;
      if (audience == 'guest') return !isLoggedIn;
      if (audience == 'user') return isLoggedIn;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleOptions = _visibleOptions();

    return Container(
      color: const Color(0xFF1E1E1E),
      padding: EdgeInsets.fromLTRB(10.w, 3.h, 10.w, 10.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100.w,
                height: 70.w,
                child: Padding(
                  padding: EdgeInsets.all(5.w),
                  child: SvgPicture.asset(
                    'assets/svg/pizza_logo_2.svg',
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFE87C1E),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onMenuTap?.call(!isExpanded),
                icon: Icon(
                  isExpanded ? Icons.close : Icons.menu,
                  color: const Color(0xFFE87C1E),
                  size: 28.sp,
                ),
              ),
            ],
          ),
          if (isExpanded)
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: visibleOptions.map((entry) {
                  final id = entry.key;
                  final title = entry.value['title'] as String;
                  final loginRequired =
                      entry.value['loginRequired'] as bool? ?? false;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: InkWell(
                      onTap: () => onOptionTap?.call(id),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFE87C1E)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: const Color(0xFFE87C1E),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (loginRequired) ...[
                              SizedBox(width: 6.w),
                              Icon(
                                Icons.lock_outline,
                                size: 14.sp,
                                color: Colors.orangeAccent,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
