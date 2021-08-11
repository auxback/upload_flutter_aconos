import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/widgets/product_grid_item.dart';

// Lista em forma de grade

class ProductGrid extends StatelessWidget {
  final bool showFavoriteOnly;

  const ProductGrid(this.showFavoriteOnly);

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<Products>(context); // Provider
    final products = showFavoriteOnly // Lista de produtos filtrada ou não
        ? productsProvider.favoriteItems
        : productsProvider.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        // Precisa da localização do changeNotify
        //mesma classe em cada product na lista de products
        // Abaixo, product para cada ítem da lista
        value: products[i], // value tem inst do Prov. na lista.
        // itemBuilder é executado até o fim da lista
        // E, talvez, o que vai diferenciar um de cada é value, pois era por construtor
        child: ProductGridItem(),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
