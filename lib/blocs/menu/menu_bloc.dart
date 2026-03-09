import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(const MenuState()) {
    on<LoadMenu>(_onLoadMenu);
    on<SelectCategory>(_onSelectCategory);
    on<SearchMenu>(_onSearchMenu);
  }

  void _onLoadMenu(LoadMenu event, Emitter<MenuState> emit) async {
    emit(state.copyWith(loading: true));
    // TODO: load menu items & categories from repository/service
    await Future.delayed(const Duration(milliseconds: 500));
    emit(
      state.copyWith(
        loading: false,
        items: [
          // demo data
          {
            'id': '1',
            'name': 'Pizza Margherita',
            'category': 'Pizza',
            'description': 'Classic pizza',
            'price': '12.00',
            'qty': 0,
          },
          {
            'id': '2',
            'name': 'Pizza Pepperoni',
            'category': 'Pizza',
            'description': 'Pepperoni pizza',
            'price': '14.00',
            'qty': 0,
          },
        ],
        categories: ['Pizza', 'Pasta', 'Drinks'],
        selectedCategory: 'Pizza',
      ),
    );
  }

  void _onSelectCategory(SelectCategory event, Emitter<MenuState> emit) {
    emit(state.copyWith(selectedCategory: event.category));
    // TODO: filter items by category
  }

  void _onSearchMenu(SearchMenu event, Emitter<MenuState> emit) {
    emit(state.copyWith(searchQuery: event.query));
    // TODO: filter items by search query
  }
}
