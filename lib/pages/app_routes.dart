part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const home = '/';
  static const settings = '/settings';
  // e.g., /section/Fiqh Al-Hajj/Al-Ihram/1
  static const questionByPath = '/section/:title/:subtitle/:questionNo';

  // e.g., /q/123
  static const questionShortcut = '/q/:questionNo';
}
