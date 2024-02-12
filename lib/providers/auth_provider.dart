import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/common/constant.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  Dio dio = Dio();

  AuthProvider() {
    init();
  }

  login(String email, String password) async {
    try {
      final response = await dio.post(
        '$base_url/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['error'] == false) {
        final sharedPref = await SharedPreferences.getInstance();
        sharedPref.setString('token', response.data['loginResult']['token']);
        _isLoggedIn = true;
        notifyListeners();
      }

      return response.data;
    } catch (e) {
      return {
        "error": true,
        'message': 'Pastikan Data Benar atau User Telah Terdaftar',
      };
    }
  }

  register(String name, String email, String password) async {
    try {
      final response = await dio.post(
        '$base_url/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data;
    } catch (e) {
      return {
        "error": true,
        'message': 'Pastikan Data Benar atau User Telah Terdaftar',
      };
    }
  }

  logout() async {
    final sharedPref = await SharedPreferences.getInstance();
    sharedPref.remove('token');
    _isLoggedIn = false;
    notifyListeners();
  }

  bool get isLoggedIn => _isLoggedIn;

  init() async {
    var sharedPref = await SharedPreferences.getInstance();
    final token = sharedPref.getString('token');
    _isLoggedIn = token != null;
    notifyListeners();
  }
}

final authProvider = ChangeNotifierProvider((ref) => AuthProvider());
