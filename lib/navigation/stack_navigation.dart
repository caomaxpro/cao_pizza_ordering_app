import 'package:flutter/material.dart';

class StackNavigator extends StatefulWidget {
  final List<Widget> screens;

  const StackNavigator({super.key, this.screens = const []});

  @override
  State<StackNavigator> createState() => _StackNavigatorState();
}

class _StackNavigatorState extends State<StackNavigator> {
  late List<Widget> _navigationStack;

  @override
  void initState() {
    super.initState();
    _navigationStack = List.from(widget.screens);
  }

  void pushScreen(Widget screen) {
    setState(() {
      _navigationStack.add(screen);
    });
  }

  void popScreen() {
    if (_navigationStack.isNotEmpty) {
      setState(() {
        _navigationStack.removeLast();
      });
    }
  }

  void popUntil(int index) {
    if (index >= 0 && index < _navigationStack.length) {
      setState(() {
        _navigationStack.removeRange(index + 1, _navigationStack.length);
      });
    }
  }

  void clearStack() {
    setState(() {
      _navigationStack.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _navigationStack.length <= 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _navigationStack.isNotEmpty) {
          popScreen();
        }
      },
      child: _navigationStack.isNotEmpty
          ? _navigationStack.last
          : const Scaffold(body: Center(child: Text('No screen in stack'))),
    );
  }
}
