import 'package:equatable/equatable.dart';

class MenuState extends Equatable {
  final List<Map<String, dynamic>> items;
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;
  final bool loading;

  const MenuState({
    this.items = const [],
    this.categories = const [],
    this.selectedCategory = '',
    this.searchQuery = '',
    this.loading = false,
  });

  MenuState copyWith({
    List<Map<String, dynamic>>? items,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    bool? loading,
  }) {
    return MenuState(
      items: items ?? this.items,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [
    items,
    categories,
    selectedCategory,
    searchQuery,
    loading,
  ];
}
