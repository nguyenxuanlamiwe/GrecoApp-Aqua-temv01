class LocalStoreKey {
  LocalStoreKey._();

  static const tbCredential = "tbCredential";
  static const loggedInUser = "loggedInUser";
  static const prevUsername = "prevUsername";
  static const prevPassword = "prevPassword";
  static const saveLoginInfo = "saveLoginInfo";
  // per-device optional features (List<String>)
  static String systemFeatures(String deviceId) => "features_$deviceId";
}
