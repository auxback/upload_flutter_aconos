import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/badge.dart';
import 'package:shop/widgets/product_grid.dart';
import '../utils/app_routes.dart';

enum FilterOptions {
  Favorite,
  All,
}

// Tela mostrando lista de produtos
class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _showFavoriteOnly = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // "listen = false" pq vai ficar por initState
    Provider.of<Products>(context, listen: false).loadProducts().then(
      (_) {
        setState(
          () {
            _isLoading = false;
          },
        );
      },
    );
  }
  // ao voltar n executa o build pois espera

  @override
  Widget build(BuildContext context) {
    // Onde conecta esse contexto ao contexto do main (ctx)
    return Scaffold(
      appBar: AppBar(
        title: Text('Minha Loja'),
        actions: <Widget>[
          Consumer<Cart>(
            // Em relação ao Consumer, child é o que não vai ser modificado
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.CART);
              },
            ),
            // O que vai ser modificado:
            builder: (ctx, cart, child) => Badge(
              value: cart.itemsCount.toString(),
              child: child,
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('favoritos'),
                value: FilterOptions.Favorite,
              ),
              PopupMenuItem(
                child: Text('todos'),
                value: FilterOptions.All,
              ),
            ],
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorite) {
                  _showFavoriteOnly = true;
                } else {
                  _showFavoriteOnly = false;
                }
              });
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductGrid(_showFavoriteOnly),
    );
  }
}
