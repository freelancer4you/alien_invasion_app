import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alien_invasion_app/domain/benutzer.dart';
import 'package:alien_invasion_app/domain/gebaeude.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class SupportedBuildings extends StatelessWidget{

  final Benutzer benutzer;
  final MapController mapController;
  final double zoom;
  const SupportedBuildings({Key key, this.benutzer, this.mapController, this.zoom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        child:
        SingleChildScrollView(
            child:DataTable(
              // border: TableBorder(horizontalInside: BorderSide(width: 1, color: Colors.blue, style: BorderStyle.solid),
              dataRowHeight: 40,
              showCheckboxColumn:false,
              columns: [
                DataColumn(label: Text('Name', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Typ', style: TextStyle(color: Colors.white))),
                DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white)))
              ],
              rows: fillRows(benutzer.besetzteGebaude),
            )
        )
    );
  }

  List<DataRow> fillRows(List<Gebaeude> inderNaeheBefindlicheGebaeude) {
    List<DataRow> _rowList = [];
    inderNaeheBefindlicheGebaeude.forEach((geb) {
      _rowList.insert(0, DataRow(
        // color: MaterialStateProperty.resolveWith<
        //     Color>(
        //         (Set<MaterialState> states) {
        //       return alert.type ==
        //           NewsFeedType.SIGNAL
        //           ? Colors.red
        //           : Colors.transparent;
        //     }),
          cells: <DataCell>[
            DataCell(Text(geb.title, style: TextStyle(color: Colors.white))),
            DataCell(Text(geb.typ, style: TextStyle(color: Colors.white))),
            DataCell(
                ElevatedButton(
                  child: Text("Go to"),
                  onPressed: () {
                    mapController.move(LatLng(geb.lat, geb.lng), zoom);
                  },
                )
            )
          ]));
    });
    return _rowList;
  }
}