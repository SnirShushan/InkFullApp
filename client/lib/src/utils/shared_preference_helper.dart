import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String homeScreenApi = "homeScreenApiHold";
  static const String inspirationScreenApi = "inspirationScreenApiHold";
  static const String businessScreenApi = "businessScreenApiHold";

  //Save homeScreenApi Hold Time
  static Future<void> saveHomeApiHoldTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(homeScreenApi, DateTime.now().toString());
  }

  //Get homeScreenApi Hold Time
  static Future<String?> getHomeApiHoldTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(homeScreenApi);
  }

  //Save inspirationScreenApi Hold Time
  static Future<void> saveInspirationApiHoldTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(inspirationScreenApi, DateTime.now().toString());
  }

  //Get inspirationScreenApi Hold Time
  static Future<String?> getInspirationApiHoldTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(inspirationScreenApi);
  }

  //Save inspirationScreenApi Hold Time
  static Future<void> saveBusinessScreenApiHoldTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(businessScreenApi, DateTime.now().toString());
  }

  //Get inspirationScreenApi Hold Time
  static Future<String?> getBusinessScreenApiHoldTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(businessScreenApi);
  }

  // Method to clear data (optional)
  static Future<void> clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(homeScreenApi);
    await prefs.remove(inspirationScreenApi);
    await prefs.remove(businessScreenApi);
  }
}
