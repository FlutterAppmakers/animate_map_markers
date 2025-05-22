import 'package:flutter/material.dart';

/// Provides controller for all the child widgets.
class PageCtrlProvider extends InheritedWidget {

  final PageController pageCtrl;


  const PageCtrlProvider ({
    super.key, 
    required super.child,
     required this.pageCtrl,
  });

  @override
  bool updateShouldNotify(PageCtrlProvider oldWidget) => false;

  static PageCtrlProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PageCtrlProvider>();
  }
}
