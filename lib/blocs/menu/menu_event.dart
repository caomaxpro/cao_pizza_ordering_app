import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMenu extends MenuEvent {}

class SelectCategory extends MenuEvent {
  final String category;
  SelectCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchMenu extends MenuEvent {
  final String query;
  SearchMenu(this.query);

  @override
  List<Object?> get props => [query];
}