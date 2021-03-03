import 'gebaeude.dart';

class GebaeudeList {
  List<Gebaeude> gebaeude;

  GebaeudeList({this.gebaeude});

  factory GebaeudeList.fromJson(List<dynamic> parsedJson) {

    List<Gebaeude> gebaeude = parsedJson.map((i)=>Gebaeude.fromJson(i)).toList();
    return new GebaeudeList(
      gebaeude: gebaeude,
    );
  }
}