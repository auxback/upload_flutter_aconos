import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/providers/auth.dart';

enum AuthMode { SignUp, Login }

class AuthCard extends StatefulWidget {
  //const AuthCard({Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
//------------------------------------------------------------------------------
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  GlobalKey<FormState> _form = GlobalKey();
  final _passwordController = TextEditingController();
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
//------------------------------------------------------------------------------
  Future<void> _submite() async {
    if (!_form.currentState.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Este tá conectado com "onSaved:" do Form
    _form.currentState.save();

    Auth auth = Provider.of(context, listen: false);

    void _showErrorDialog(String msg) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ocorreu um erro'),
          content: Text(msg),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('fechar'))
          ],
        ),
      );
    }

    try {
      if (_authMode == AuthMode.Login) {
        await auth.signIn(
          _authData['email'],
          _authData['password'],
        );
      } else {
        await auth.signUp(
          _authData['email'],
          _authData['password'],
        );
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('ocorreu um erro inesperado!');
    }

    setState(() {
      _isLoading = false;
    });
  }

//------------------------------------------------------------------------------
  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
    } else if (_authMode == AuthMode.SignUp) {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

//------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final _deviceSize = MediaQuery.of(context).size;

    return Card(
      margin: EdgeInsets.only(top: 20.0),
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        height: _authMode == AuthMode.Login ? 300 : 400,
        width: _deviceSize.width * 0.75,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value.isEmpty || !value.contains('@')) {
                    return 'informe um e-mail válido. Com ao menos "@"';
                  }
                  return null;
                },
                onSaved: (value) => _authData['email'] = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                controller: _passwordController,
                validator: (value) {
                  if (value.isEmpty || value.length <= 5) {
                    return 'informe uma senha válida. Tendo mais de 5 carácteres';
                  }
                  return null;
                },
                onSaved: (value) => _authData['password'] = value,
              ),
              if (_authMode == AuthMode.SignUp)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Confirmar senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty || value.length <= 5) {
                      return 'informe uma senha válida. Tendo mais de 5 carácteres';
                    } else if (value != _passwordController.text) {
                      return 'Senha diferente da anterior';
                    }
                    return null;
                  },
                ),
              Spacer(),
              if (_isLoading)
                CircularProgressIndicator()
              else
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _submite,
                    child: Text(
                      _authMode == AuthMode.Login ? 'ENTRAR' : 'REGISTRAR',
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _switchAuthMode,
                  //style: ButtonStyle(shape: ),
                  child: Text(
                    'ALTERNAR P/ ${_authMode == AuthMode.Login ? 'REGISTRAR' : 'LOGIN'}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
