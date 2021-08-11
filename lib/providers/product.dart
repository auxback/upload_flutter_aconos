import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/utils/constants.dart';

//    MARCAÇÃO FAVORITO
// A marcação de favorito foi deixado nos próprios produtos internamente e no
//servidor fica uma parte separada para os favoritos de cada usuário.

class Product with ChangeNotifier {
  // id é do retorno do servidor
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    this.id,
    @required this.description,
    @required this.title,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });
//------------------------------------------------------------------------------
  Future<void> toggleFavorite(String token, String userId) async {
    final _baseUrl = '${Constants.BASE_API_URL}/userFavorites/$userId';

    isFavorite = !isFavorite;

    //    PATCH ou PUT ?
    // Precisa mandar "put", pq vai mudar toda a info e não uma das info
    //caso usando "patch".
    final response = await http.put(
      Uri.parse('$_baseUrl/$id.json?auth=$token'),
      // Manda apenas uma marcação logo após o token do produto.
      body: jsonEncode(isFavorite),
    );

    if (response.statusCode >= 400) {
      isFavorite = !isFavorite;

      //notify, pois quando dá erro o código para aqui
      notifyListeners();

      throw HttpException('Ocorreu um erro ao favoritar.');
    }

    notifyListeners();
  }
}
