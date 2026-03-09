import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_custom_widget/flutter_custom_widget.dart'
//     hide CustomTextInput, Responsive;
import 'package:flutter_svg/svg.dart';
import 'package:pizza_ordering_app/screen/menu/address_bar.dart';
import 'package:pizza_ordering_app/screen/menu/search_bar.dart';
import 'package:pizza_ordering_app/screen/menu/top_bar.dart';
import 'package:pizza_ordering_app/widgets/custom_text_input.dart';
import 'menu_item.dart';
import 'bottom_bar.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchFocused = false;

  bool _isCartOpen = false;
  bool _isTopBarExpanded = false; // <-- add

  // chọn category hiện tại
  String _selectedCategory = 'Pizza';

  // map chứa options + meta (dễ map từ backend sau này)
  // ...existing code...
  final Map<String, Map<String, dynamic>> _menuOptions = {
    // Pizza
    'pepperoni': {
      'id': 'pepperoni',
      'name': 'Pepperoni',
      'description': 'Medium - Cheese, Onion, and Tomato Sauce',
      'price': '\$12.00',
      'category': 'Pizza',
      'qty': 0,
    },
    'hawaiian': {
      'id': 'hawaiian',
      'name': 'Tropical Hawaiian',
      'description': 'Medium - Cheese, Ham, Pineapple, and Tomato Sauce',
      'price': '\$14.00',
      'category': 'Pizza',
      'qty': 0,
    },
    'margherita': {
      'id': 'margherita',
      'name': 'Margherita',
      'description': 'Medium - Mozzarella, basil, tomato sauce',
      'price': '\$11.50',
      'category': 'Pizza',
      'qty': 0,
    },
    'bbq_chicken': {
      'id': 'bbq_chicken',
      'name': 'BBQ Chicken',
      'description': 'Medium - Chicken, onion, BBQ sauce',
      'price': '\$15.00',
      'category': 'Pizza',
      'qty': 0,
    },
    'veggie': {
      'id': 'veggie',
      'name': 'Veggie Delight',
      'description': 'Medium - Bell pepper, olive, mushroom, onion',
      'price': '\$13.00',
      'category': 'Pizza',
      'qty': 0,
    },

    // Salad
    'caesar': {
      'id': 'caesar',
      'name': 'Caesar Salad',
      'description': 'Fresh romaine, parmesan, croutons',
      'price': '\$8.00',
      'category': 'Salad',
      'qty': 0,
    },
    'greek_salad': {
      'id': 'greek_salad',
      'name': 'Greek Salad',
      'description': 'Cucumber, tomato, feta, olive',
      'price': '\$8.50',
      'category': 'Salad',
      'qty': 0,
    },
    'garden_salad': {
      'id': 'garden_salad',
      'name': 'Garden Salad',
      'description': 'Mixed greens, tomato, carrot',
      'price': '\$7.00',
      'category': 'Salad',
      'qty': 0,
    },

    // Sides
    'fries': {
      'id': 'fries',
      'name': 'French Fries',
      'description': 'Crispy potato fries',
      'price': '\$4.50',
      'category': 'Sides',
      'qty': 0,
    },
    'garlic_bread': {
      'id': 'garlic_bread',
      'name': 'Garlic Bread',
      'description': 'Toasted bread with garlic butter',
      'price': '\$5.00',
      'category': 'Sides',
      'qty': 0,
    },
    'onion_rings': {
      'id': 'onion_rings',
      'name': 'Onion Rings',
      'description': 'Golden fried onion rings',
      'price': '\$5.50',
      'category': 'Sides',
      'qty': 0,
    },
    'wings': {
      'id': 'wings',
      'name': 'Chicken Wings',
      'description': '6 pcs - spicy or BBQ',
      'price': '\$9.00',
      'category': 'Sides',
      'qty': 0,
    },

    // Drink
    'coke': {
      'id': 'coke',
      'name': 'Coke',
      'description': '330ml Can',
      'price': '\$2.50',
      'category': 'Drink',
      'qty': 0,
    },
    'sprite': {
      'id': 'sprite',
      'name': 'Sprite',
      'description': '330ml Can',
      'price': '\$2.50',
      'category': 'Drink',
      'qty': 0,
    },
    'orange_juice': {
      'id': 'orange_juice',
      'name': 'Orange Juice',
      'description': 'Fresh - 250ml',
      'price': '\$3.50',
      'category': 'Drink',
      'qty': 0,
    },
    'water': {
      'id': 'water',
      'name': 'Mineral Water',
      'description': '500ml Bottle',
      'price': '\$1.50',
      'category': 'Drink',
      'qty': 0,
    },
  };
  // ...existing code...

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() => _isSearchFocused = _searchFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchFocus.removeListener(() {});
    _searchFocus.dispose();
    super.dispose();
  }

  void _selectCategory(String category) {
    setState(() => _selectedCategory = category);
  }

  void _changeQty(String itemId, int delta) {
    setState(() {
      final item = _menuOptions[itemId];
      if (item == null) return;
      final int newQty = ((item['qty'] as int) + delta).clamp(0, 999);
      item['qty'] = newQty;
    });
  }

  void _toggleSelect(String itemId) {
    setState(() {
      final item = _menuOptions[itemId];
      if (item == null) return;
      item['qty'] = (item['qty'] as int) > 0 ? 0 : 1;
    });
  }

  List<Map<String, dynamic>> get _filteredItems => _menuOptions.values
      .where((m) => m['category'] == _selectedCategory)
      .toList();

  // cart helpers
  List<Map<String, dynamic>> get _cartItems =>
      _menuOptions.values.where((m) => (m['qty'] as int) > 0).toList();

  double _parsePrice(String price) {
    final s = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(s) ?? 0.0;
  }

  double get _cartTotal => _cartItems.fold(
    0.0,
    (sum, it) => sum + _parsePrice(it['price']) * (it['qty'] as int),
  );

  int get _cartCount =>
      _cartItems.fold(0, (sum, it) => sum + (it['qty'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Stack(
          children: [
            // main scrollable content
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 96.h, 16.w, 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),

                  Text(
                    'Hi Karl!',
                    style: TextStyle(
                      color: const Color(0xFFE87C1E),
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Welcome To Cao Pizza',
                    style: TextStyle(
                      color: const Color(0xFFE87C1E),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  AddressBar(
                    address: '12 Eldorado Ct, Toronto, ON, Canada',
                    onAddressChanged: (a) {
                      /* cập nhật state nếu cần */
                    },
                  ),
                  SizedBox(height: 20.h),
                  MenuSearchBar(
                    focusNode: _searchFocus,
                    isFocused: _isSearchFocused,
                  ),
                  SizedBox(height: 30.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories
                          .map(
                            (category) => Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: InkWell(
                                onTap: () => setState(
                                  () => _selectedCategory = category,
                                ),
                                borderRadius: BorderRadius.circular(12.w),
                                child: _CategoryItem(
                                  label: category,
                                  isSelected: _selectedCategory == category,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ..._filteredItems.map((it) {
                    return Column(
                      children: [
                        MenuItemWidget(
                          id: it['id'] as String,
                          name: it['name'] as String,
                          description: it['description'] as String,
                          price: it['price'] as String,
                          qty: it['qty'] as int,
                          isSelected: (it['qty'] as int) > 0,
                          onTap: () => _toggleSelect(it['id'] as String),
                          onAdd: () => _changeQty(it['id'] as String, 1),
                          onRemove: () => _changeQty(it['id'] as String, -1),
                          onCustomize: (it['qty'] as int) > 0
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        appBar: AppBar(
                                          title: Text(
                                            'Customize ${it['name']}',
                                          ),
                                        ),
                                        body: Center(
                                          child: Text(
                                            'Customize options for ${it['name']}',
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                        SizedBox(height: 12.h),
                      ],
                    );
                  }),
                  SizedBox(height: 20.h),
                ],
              ),
            ),

            // dim overlay when top bar expanded
            if (_isTopBarExpanded)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ),
              ),

            // TOP BAR: sticky/fixed
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: MenuTopBar(
                isExpanded: _isTopBarExpanded,
                onMenuTap: (expanded) {
                  setState(() => _isTopBarExpanded = expanded);
                },
              ),
            ),

            // hide bottom bar when top bar is expanded
            if (!_isTopBarExpanded)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomBar(
                  isOpen: _isCartOpen,
                  cartItems: _cartItems,
                  total: _cartTotal,
                  count: _cartCount,
                  onToggle: () => setState(() => _isCartOpen = !_isCartOpen),
                  onChangeQty: (id, delta) => _changeQty(id, delta),
                  onCheckout: () {},
                  onItemDetails: (id) {
                    final it = _menuOptions[id];
                    if (it == null) return;
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(it['name']),
                        content: Text(
                          '${it['description']}\n\nPrice: ${it['price']}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const Map<String, String> _categoryIcons = {
  'Pizza': 'assets/svg/pizza.svg',
  'Salad': 'assets/svg/salad.svg',
  'Sides': 'assets/svg/sides.svg',
  'Drink': 'assets/svg/drink.svg',
};

const List<String> _categories = ['Pizza', 'Salad', 'Sides', 'Drink'];

class _CategoryItem extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _CategoryItem({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final String? iconPath = _categoryIcons[label];

    // debugPrint(iconPath);

    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(12.w),
            border: isSelected
                ? Border.all(color: const Color(0xFFE87C1E), width: 2)
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(18.w),
            child: iconPath != null
                ? SvgPicture.asset(
                    width: 35.w,
                    height: 35.w,
                    fit: BoxFit.contain,
                    iconPath,
                    colorFilter: ColorFilter.mode(
                      isSelected ? const Color(0xFFE87C1E) : Colors.grey,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(
                    Icons.fastfood,
                    color: isSelected ? const Color(0xFFE87C1E) : Colors.grey,
                    size: 36.sp,
                  ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFE87C1E) : Colors.grey,
            fontSize: 15.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
