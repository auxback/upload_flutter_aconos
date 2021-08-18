import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/utils/constants.dart';

class Order {
  final String id;
  final num total; //final double total;
  final List<CartItem> products;
  final DateTime date;

  Order({
    this.id,
    this.total,
    this.products,
    this.date,
  });
}

class Orders with ChangeNotifier {
  Orders([this._token, this._items = const [], this._userId]);

  String _userId;

  String _token;

  List<Order> _items = [];

  List<Order> get items => [..._items];

  final _baseUrl = '${Constants.BASE_API_URL}/orders';

  int get itemsCount {
    return _items.length;
  }

//----------------------------------------------------------------------------//

  // ADICIONAR PEDIDO

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();

    final response = await http.post(
      Uri.parse('$_baseUrl/$_userId.json?auth=$_token'),
      //Aqui tmbm poderia ser colocado try e tal
      body: jsonEncode(
        {
          'total': cart.totalAmount,
          'date': date.toIso8601String(),
          // retorna um Map para cada item (=> {})
          'products': cart.items.values
              .map(
                (cartItem) => {
                  'title': cartItem.title,
                  'quantity': cartItem.quantity,
                  'id': cartItem.id,
                  'productId': cartItem.productId,
                  'price': cartItem.price,
                },
              )
              .toList(),
        },
      ),
    );

    // Insere o elementos (products) na lista a partir de tal posição (0).
    // elementos inseridos a partir do começo e não sempre do fim.
    _items.insert(
      0,
      Order(
        id: jsonDecode(response.body)['name'],
        total: cart.totalAmount,
        products: cart.items.values.toList(),
        date: date,
      ),
    );

    notifyListeners();
  }

//----------------------------------------------------------------------------//

  // CARREGA OS PEDIDOS

  Future<void> loadOrders() async {
    List<Order> _loadedItems = [];

    final response = await http.get(
      Uri.parse('$_baseUrl/$_userId.json?auth=$_token'),
    );

    // retorna no padrão json Map<String, Map<String, dynamic>>
    Map<String, dynamic> data = jsonDecode(response.body);

    if (data != null) {
      // novamente n se faz forEach no nada
      data.forEach((orderId, orderData) {
        _loadedItems.add(
          Order(
            // As key (productData[...]) abaixo são exatas do servidor
            id: orderId,
            total: orderData['total'],
            date: DateTime.parse(orderData['date']),
            // Aqui a parada foi punk !
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    productId: item['productId'],
                    price: item['price'],
                  ),
                )
                .toList(),
          ),
        );
      });
      // sempre vai vir mais recente 1º
      _items = _loadedItems.reversed.toList();
      // Notifica todos os interessados
      notifyListeners();
    }

    return Future.value();
  }
}
