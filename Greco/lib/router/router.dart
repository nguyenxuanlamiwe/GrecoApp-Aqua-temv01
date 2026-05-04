import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:zen8app/app/pages/iot/tb_auto_mode/tb_auto_mode_page.dart';
import 'package:zen8app/app/pages/iot/tb_list_auto_mode/tb_auto_mode_list_page.dart';
import 'package:zen8app/app/pages/iot/tb_suggestion/tb_suggestion_page.dart';
import 'package:zen8app/core/core.dart';
import 'package:zen8app/models/models.dart';
import 'package:zen8app/app/pages/iot/tb_control_system/tb_control_system_page.dart';
import 'package:zen8app/app/pages/auth/login/login_page.dart';
import 'package:zen8app/app/pages/main/home_page.dart';
import 'package:zen8app/app/pages/main/map/map_page.dart';
import 'package:zen8app/app/pages/iot/tb_atsystem_config/tb_atsystem_config_page.dart';
export 'package:auto_route/auto_route.dart';

part 'router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    if (Session.isLoggedIn) {
      resolver.next(true);
    } else {
      router.push(const LoginRoute());
    }
  }
}

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  final List<AutoRoute> routes = [
    AutoRoute(page: HomeRoute.page, path: "/", guards: [AuthGuard()]),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: TBControlSystemRoute.page),
    AutoRoute(page: TBAutoModeListRoute.page),
    AutoRoute(page: TBAutoModeRoute.page),
    AutoRoute(page: TBATSystemConfigRoute.page),
    AutoRoute(page: MapRoute.page),
  ];
}
