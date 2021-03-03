import 'package:flutter/material.dart';
import 'package:alien_invasion_app/moving_markers.dart';
import 'package:latlong/latlong.dart';
import 'components/sopported_buildings.dart';
import 'components/unsopported_buildings.dart';
import 'package:flutter_map/flutter_map.dart';

import 'domain/benutzer.dart';
import 'main.dart';

final Color backgroundColor = Color(0xFF4A4A58);

class MenuDashboardPage extends StatefulWidget {
  final MapController mapController;
  final Benutzer benutzer;
  MenuDashboardPage(this.benutzer, this.mapController, );

  @override
  _MenuDashboardPageState createState() => _MenuDashboardPageState(this.benutzer, this.mapController);
}

class _MenuDashboardPageState extends State<MenuDashboardPage> with SingleTickerProviderStateMixin {
  bool isCollapsed = true;
  double screenWidth, screenHeight;
  final MapController mapController;
  final CallbackMethodHolder callbackMethodHolder = CallbackMethodHolder();
  //final Function moveTank;
  final Benutzer benutzer;

  _MenuDashboardPageState(this.benutzer, this.mapController);
  LatLng _mapcenter, _tankPos, _userPos;
  double zoom = 15.0;
  final Duration duration = const Duration(milliseconds: 300);
  AnimationController _controller;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: <Widget>[
          //menu(context),
          MovingMarkersPage(benutzer:benutzer,  mapController: mapController, callbackMethodHolder: callbackMethodHolder),
          dashboard(context),
        ],
      ),
    );
  }

  Widget dashboard(context) {
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      // Hier wird die eingeklappte Breit des Menüs gesetzt
      left: isCollapsed ? 0 : 0.7 * screenWidth,
      right: isCollapsed ? 0 : -0.2 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          animationDuration: duration,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          elevation: 8,
          color: backgroundColor,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        child: Icon(Icons.menu, color: Colors.white),
                        onTap: () {
                          setState(() {
                            if (isCollapsed)
                              _controller.forward();
                            else
                              _controller.reverse();

                            isCollapsed = !isCollapsed;
                          });
                        },
                      ),
                      Text("Übersicht", style: TextStyle(fontSize: 18, color: Colors.white)),
                      Icon(Icons.settings, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 50),
                  /*Container(
                    height: 200,
                    child: PageView(
                      controller: PageController(viewportFraction: 0.8),
                      scrollDirection: Axis.horizontal,
                      pageSnapping: true,
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.redAccent,
                          width: 100,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.blueAccent,
                          width: 100,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.greenAccent,
                          width: 100,
                        ),
                      ],
                    ),
                  ),*/
                  Text("Besetzte Gebäude", style: TextStyle(color: Colors.white, fontSize: 20),),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SupportedBuildings(benutzer: benutzer, mapController: mapController, zoom: zoom)
                      ]
                  ),
                  SizedBox(height: 20),
                  Text("Zu unterstüzende Gebäude in der Nähe", style: TextStyle(color: Colors.white, fontSize: 20),),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        UnsupportedBuildings(benutzer: benutzer, mapController: mapController, zoom: zoom, tankCallback: callbackMethodHolder)
                      ]
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        // style: ElevatedButton.styleFrom(
                        //   //primary: Colors.purple,
                        //   padding: EdgeInsets.all(15.0),
                        //
                        // ),
                        child: Text("Home"),
                        onPressed: () {

                          setState(() {
                            print("Go Home from here");
                            _mapcenter = LatLng(benutzer.latitude, benutzer.longitude);

                            mapController.move(_mapcenter, zoom);
                          });

                        },
                      ),
                      SizedBox(width: 5),
                      ElevatedButton(
                        child: Text("Help"),
                        onPressed: () {
                          print("TODO");
                        },
                      )
                      // Container(
                      //   margin: const EdgeInsets.symmetric(horizontal: 8),
                      //   color: Colors.redAccent,
                      //   width: 40,
                      // ),
                      // Container(
                      //   margin: const EdgeInsets.symmetric(horizontal: 8),
                      //   color: Colors.blueAccent,
                      //   width: 40,
                      // ),
                      // Container(
                      //   margin: const EdgeInsets.symmetric(horizontal: 8),
                      //   color: Colors.greenAccent,
                      //   width: 40,
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<Marker> _markers = [
  Marker(
    width: 80.0,
    height: 80.0,
    point: LatLng(51.5, -0.09),
    builder: (ctx) => Container(
      child: FlutterLogo(),
    ),
  ),
  Marker(
    width: 80.0,
    height: 80.0,
    point: LatLng(53.3498, -6.2603),
    builder: (ctx) => Container(
      child: FlutterLogo(),
    ),
  ),
  Marker(
    width: 80.0,
    height: 80.0,
    point: LatLng(48.8566, 2.3522),
    builder: (ctx) => Container(
      child: FlutterLogo(),
    ),
  ),
];