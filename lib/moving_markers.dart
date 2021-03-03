import 'dart:async';
import 'dart:math';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:alien_invasion_app/domain/benutzer.dart';

import 'custom_popup.dart';
import 'domain/gebaeude.dart';
import 'main.dart';
import 'marker_animation.dart';

class MovingMarkersPage extends StatefulWidget {
  final MapController mapController;
  final Benutzer benutzer;
  final CallbackMethodHolder callbackMethodHolder;
  const MovingMarkersPage({Key key, this.benutzer, this.mapController, this.callbackMethodHolder}) : super(key: key);

  @override
  _MovingMarkersPageState createState() {
    return _MovingMarkersPageState(this.benutzer, this.mapController, this.callbackMethodHolder);
  }
}

class _MovingMarkersPageState extends State<MovingMarkersPage> {
  LatLng _mapcenter, _tankPos, _userPos;
  double zoom = 15.0;
  Marker _marker;
  Timer _timer;
  int _markerIndex = 0;
  final MapController mapController;
  final Benutzer benutzer;
  final CallbackMethodHolder callbackMethodHolder;
  _MovingMarkersPageState(this.benutzer, this.mapController, this.callbackMethodHolder);
  List<Marker> _markers = [];

  double doubleInRange(Random source, num start, num end) =>
      source.nextDouble() * (end - start) + start;

  Future<void> animateMarkerToGB(final Marker marker, final LatLng finalPosition) async {
    final LatLng startPosition = marker.point;
    print("start: " + startPosition.toString());
    print("target: " + finalPosition.toString());

    //float distance = startPosition.distanceTo(loc2);
    final int start = clock.now().millisecond;
    // Verlängert man durationInMs wird die Geschwindigkeit geringer
    //final double durationInMs = 6000;

    // int elapsed;
    // double t;
    // double v;
    // Je größer der Divisor, desto geringer ist die Geschwindigkeit
    var speed = 1 / 5000;
    var minDistanceToTarget = 50.0;// Die Mindestentfernung zum Ziel, die erreicht werden soll
    var startTime = clock.now();
    var dist = (Haversine().distance(startPosition, finalPosition));

    //final int timeout = 50;

    do {
      // Calculate progress using interpolator
      // elapsed =  clock.now().millisecond - start;
      //
      // if(elapsed % 1000 ==0) {
      //   print(elapsed);
      // }
      //
      // t = elapsed / durationInMs;
      // v = MarkerAnimation.getInterpolation(t);

      //LatLng newPos = MarkerAnimation.interpolate(startPosition, finalPosition, v);// Braucht man nicht so machen
      // Geht auch so

      LatLng newPos = MarkerAnimation.interpolate(startPosition, finalPosition, speed);

      double distance = Haversine().distance(startPosition, finalPosition);

      if(distance.toInt() % 50.0 == 0 || (distance.toInt() < 10 && distance.toInt() % 2 == 0)) {
        setState(() {
          marker.point.latitude = newPos.latitude;
          marker.point.longitude = newPos.longitude;
        });
      } else {
        marker.point.latitude = newPos.latitude;
        marker.point.longitude = newPos.longitude;
      }
      //}
      // ohne das geht es viel zu schnell
      await new Future.delayed(const Duration(milliseconds: 50));
      // if(distance.toInt() < 60.0) {
      //   if(distance.toInt() % 5.0 == 0) {
      //     print(distance.toString());
      //   }
      // }

    } //while((Haversine().distance(startPosition, finalPosition) > 0.001));
    while((Haversine().distance(startPosition, finalPosition) > minDistanceToTarget));

    print("Speed | Distance | Started |  Finished | Time spended") ;
    print((speed).toString() + " | " + dist.toString() + " | " + clock.now().difference(startTime).toString()) ;

    // 22:06 = 1260, 22:20 = 1200, 22:45 = 1242, 06:00 = 1084
    // 1/2500
    // Speed | Distance            | Time spended
    // 0.0004 | 1152.1985583803691 | 0:10:11.285000
    // 0.0004 | 1152.1985583803691 | 0:10:28.670000
    // 0.0004 | 1981.8480019110511 | 0:12:30.613000
    // 0.0004 | 2688.7490426404643 | 0:13:55.149000
    // 0.0004 | 2885.0045465881503 | 0:14:18.798000
    // 0.0004 | 3406.7860686175154 | 0:14:53.320000
    // 0.0004 | 4379.922939214936 | 0:15:44.164000
    // 0.0004 | 4742.294401934609 | 0:16:19.036000
    // 0.0004 | 4437.252050979897 | 0:16:20.071000
    // 1/5000
    // 0.0002 | 1152.1985583803691 | 0:23:39.469000
    // 0.0002 | 1152.1985583803691 | 0:25:08.323000
  }

  moveTank(Gebaeude destination) async {

    print('Before the Future');
    await Future(() async {
      print('Running the Future');
      // TODO check how many tanks are allready on the map, if necessary remove them
        var tank = new Marker(
          point: LatLng(_userPos.latitude, _userPos.longitude),
          width: 279.0,
          height: 256.0,
          builder: (context) => GestureDetector(
            //onTap: () {
              // setState(() {
              //   tankVisible = !tankVisible;
              // });
            //},
            child: Container(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/ic_tank.png',
                  width: 49,
                  height: 65,
                )
            ),
          ),
        );
        _markers.add(tank);
        animateMarkerToGB(tank, LatLng(destination.lat, destination.lng));

    }).then((_){
      print('Future is complete');
    });
    print('After the Future');
  }

  @override
  void initState() {
    super.initState();
    callbackMethodHolder.callback = moveTank;
    _mapcenter = LatLng(benutzer.latitude, benutzer.longitude);
    _userPos = LatLng(benutzer.latitude, benutzer.longitude);
    _tankPos = LatLng(benutzer.latitude, benutzer.longitude);

    _buildMarkersOnMap(benutzer);
    //_marker = _markers[_markerIndex];
    // _timer = Timer.periodic(Duration(seconds: 1), (_) {
    //   setState(() {
    //
    //   });
    // });
  }

  @override
  void dispose() {
    super.dispose();
    if(_timer != null) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      //drawer: buildDrawer(context, MovingMarkersPage.route),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Padding(
            //   padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            //   child: Text('This is a map that is showing (51.5, -0.9).'),
            // ),
            Flexible(

              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center: _mapcenter,
                  zoom: zoom,
                ),
                layers: [
                    new TileLayerOptions(
                        urlTemplate:
                        "https://api.mapbox.com/styles/v1/loredana/cjwhjt50d005k1dplt10c8e5r/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibG9yZWRhbmEiLCJhIjoiY2p1dXk3ZHl4MG53OTN5bWhxZjYxYzJodSJ9.TyqzGK0TjNAIDF6B5FwNyA",
                        additionalOptions: {
                          'accessToken':
                          'pk.eyJ1IjoibG9yZWRhbmEiLCJhIjoiY2p1dXk3ZHl4MG53OTN5bWhxZjYxYzJodSJ9.TyqzGK0TjNAIDF6B5FwNyA',
                          'id': 'mapbox.mapbox-streets-v8'
                        }),

                  MarkerLayerOptions(markers: _markers)
                ],

              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buildMarkersOnMap(Benutzer benutzer) {

    // Images:
    // https://github.com/rhin123/OpenCiv/tree/master/core/assets
    // https://github.com/TriDvaRas/Civilizator/tree/master/assets/Imgs
    // https://github.com/Venerons/civis/tree/master/img
    // https://github.com/tuomount/Open-Realms-of-Stars/tree/master/src/main/resources/resources/images
    // https://github.com/Trilarion/imperialism-remake/tree/master/source/imperialism_remake/data/artwork/graphics/map
    // https://github.com/stanislawbartkowski/CivilizationUI/tree/master/war/images

    var markerBenutzer = new Marker(
      point: _userPos,//LatLng(benutzer.latitude, benutzer.longitude),
      width: 279.0,
      height: 256.0,
      builder: (context) => GestureDetector(
          onTap: () {
            setState(() {
              infoWindowVisible = !infoWindowVisible;
            });
          },
          child: _buildCustomMarker()),
    );
    _markers.add(markerBenutzer);

    // var tank = new Marker(
    //   point: _tankPos,
    //   width: 279.0,
    //   height: 256.0,
    //   builder: (context) => GestureDetector(
    //     onTap: () {
    //       // setState(() {
    //       //   tankVisible = !tankVisible;
    //       // });
    //     },
    //     child: Container(
    //         alignment: Alignment.bottomCenter,
    //         child: Image.asset(
    //           'assets/images/ic_tank.png',
    //           width: 49,
    //           height: 65,
    //         )
    //     ),
    //   ),
    // );
    // _markers.add(tank);

    List<Gebaeude> inderNaehBefindlicheGebaeude = benutzer.inderNaeheBefindlicheGebaeude;
    inderNaehBefindlicheGebaeude.forEach((element) {

      var marker = new Marker(
        point: LatLng(element.lat, element.lng),
        width: 289.0,
        height: 280.0,
        builder: (context) => GestureDetector(
            onTap: () {
              setState(() {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Stack(
                          overflow: Overflow.visible,
                          children: <Widget>[
                            Positioned(
                              right: -40.0,
                              top: -40.0,
                              child: InkResponse(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: CircleAvatar(
                                  child: Icon(Icons.close),
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ),
                            Form(
                              // key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    //child: TextFormField(),
                                    child: Text(element.title),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: TextFormField(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      child: Text("Send Suppport"),
                                      onPressed: () {
                                        moveTank(element);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              });
            },
            child: Container(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/ic_' + element.typ.toLowerCase() + '.png',
                  width: 49,
                  height: 65,
                )
            )
        ),
      );

      _markers.add(marker);
    });

  }

  var infoWindowVisible = false;
  var tankVisible = false;
  GlobalKey<State> key = new GlobalKey();

  Stack _buildCustomMarker() {
    return Stack(
      children: <Widget>[popup(), marker()],
    );
  }

  Opacity popup() {
    return Opacity(
      opacity: infoWindowVisible ? 1.0 : 0.0,
      child: Container(
        alignment: Alignment.bottomCenter,
        width: 279.0,
        height: 256.0,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/ic_info_window.png"),
                fit: BoxFit.cover)),
        child:CustomPopup(key: key, benutzer: benutzer),
      ),
    );
  }

  Opacity marker() {
    return Opacity(
      child: Container(
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            'assets/images/ic_marker.png',
            width: 49,
            height: 65,
          )),
      opacity: infoWindowVisible ? 0.0 : 1.0,
    );
  }
}

// List<Marker> _markers = [
//   Marker(
//     width: 80.0,
//     height: 80.0,
//     point: LatLng(51.5, -0.09),
//     builder: (ctx) => Container(
//       child: FlutterLogo(),
//     ),
//   ),
//   Marker(
//     width: 80.0,
//     height: 80.0,
//     point: LatLng(53.3498, -6.2603),
//     builder: (ctx) => Container(
//       child: FlutterLogo(),
//     ),
//   ),
//   Marker(
//     width: 80.0,
//     height: 80.0,
//     point: LatLng(48.8566, 2.3522),
//     builder: (ctx) => Container(
//       child: FlutterLogo(),
//     ),
//   ),
// ];