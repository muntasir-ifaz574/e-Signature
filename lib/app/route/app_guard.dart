import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import '../core/data/data.dart';
import 'app_route.gr.dart';

class AppGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final localData = GetIt.I<LocalData>();

    if (resolver.routeName == SplashRoute.name) {
      resolver.next();
      return;
    }

    if (!localData.getLoginStatus()) {
      router.replace(const SignUpRoute());
      return;
    }

    resolver.next();
  }
}
