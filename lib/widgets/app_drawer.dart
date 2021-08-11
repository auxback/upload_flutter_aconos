import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/utils/app_routes.dart';

// A alteração de tirar o Replacement pode fazer com que, talvez, as telas fiquem
//na memória e sobrecarregue a aplicação.

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Bem Vindo Usuário!'),
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Loja'),
            onTap: () =>
                // INVÉS DE FAZER STACK SUBSTITUI A TELA POR OUTRA
                Navigator.of(context).pushReplacementNamed(AppRoutes.HOME),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Pedidos'),
            onTap: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.ORDERS),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Gerenciar Produtos'),
            onTap: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.PRODUCTS),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('sair da conta'),
            onTap: () {
              Provider.of<Auth>(context, listen: false).logout();
              Navigator.of(context)
                  .pushReplacementNamed(AppRoutes.SCREEN_FOR_AUTH);
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
