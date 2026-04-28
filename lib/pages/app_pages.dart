import 'package:get/get.dart';
import 'package:hajj_app/pages/settings_page.dart';
import 'package:hajj_app/pages/home_page.dart';
import 'package:hajj_app/pages/question_page.dart'; // You will need to create/have a QuestionPage

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    // GetPage(name: Routes.home, page: () => const HomePage()),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsPage(),
    ),

    // NOTE: Uncomment the following section once you have a 'QuestionPage' that can
    // read parameters from the route to display the correct data.
    GetPage(
      name: Routes.questionByPath,
      page: () =>
          QuestionPage(int.tryParse(Get.parameters['questionNo'] ?? '')),
    ),
    GetPage(
      name: Routes.questionShortcut,
      page: () =>
          QuestionPage(int.tryParse(Get.parameters['questionNo'] ?? '')),
    ),
  ];
}
