import 'package:alien_invasion_app/domain/benutzer.dart';

class BenutzerList {
  List<Benutzer> benutzer;

  BenutzerList({this.benutzer});

  factory BenutzerList.fromJson(List<dynamic> parsedJson) {

    List<Benutzer> benutzer = parsedJson.map((i)=>Benutzer.fromJson(i)).toList();
    return new BenutzerList(
      benutzer: benutzer,
    );
  }
}