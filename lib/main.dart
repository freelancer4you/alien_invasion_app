import 'dart:io';

import 'package:flutter/material.dart';
import 'domain/benutzer.dart';
import 'menu_dashboard_layout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';

void main(){
  HttpOverrides.global = new DevHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft]).then((_){
    runApp(MyApp());
  });
}

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
//https://stackoverflow.com/questions/36991562/how-can-i-set-up-a-letsencrypt-ssl-certificate-and-use-it-in-a-spring-boot-appli
//https://dzone.com/articles/spring-boot-secured-by-lets-encrypt
//https://stackoverflow.com/questions/4398300/map-ip-to-hostname-in-linux
//https://wstutorial.com/rest/spring-boot-with-lets-encrypt.html
//https://auth0.com/blog/get-started-with-flutter-authentication/
Future<Benutzer> login(final String login) async {
  // Web geht aktuell nur ohne https
   //final response =
  //await http.get('http://192.168.2.116:8000/user/' + login);

  //await http.get('https://192.168.2.116:8000/user/' + login);
  // HANDY
   final HttpClient client = new HttpClient();
   client.badCertificateCallback =((X509Certificate cert, String  host, int port) => true);
   final HttpClientRequest request = await client.getUrl(Uri.parse('https://192.168.2.116:8000/user/' + login));
   request.headers.set('Content-Type', 'application/json');
   final HttpClientResponse response = await request.close();

  if (response.statusCode == 200) {
    // Handy
    return Benutzer.fromJson(jsonDecode(await response.transform(utf8.decoder).join()));
    // WEB
    //final jsonresponse = jsonDecode(response.body);
    //debugPrint('response: $jsonresponse');
    //return Benutzer.fromJson(jsonresponse);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to login');
  }
}

class CallbackMethodHolder {
  Function callback;
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom map',

      home: FutureBuilder<Benutzer>(
        // future: Future.wait([
        //   login("firstUserLogin")
        // ])
          future: login("1001"),
          builder: (BuildContext context, AsyncSnapshot<Benutzer> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting: return Text('Loading....');
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                else {

                  final Benutzer benutzer = snapshot.data;
                  //print(benutzer);
                  final MapController mapController = MapController();
                  return MenuDashboardPage(
                      benutzer,
                      mapController
                  );
                }
            }
          }
      )
    );
  }
}