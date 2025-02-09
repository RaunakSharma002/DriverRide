import 'dart:async';

import 'package:driver_ride/global/global.dart';
import 'package:driver_ride/pushNotification/push_notification_system.dart';
import 'package:driver_ride/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Assistants/assistant_methods.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);
  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;

  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  checkIfLocationPermissionAllowed() async{
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied){
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateDriverPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(driverCurrentPosition!, context);

    AssistantMethods.readDriverRatings(context);
  }

  readCurrentDriverInformation() async{
    currentUser = firebaseAuth.currentUser;

    FirebaseDatabase.instance.ref()
      .child("drivers")
      .child(currentUser!.uid)
      .once()
      .then((snap)
    {
        if(snap.snapshot.value != null){
          onlineDriverData.id = (snap.snapshot.value as Map)["id"];
          onlineDriverData.name = (snap.snapshot.value as Map)["name"];
          onlineDriverData.phone = (snap.snapshot.value as Map)["phone"];
          onlineDriverData.email = (snap.snapshot.value as Map)["email"];
          onlineDriverData.address = (snap.snapshot.value as Map)["address"];
          onlineDriverData.ratings = (snap.snapshot.value as Map)["ratings"];
          onlineDriverData.car_model = (snap.snapshot.value as Map)["car_details"]["car_model"];
          onlineDriverData.car_number = (snap.snapshot.value as Map)["car_details"]["car_number"];
          onlineDriverData.car_color = (snap.snapshot.value as Map)["car_details"]["car_color"];
          onlineDriverData.car_type = (snap.snapshot.value as Map)["car_details"]["type"];

          driverVehicleType = (snap.snapshot.value as Map)["car_details"]["type"];
        }
    });

    AssistantMethods.readDriverEarnings(context);
  }

  //read driver's information through database driver->uid and store in object onlineDriverData with help of readCurrentDriverInformation()
  //request for location Permission with help of Geolocator.requestPermission() in function checkIfLocationPermissionAllowed();
  //make pushNotificationSystem with class PushNotificationSystem and call it function initializeCloudMessaging & generateAndGetToken
  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: 40),
          mapType: MapType.normal,
          // myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller){
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            locateDriverPosition();
          },
        ),

        //ui for online/offline driver
        statusText != "Now Online"
          ? Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            color: Colors.black87,
          )
            :Container(),

        //button for online/offline driver
        Positioned(
          top: statusText != "Now Online" ? MediaQuery.of(context).size.height*0.45 : 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (){
                  if(isDriverActive != true){//making driver online
                    driverIsOnlineNow();
                    updateDriverLocationAtRealTime();

                    setState(() {
                      statusText = "Now Online";
                      isDriverActive = true;
                      buttonColor = Colors.transparent;
                    });
                  }
                  else{
                    driverIsOfflineNow();
                    setState(() {
                      statusText = "Now Offline";
                      isDriverActive = false;
                      buttonColor = Colors.grey;
                    });
                    Fluttertoast.showToast(msg: "You are offline now");
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: buttonColor,
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  )
                ),
                child: statusText != "Now Online" ? Text(statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ) : Icon(
                  Icons.phonelink_ring,
                  color: Colors.white,
                  size: 26,
                ),
              )
            ],
          ),
        ),


        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (){
                    firebaseAuth.signOut();
                    Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
                },
                style: ElevatedButton.styleFrom(
                    primary: buttonColor,
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    )
                ),
                child: Text("Sign Out")
              )
            ],
          ),
        ),



      ],
    );
  }


  //Function
  driverIsOnlineNow() async{
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy:  LocationAccuracy.high);
    driverCurrentPosition = pos;

    //Geofire use firebase as dataStorage to store location
    Geofire.initialize("activeDrivers"); //make rule in realtimeDatabase
    Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    //making newRideStatus in database and put value to "idle"
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("newRideStatus");
    ref.set("idle");
    ref.onValue.listen((event) { });

  }

  updateDriverLocationAtRealTime(){
    streamSubscriptionPosition = Geolocator.getPositionStream().listen((Position position) {
      if(isDriverActive == true){
        Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      }

      LatLng latLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverIsOfflineNow(){
    Geofire.removeLocation(currentUser!.uid);

    //deleting the newRideStatus database
    DatabaseReference? ref = FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(Duration(milliseconds: 2000), (){
      //removing top most instance instance before it(to exist app)
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });
  }

}
