import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/store.dart';
import 'package:shop/exceptions/auth_exception.dart';
//import 'package:shop/exceptions/auth_exception.dart';

// Em cada requisição é preciso mostrar q tem o token, pois a API REST não tem estado.
class Auth with ChangeNotifier {
  String _userId;
  String _token;

  DateTime _expiryDate;

  Timer _logoutTimer;

  String get userId {
    return isAuth ? _userId : null;
  }

  // retorna o resultado
  bool get isAuth {
    return token != null;
  }

  // Se for não for nulo e tiver tempo maior que o atual, retorna token orig
  String get token {
    if (_token != null &&
        _expiryDate.isAfter(
          DateTime.now(),
        )) {
      return _token;
    } else {
      return null;
    }
  }

//------------------------------------------------------------------------------

  Future<void> _authentication(
      String email, String password, String segmentUrl) async {
    String _url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$segmentUrl?key=AIzaSyCNxRdwlwCjFVHN3K5QLw_jVUSn_Jgu8ew';

    final response = await http.post(
      Uri.parse(_url),
      body: jsonEncode(
        {
          // email e pass estão em authCard
          'email': email,
          'password': password,
          'returnSecureToken': true, // Deve ser enviado e sempre true
        },
      ),
    );

    final responseBody = jsonDecode(response.body);
    print(response.body.toString());
    if (responseBody['error'] != null) {
      // entrega a "message" que é de um Map de Map
      throw AuthException(responseBody['error']['message']);
    } else {
      _token = responseBody['idToken']; // varia
      _userId = responseBody['localId']; // cada usuário tem um
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseBody['expiresIn']),
        ),
      );
      //print(responseBody.toString());
    }

    Store.saveMap(
      'userData',
      {
        'token': _token,
        'userId': _userId,
        // Esse toIso precisa smp ser usado senão não funciona.
        //Se só "_expiryDate," não dá certo (muito erro).
        'expiryDate': _expiryDate.toIso8601String(),
      },
    );

    _autoLogout();

    notifyListeners();

    return Future.value();
  }

//------------------------------------------------------------------------------

  Future<void> signIn(String email, String password) async {
    //authentication já retorna um future.value()
    return _authentication(email, password, 'signInWithPassword');
  }

//------------------------------------------------------------------------------

  Future<void> signUp(String email, String password) async {
    return _authentication(email, password, 'signUp');
  }

//------------------------------------------------------------------------------

  Future<void> autoLogin() async {
    if (isAuth) {
      return Future.value();
    }

    final userData = await Store.getMap('userData');

    // Caso tenha dado logout, sai exat aqui
    if (userData == null) {
      return Future.value();
    }

    // Passa de string pra DateTime
    // Depois do toIso8601 pode passar pra DateTime
    final expiryDate = DateTime.parse(userData['expiryDate']);

    // Se o tempo expirou, para de fazer login auto
    if (expiryDate.isBefore(DateTime.now())) {
      return Future.value();
    }

    _userId = userData['userId'];
    _token = userData['token'];
    _expiryDate = expiryDate;

    autoLogin();

    notifyListeners();
  }

//------------------------------------------------------------------------------

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;

    if (_logoutTimer != null) {
      _logoutTimer.cancel();
      _logoutTimer = null;
    }

    Store.remove('userData');

    notifyListeners();
  }

//------------------------------------------------------------------------------

  // No logout automático, caso eu dê logout e fique na aplicação, em auth, pode ser que
  //o tempo de logout auto. do outro login ainda se mantenha, logo precisa de um novo a
  //cada login

  // cancelar o timer só pausa, deve deixar o timer nulo.

  void _autoLogout() {
    if (_logoutTimer != null) _logoutTimer.cancel();
    final timeToLogout = _expiryDate.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(Duration(seconds: timeToLogout), logout);

    if (timeToLogout == 0) {}
  }
}
