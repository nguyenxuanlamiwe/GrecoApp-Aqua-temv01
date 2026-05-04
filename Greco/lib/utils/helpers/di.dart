class DI {
  static const _voidTypeString = '_void_';
  static Map<String, Map<String, dynamic>> _factoryMap = {};
  static Map<String, dynamic> _singletonInstances = {};

  DI._();

  static void register<T>(T Function() factoryFunc) {
    _register(T.toString(), _voidTypeString, factoryFunc);
  }

  static void registerWithParam<T, P>(T Function(P param) factoryFunc) {
    _register(T.toString(), P.toString(), factoryFunc);
  }

  static void _register(
      String instanceTypeString, String paramTypeString, dynamic factoryFunc) {
    final currentMap = _factoryMap[instanceTypeString];
    if (currentMap == null) {
      _factoryMap[instanceTypeString] = {paramTypeString: factoryFunc};
    } else {
      final existedFactoryFunc = currentMap[paramTypeString];
      if (existedFactoryFunc != null) {
        print(
            "- [DI] Warning: duplicated factory ${existedFactoryFunc.runtimeType}, the old one is gonna be overriden by the new one");
      }
      currentMap[paramTypeString] = factoryFunc;
    }

    if (_factoryMap.containsKey(instanceTypeString)) {
      _factoryMap[instanceTypeString]?[paramTypeString] = factoryFunc;
    } else {
      _factoryMap[instanceTypeString] = {paramTypeString: factoryFunc};
    }
  }

  static T resolve<T>() {
    String instanceTypeString = T.toString();
    try {
      return _factoryMap[instanceTypeString]![_voidTypeString]() as T;
    } catch (e) {
      print(
          "- [DI] Error: Unregister factory () => $instanceTypeString, registered list: ${_factoryMap[instanceTypeString]?.values.map((e) => e.runtimeType)}");
      rethrow;
    }
  }

  static T resolveWithParam<T>(dynamic param) {
    String instanceTypeString = T.toString();
    String paramTypeString = param.runtimeType.toString();
    try {
      return _factoryMap[instanceTypeString]![paramTypeString](param) as T;
    } catch (e) {
      print(
          "- [DI] Error: Unregister factory ($paramTypeString) => $instanceTypeString, registered list: ${_factoryMap[instanceTypeString]?.values.map((e) => e.runtimeType)}");
      rethrow;
    }
  }

  static T resolveSingleton<T>() {
    final instanceTypeString = T.toString();
    final oldInstance = _singletonInstances[instanceTypeString];
    if (oldInstance != null) {
      return oldInstance;
    } else {
      final newInstance = resolve<T>();
      _singletonInstances[instanceTypeString] = newInstance;
      return newInstance;
    }
  }
}
