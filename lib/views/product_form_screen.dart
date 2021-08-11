import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';

// Há 2 formas de passar o Product: null ou por arguments

class ProductFormScreen extends StatefulWidget {
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  //----------------------//----------------------//----------------------//----
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _imageUrlFocus = FocusNode();

  final _imageUrlController = TextEditingController();

  final _formGK = GlobalKey<FormState>();

  final _formData = Map<String, Object>();

  bool _isLoading = false;

  //----------------------//----------------------//----------------------//----
  @override
  void initState() {
    print('initState');
    super.initState();
    _imageUrlFocus.addListener(_updateImage);
  }

  //----------------------//----------------------//----------------------//----
  // Ainda não sei como usar.
  @override
  void didChangeDependencies() {
    print('didChange');
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final product = ModalRoute.of(context).settings.arguments as Product;

      if (product != null) {
        _formData['id'] = product.id;
        _formData['title'] = product.title;
        _formData['price'] = product.price;
        _formData['description'] = product.description;
        _formData['imageUrl'] = product.imageUrl;

        // POR QUE COLOCA AQUI, E NÃO NO INITIAL ?!
        _imageUrlController.text = _formData['imageUrl'];
      } else {
        _formData['price'] = '';
      }
    }
  }

  //----------------------//----------------------//----------------------//----
  void _updateImage() {
    setState(() {});
  }
  //----------------------//----------------------//----------------------//----

  bool _isValidImageUrl(String url) {
    bool startWithHttp = url.toLowerCase().startsWith('http://');
    bool startWithHttps = url.toLowerCase().startsWith('https://');
    // algum motivo, as imagens não tem no final jpg e tal
    // bool endsWithPng = url.toLowerCase().endsWith('.png');
    // bool endsWithJpg = url.toLowerCase().endsWith('.jpg');
    // bool endsWithJpeg = url.toLowerCase().endsWith('jpeg');

    return (startWithHttps || startWithHttp);
    // && (endsWithJpeg || endsWithJpg || endsWithPng);
  }

  //----------------------//----------------------//----------------------//----
  Future<void> _saveForm() async {
    bool isValid = _formGK.currentState.validate();

    if (!isValid) return;

    _formGK.currentState.save();

    final product = Product(
      id: _formData['id'],
      title: _formData['title'],
      description: _formData['description'],
      price: _formData['price'],
      imageUrl: _formData['imageUrl'],
    );

    setState(() {
      _isLoading = true;
    });

    final products = Provider.of<Products>(context, listen: false);

    try {
      if (_formData['id'] == null) {
        await products.addProduct(product);
      } else {
        await products.updateProduct(product);
      }
      // vai ser null ou não, senão dá catch
      Navigator.of(context).pop();
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ocorreu um erro interno'),
          // Poderia usar error de catchError aqui se quisesse.
          content: Text('Aperte "OK" para enviar o erro para tratamento'),
          actions: [
            TextButton(
              onPressed: () {
                _isLoading = false;
                // todo pop é passado para o próximo then ou catchError
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } finally {
      setState(
        () {
          _isLoading = false;
        },
      );
    }
  }

  //----------------------//----------------------//----------------------//----
  // O dispose só é chamado quando o widget precisa ser reconstruído.
  @override
  void dispose() {
    print('dispose');
    super.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    _imageUrlFocus.removeListener(_updateImage);
    _imageUrlFocus.dispose();
  }

  //----------------------//----------------------//----------------------//----

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Produto'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formGK,
              child: ListView(
                padding: EdgeInsets.all(15.0),
                children: [
                  TextFormField(
                    initialValue: _formData['title'],
                    decoration: InputDecoration(labelText: 'Título'),
                    // vai pra próximo elemento, mas precisa do "foco"
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_priceFocus),
                    onSaved: (value) => _formData['title'] = value,
                    validator: (value) {
                      if (value.trim().isEmpty) {
                        return 'Informe um título';
                      }

                      if (value.trim().length < 2) {
                        return 'Mínimo de 2 letras';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _formData['price'].toString(),
                    decoration: InputDecoration(labelText: 'Preço'),
                    keyboardType: TextInputType.numberWithOptions(
                        decimal:
                            true), // permite usar teclado numérico com vírgula
                    textInputAction: TextInputAction.next,
                    focusNode: _priceFocus,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_descriptionFocus),
                    onSaved: (value) =>
                        _formData['price'] = double.parse(value),
                    validator: (value) {
                      bool isEmpty = value.trim().isEmpty;
                      var newPrice = double.tryParse(value);
                      bool isInvalid = newPrice == null || newPrice <= 0;

                      if (isEmpty || isInvalid)
                        return 'Informe um valor maior que zero';

                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _formData['description'],
                    decoration: InputDecoration(labelText: 'Descrição'),
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    maxLength: 1000,
                    //textInputAction: TextInputAction.next,  // Pode atrapalhar caso queira só passar para prox linha
                    focusNode: _descriptionFocus,
                    onSaved: (value) => _formData['description'] = value,
                    validator: (value) {
                      bool isEmpty = value.trim().isEmpty;
                      bool isInvalid = value.trim().length < 10;

                      if (isEmpty || isInvalid)
                        return 'Informe uma descrição. Mínimo 10 caracteres';
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration:
                              InputDecoration(labelText: 'URL da imagem'),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          focusNode: _imageUrlFocus,
                          controller: _imageUrlController,
                          onFieldSubmitted: (_) {
                            _saveForm();
                          },
                          onSaved: (value) => _formData['imageUrl'] = value,
                          validator: (value) {
                            bool isEmpty = value.trim().isEmpty;
                            bool validUrl = !_isValidImageUrl(value);

                            if (isEmpty || validUrl)
                              return 'Informe uma URL válida';

                            return null;
                          },
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 100,
                        margin: EdgeInsets.only(
                          top: 8,
                          left: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: _imageUrlController.text.isEmpty
                            ? Text('informe a URL')
                            : FittedBox(
                                child: Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
