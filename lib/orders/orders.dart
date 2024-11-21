import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});
  final currentDate = DateTime.now();
  final formatDate = DateFormat('dd/MM/yyyy');

  Future<String?> getUserName() async {
    SharedPreferences preferencia = await SharedPreferences.getInstance();

    return preferencia.getString('username');
  }

  Future<dynamic> getClients() async {
    dynamic clients = '';
    SharedPreferences preferencia = await SharedPreferences.getInstance();
    String? token = preferencia.getString('token');
    Map<String, dynamic> data = ({'vendedor': '0302', 'enterprise': '1'});
    String urlApi =
        'http://192.168.4.125:8081/ventas/pedidos/clientes/vendedor';

    Uri uriApi = Uri.parse(urlApi);
    http.Response respClients = await http.get(
        uriApi.replace(queryParameters: data),
        headers: {'authorization': 'Bearer ' + token!});
    if (respClients.statusCode == 200) {
      clients = json.decode(respClients.body);
    }
    return clients.payload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Image.asset(
              'assets/LOGO_DE_BG.png',
              width: 150,
              height: 150,
            ),
            Text('Postear pedido'),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(formatDate.format(currentDate)),
              FutureBuilder<String?>(
                  future: getUserName(),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      if (snap.data != null) {
                        return Text(snap.data!);
                      } else {
                        return Text('No hay vendedor');
                      }
                    } else {
                      return Text('No hay vendedor');
                    }
                  }),
              Container(
                width: 120,
                child: DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(
                          child: const Text('Crédito'), value: 'CR'),
                      DropdownMenuItem(
                          child: const Text('Contado'), value: 'CO')
                    ],
                    onChanged: (value) {
                      print(value);
                    }),
              ),
            ]),
            FutureBuilder<dynamic>(
                future: getClients(),
                builder: (context, snap) {
                  if (snap.hasData) {
                    if (snap.data != null) {
                      print(snap.data);
                      // List<DropdownMenuItem> clientsWidget = [];
                      return Text('tiene datos');
                      // payload =
                      // for (var client in snap.data.payload) {
                      //   clientsWidget.add(DropdownMenuItem(
                      //       value: client.id,
                      //       child: Text(client.nombre_cliente)));
                      // }
                      // return DropdownButtonFormField(
                      //     items: clientsWidget,
                      //     onChanged: (value) {
                      //       print(value);
                      //     });
                    } else {
                      return Text('No hay clientes');
                    }
                  } else {
                    return Text('No hay clientes');
                  }
                }),
            Text('Observation'),
            Text('Header product'),
            Text('Products'),
            Text('Controllers')
          ],
        ),
      ),
    );
  }
}
