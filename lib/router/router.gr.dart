// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomePage(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginPage(),
      );
    },
    MapRoute.name: (routeData) {
      final args = routeData.argsAs<MapRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MapPage(
          key: args.key,
          farms: args.farms,
        ),
      );
    },
    TBATSystemConfigRoute.name: (routeData) {
      final args = routeData.argsAs<TBATSystemConfigRouteArgs>();
      return AutoRoutePage<bool>(
        routeData: routeData,
        child: TBATSystemConfigPage(
          key: args.key,
          atSystem: args.atSystem,
          controlSystem: args.controlSystem,
        ),
      );
    },
    TBAutoModeListRoute.name: (routeData) {
      final args = routeData.argsAs<TBAutoModeListRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: TBAutoModeListPage(
          key: args.key,
          system: args.system,
        ),
      );
    },
    TBAutoModeRoute.name: (routeData) {
      final args = routeData.argsAs<TBAutoModeRouteArgs>();
      return AutoRoutePage<bool>(
        routeData: routeData,
        child: TBAutoModePage(
          key: args.key,
          mode: args.mode,
          system: args.system,
        ),
      );
    },
    TBControlSystemRoute.name: (routeData) {
      final args = routeData.argsAs<TBControlSystemRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: TBControlSystemPage(
          key: args.key,
          systems: args.systems,
        ),
      );
    },
    UIConfigRoute.name: (routeData) {
      final args = routeData.argsAs<UIConfigRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UIConfigPage(
          key: args.key,
          farm: args.farm,
        ),
      );
    },
  };
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MapPage]
class MapRoute extends PageRouteInfo<MapRouteArgs> {
  MapRoute({
    Key? key,
    required List<(TBFarm, Color)> farms,
    List<PageRouteInfo>? children,
  }) : super(
          MapRoute.name,
          args: MapRouteArgs(
            key: key,
            farms: farms,
          ),
          initialChildren: children,
        );

  static const String name = 'MapRoute';

  static const PageInfo<MapRouteArgs> page = PageInfo<MapRouteArgs>(name);
}

class MapRouteArgs {
  const MapRouteArgs({
    this.key,
    required this.farms,
  });

  final Key? key;

  final List<(TBFarm, Color)> farms;

  @override
  String toString() {
    return 'MapRouteArgs{key: $key, farms: $farms}';
  }
}

/// generated route for
/// [TBATSystemConfigPage]
class TBATSystemConfigRoute extends PageRouteInfo<TBATSystemConfigRouteArgs> {
  TBATSystemConfigRoute({
    Key? key,
    required TBATSystem? atSystem,
    required TBControlSystem controlSystem,
    List<PageRouteInfo>? children,
  }) : super(
          TBATSystemConfigRoute.name,
          args: TBATSystemConfigRouteArgs(
            key: key,
            atSystem: atSystem,
            controlSystem: controlSystem,
          ),
          initialChildren: children,
        );

  static const String name = 'TBATSystemConfigRoute';

  static const PageInfo<TBATSystemConfigRouteArgs> page =
      PageInfo<TBATSystemConfigRouteArgs>(name);
}

class TBATSystemConfigRouteArgs {
  const TBATSystemConfigRouteArgs({
    this.key,
    required this.atSystem,
    required this.controlSystem,
  });

  final Key? key;

  final TBATSystem? atSystem;

  final TBControlSystem controlSystem;

  @override
  String toString() {
    return 'TBATSystemConfigRouteArgs{key: $key, atSystem: $atSystem, controlSystem: $controlSystem}';
  }
}

/// generated route for
/// [TBAutoModeListPage]
class TBAutoModeListRoute extends PageRouteInfo<TBAutoModeListRouteArgs> {
  TBAutoModeListRoute({
    Key? key,
    required TBControlSystem system,
    List<PageRouteInfo>? children,
  }) : super(
          TBAutoModeListRoute.name,
          args: TBAutoModeListRouteArgs(
            key: key,
            system: system,
          ),
          initialChildren: children,
        );

  static const String name = 'TBAutoModeListRoute';

  static const PageInfo<TBAutoModeListRouteArgs> page =
      PageInfo<TBAutoModeListRouteArgs>(name);
}

class TBAutoModeListRouteArgs {
  const TBAutoModeListRouteArgs({
    this.key,
    required this.system,
  });

  final Key? key;

  final TBControlSystem system;

  @override
  String toString() {
    return 'TBAutoModeListRouteArgs{key: $key, system: $system}';
  }
}

/// generated route for
/// [TBAutoModePage]
class TBAutoModeRoute extends PageRouteInfo<TBAutoModeRouteArgs> {
  TBAutoModeRoute({
    Key? key,
    required TBATMode mode,
    required TBControlSystem system,
    List<PageRouteInfo>? children,
  }) : super(
          TBAutoModeRoute.name,
          args: TBAutoModeRouteArgs(
            key: key,
            mode: mode,
            system: system,
          ),
          initialChildren: children,
        );

  static const String name = 'TBAutoModeRoute';

  static const PageInfo<TBAutoModeRouteArgs> page =
      PageInfo<TBAutoModeRouteArgs>(name);
}

class TBAutoModeRouteArgs {
  const TBAutoModeRouteArgs({
    this.key,
    required this.mode,
    required this.system,
  });

  final Key? key;

  final TBATMode mode;

  final TBControlSystem system;

  @override
  String toString() {
    return 'TBAutoModeRouteArgs{key: $key, mode: $mode, system: $system}';
  }
}

/// generated route for
/// [TBControlSystemPage]
class TBControlSystemRoute extends PageRouteInfo<TBControlSystemRouteArgs> {
  TBControlSystemRoute({
    Key? key,
    required List<TBControlSystem> systems,
    List<PageRouteInfo>? children,
  }) : super(
          TBControlSystemRoute.name,
          args: TBControlSystemRouteArgs(
            key: key,
            systems: systems,
          ),
          initialChildren: children,
        );

  static const String name = 'TBControlSystemRoute';

  static const PageInfo<TBControlSystemRouteArgs> page =
      PageInfo<TBControlSystemRouteArgs>(name);
}

class TBControlSystemRouteArgs {
  const TBControlSystemRouteArgs({
    this.key,
    required this.systems,
  });

  final Key? key;

  final List<TBControlSystem> systems;

  @override
  String toString() {
    return 'TBControlSystemRouteArgs{key: $key, systems: $systems}';
  }
}

/// generated route for
/// [UIConfigPage]
class UIConfigRoute extends PageRouteInfo<UIConfigRouteArgs> {
  UIConfigRoute({
    Key? key,
    required TBFarm farm,
    List<PageRouteInfo>? children,
  }) : super(
          UIConfigRoute.name,
          args: UIConfigRouteArgs(
            key: key,
            farm: farm,
          ),
          initialChildren: children,
        );

  static const String name = 'UIConfigRoute';

  static const PageInfo<UIConfigRouteArgs> page =
      PageInfo<UIConfigRouteArgs>(name);
}

class UIConfigRouteArgs {
  const UIConfigRouteArgs({
    this.key,
    required this.farm,
  });

  final Key? key;

  final TBFarm farm;

  @override
  String toString() {
    return 'UIConfigRouteArgs{key: $key, farm: $farm}';
  }
}
