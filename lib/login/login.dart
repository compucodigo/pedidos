import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:pedidos/orders/orders.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginScreen extends StatelessWidget {
  final TextEditingController teUser = TextEditingController();
  final TextEditingController tePass = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  loginScreen({super.key});
  final RegExp erMail = RegExp(r'[A-Z]');
  final RegExp erPass = RegExp(r'^.{1,15}$');

  soloLetras(String texto) {
    if (texto != '') {
      if (erMail.hasMatch(texto)) {
        return null;
      } else {
        return 'Caracter no admitido';
      }
    } else {
      return 'Coloque el usuario';
    }
  }

  validarPass(String texto) {
    if (texto != '') {
      if (erPass.hasMatch(texto)) {
        return null;
      } else {
        return 'A superado el limite de caracteres';
      }
    } else {
      return 'Coloque el password';
    }
  }

  Future<bool> logIn(String user, String pass, String empresa) async {
    empresa = '1';
    dynamic respToken = '';
    String data =
        json.encode({'user': user, 'password': pass, 'enterprise': empresa});
    String urlApi = 'https://api.asoportuguesa.net/login/pedidos';

    Uri uriApi = Uri.parse(urlApi);
    http.Response resp = await http.post(uriApi, body: {'data': data});
    if (resp.statusCode == 200) {
      print(resp.body);
      SharedPreferences preferencia = await SharedPreferences.getInstance();
      respToken = json.decode(resp.body);
      String jwt = respToken['payload']['token'];
      Map<String, dynamic> jwt_decoded = JwtDecoder.decode(jwt);
      String username = jwt_decoded['name_user'];
      await preferencia.setString('token', jwt);
      await preferencia.setString('username', username);
      return true;
    } else {
      return false;
    }
  }

  Future<void> verifyToken(BuildContext context) async {
    SharedPreferences preferencia = await SharedPreferences.getInstance();
    String? token = preferencia.getString('token');
    print(token);
    if (token != null && token != '') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OrdersScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    verifyToken(context);
    return Scaffold(
        body: Form(
      key: formKey,
      child: Center(
        child: Card(
          margin: EdgeInsets.all(150),
          child: Container(
              padding: EdgeInsets.all(50),
              child: Column(
                children: [
                  Image.asset('assets/LOGO_DE_BG.png', width: 120, height: 120),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Usuario ej. Juan'),
                    controller: teUser,
                    validator: (value) => soloLetras(teUser.text.toUpperCase()),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Contraseña ej. 123456'),
                    controller: tePass,
                    validator: (value) => validarPass(tePass.text),
                    obscureText: true,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          if (await logIn(teUser.text, tePass.text, '1')) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrdersScreen()));
                          }
                        } else {
                          print('object error');
                        }
                      },
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(color: Colors.red),
                      ))
                ],
              )),
        ),
      ),
    ));
  }
}
