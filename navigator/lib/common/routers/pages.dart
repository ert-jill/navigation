import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../pages/home/view.dart';
import 'names.dart';

class RoutePages {
  // 列表
  static List<GetPage> list = [
    GetPage(
      name: RouteNames.home,
      page: () => const HomePage(),
    ),
  ];
}
