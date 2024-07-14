import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesClass{
  static const String email = "email";
  static const String phone = "phone";
  static const String token = 'token';
  static const String tenant = "tenant";
  static const String cookieName = "cookieName";
  static const String twoFactor = "twoFactor";
  static const String idAndCookie = "IdAndCookie";
  static const String roleList = "roleList";
  static const String selectedRollId = "selectedRollId";
  static const String selectedWarehouseId = "selectedWarehouseId";
  static const String selectedRole = "selectedRole";
  static const String warehouseList = "warehouseList";
  static const String selectedWarehouse = "selectedWarehouse";
  static const String navBarContentMapList = "navBarContentMapList";
  static const String rolePermissionList = "rolePermissionList";
  static const String userId = "userId";
  static const String userName = "";
  static const String fcmToken = "fcmToken";


  static setValue(String key,String? value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value!);
  }

  static setRemoteModeType(String key,int? value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value!);
  }

  static Future<int?> getRemoteModeType(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var value = prefs.getInt(key);
      return value;
    } catch (error) {
      return null;
    }
  }

  static setLanguageIntValue(String key,int? value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value!);
  }

  static Future<int?> getSelectLanguage(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var value = prefs.getInt(key);
      return value;
    } catch (error) {
      return null;
    }
  }

  static Future<String?> getValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var value = prefs.getString(key);
      print("getValue.....${value}");

      return value;
    } catch (error) {
      return null;
    }
  }

  static Future<List<String>> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    if (value != null) {
      final List<dynamic> decoded = jsonDecode(value);
      final List<String> stringList = decoded.cast<String>();
      //print("stringList......share..succ..$stringList");
      return stringList;
    } else {
      //print("stringList......share....fail");
      return [];
    }
  }

  static Future<List<dynamic>> getMapList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var value = prefs.getString(key);
      //print("getValueList.....${value}");

      if (value != null) {
        return List<Map<String, dynamic>>.from(json.decode(value));
      }

      return [];
    } catch (error) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getMap(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var value = prefs.getString(key);
      //print("getValueList.....${value}");

      if (value != null) {
        return json.decode(value);
      }

      return {};
    } catch (error) {
      return {};
    }
  }

  static setIntValue(String key,int? value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value!);
  }

  static setBoolValue(String key,bool? value) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value!);
  }

  static Future<int?> getIntValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var value = prefs.getInt(key);
      return value;
    } catch (error) {
      return null;
    }
  }

  static Future<bool?> getBoolValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var value = prefs.getBool(key);
      return value;
    } catch (error) {
      return null;
    }
  }

  static deleteKey(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  static storeLocalData({@required String? key,@required String? value}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key!, value!);
  }

  static Future<String?> getLocalData({@required String? key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key!);
  }
}