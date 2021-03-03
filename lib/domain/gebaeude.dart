import 'package:alien_invasion_app/domain/benutzer.dart';

import 'benutzer_list.dart';

class Position {
  double lat;
  double lng;

  Position({this.lat, this.lng});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}

class Gebaeude {
  int id;
  String title;
  String typ;
  double lat;
  double lng;
  //List<Benutzer> benutzer;

  Gebaeude({this.id, this.title, this.typ, this.lat, this.lng});

  factory Gebaeude.fromJson(Map<String, dynamic> json) {
    Position position = Position.fromJson(json['position']);

    return Gebaeude(
        id: json['id'],
        title: json['title'],
        typ: json['gebaeudeTyp'],
        lat: position.lat,
        lng: position.lng,
        //benutzer: BenutzerList.fromJson(json['longitude']).benutzer,
    );
  }

  @override
  String toString() {
    return 'Gebaeude{id: $id, title: $title, typ: $typ, lat: $lat, lng: $lng}';
  }
}