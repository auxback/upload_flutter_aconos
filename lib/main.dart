import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/orders.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/utils/app_routes.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/views/cart_screen.dart';
import 'package:shop/views/orders_screen.dart';
import 'package:shop/views/product_detail_screen.dart';
import 'package:shop/views/product_form_screen.dart';
import 'package:shop/views/product_overview_screen.dart';
import 'package:shop/views/products_screen.dart';
import 'package:shop/views/screen_for_auth.dart';
import './utils/app_routes.dart';

// Existe 1 Provider com 2 ChangeNotifier (Product e ProductProvider)

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Reconstroi o abaixo

      providers: [
        // Já q Auth vem antes, ai dá print antes
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        //ProxyProvider precisar usar qm ta acima dele
        //Precisa ter o generic pra auth fazer sentido com Auth
        // Único método de fazer Providers conversarem entre si.
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) {
            print('create');
            return Products();
          },
          // Só preciso saber qual o momento q o token vai mudar
          update: (ctx, auth, previousProducts) {
            print('update');
            return Products(
              // "previous" deve ser obrigatório msm
              // No momento de colocar o "token", Products é reconstruído com "create" dnv, por isso precisa de "previous"
              auth.token,
              // O principal é passar o "token". Provider n tem "context", por isso faz aqui.
              previousProducts.items,
              auth.userId,
            );
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) {
            print('Cart');
            return Cart();
          },
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders(),
          update: (ctx, auth, previousOrders) {
            return Orders(
              auth.token,
              previousOrders.items,
              auth.userId,
            );
          },
        ),
      ],
      child: MaterialApp(
        title: 'Minha Loja',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          accentColor: Colors.deepOrange,
          fontFamily: 'Lato',
        ),
        //home: AuthScreen(),
        routes: {
          //AppRoutes.AUTH: (ctx) => AuthScreen(),
          AppRoutes.SCREEN_FOR_AUTH: (ctx) => ScreenForAuth(),
          AppRoutes.HOME: (ctx) => ProductOverviewScreen(),
          AppRoutes.CART: (ctx) => CartScreen(),
          AppRoutes.PRODUCT_DETAIL: (ctx) => ProductDetailScreen(),
          AppRoutes.ORDERS: (ctx) => OrdersScreen(),
          AppRoutes.PRODUCTS: (ctx) => ProductsScreen(),
          AppRoutes.PRODUCT_FORM: (ctx) => ProductFormScreen(),
        },
      ),
    );
  }
}
