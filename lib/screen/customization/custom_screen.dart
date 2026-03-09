import 'package:flutter/material.dart';
import 'package:pizza_ordering_app/widgets/folding_qty_control.dart';

class CustomScreen extends StatelessWidget {
  final String? title;

  const CustomScreen({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    // use PaperFoldDemo for quick testing
    return const PaperFoldDemo();
  }
}
