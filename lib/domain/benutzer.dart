import 'gebaeude.dart';
import 'gebaeude_list.dart';

class Benutzer {
   String login;
   String email;
   String passwort;
   double latitude;
   double longitude;
   int rang;
   List<Gebaeude> besetzteGebaude;
   List<Gebaeude> inderNaeheBefindlicheGebaeude;

   Benutzer({
     this.login,
     this.email,
     this.passwort,
     this.latitude,
     this.longitude,
     this.rang,
     this.besetzteGebaude,
     this.inderNaeheBefindlicheGebaeude});

  factory Benutzer.fromJson(Map<String, dynamic> json) {

    GebaeudeList besetzteGebaude = GebaeudeList.fromJson(json['besetzteGebaude']);
    GebaeudeList inderNaeheBefindlicheGebaeude = GebaeudeList.fromJson(json['inderNaeheBefindlicheGebaeude']);

    return Benutzer(
        login: json['login'],
        email: json['email'],
        passwort: json['passwort'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        rang: 1,
        besetzteGebaude: besetzteGebaude.gebaeude,
        inderNaeheBefindlicheGebaeude: inderNaeheBefindlicheGebaeude.gebaeude
    );
  }

   @override
  String toString() {
    return 'Benutzer{login: $login, email: $email, passwort: $passwort, latitude: $latitude, longitude: $longitude, rang: $rang, besetzteGebaude: $besetzteGebaude, inderNaeheBefindlicheGebaeude: $inderNaeheBefindlicheGebaeude}';
  }
}