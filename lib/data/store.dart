import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// PERSISTENT STORAGE

// O pricipal uso dessa class é pra guardar os dados do usuário localmente, pr
//q possa ser feito autoLogin.

// Deixou tds os mét da class em static pr serem usadas em qlqr lugar.

class Store {
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

//------------------------------------------------------------------------------

  static Future<void> saveMap(String key, Map<String, dynamic> value) async {
    saveString(key, jsonEncode(value));
  }

//------------------------------------------------------------------------------

  static Future<String> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

//------------------------------------------------------------------------------

  static Future<Map<String, dynamic>> getMap(String key) async {
    try {
      Map<String, dynamic> map = await json.decode(await getString(key));
      return map;
    } catch (_) {
      return null;
    }
  }

//------------------------------------------------------------------------------

  // Usado lá em logout pra remover as info localmente do usu quando der logout
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
