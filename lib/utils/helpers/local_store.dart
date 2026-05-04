import 'package:shared_preferences/shared_preferences.dart';

typedef LocalStoreTransformFunc<T> = T? Function(dynamic value);

class LocalStore {
  Future<T?> getValue<T>(
    String key, {
    T? defaultValue,
    LocalStoreTransformFunc<T>? transform,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      var value = prefs.get(key);
      if (transform != null) {
        return transform(value) ?? defaultValue;
      } else {
        return (value as T?) ?? defaultValue;
      }
    } catch (e) {
      return defaultValue;
    }
  }

  Future<bool> setValue(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is bool) {
      return await prefs.setBool(key, value);
    }

    if (value is int) {
      return await prefs.setInt(key, value);
    }

    if (value is double) {
      return await prefs.setDouble(key, value);
    }

    if (value is String) {
      return await prefs.setString(key, value);
    }

    if (value is List<String>) {
      return await prefs.setStringList(key, value);
    }

    print('[LocalStore] Unsupported shared preferences data type: $value');
    return false;
  }

  Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  Future<void> removeMany(Iterable<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    for (var aKey in keys) {
      await prefs.remove(aKey);
    }
  }
}
