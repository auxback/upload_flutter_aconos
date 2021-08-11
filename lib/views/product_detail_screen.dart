import 'package:flutter/material.dart';
import 'package:shop/providers/product.dart';

// Tela que mostra os detalhes do produto
class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final precisa ser inicializada por constr ou diretamente
    // modalRoute passa o ctx e var para o outro widget por argumento
    // Pode ser tanto o cast quanto por referência de instância (Prod prod)
    final Product product =
        ModalRoute.of(context).settings.arguments as Product;
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 300,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'R\$ ${product.price}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(
                product.description,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
