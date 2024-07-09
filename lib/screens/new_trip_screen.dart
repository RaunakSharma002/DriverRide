import 'dart:async';

import 'package:driver_ride/Assistants/assistant_methods.dart';
import 'package:driver_ride/global/global.dart';
import 'package:driver_ride/models/user_ride_request_information.dart';
import 'package:driver_ride/splashScreen/splash_screen.dart';
import 'package:driver_ride/widgets/fare_amount_collection_dialog.dart';
import 'package:driver_ride/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;
  NewTripScreen({this.userRideRequestDetails});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;

  //Step1. When driver accept the user ride request
  //          originLatLng = driverCurrent location
  //          destinationLatLng = user pickup location
  //Step2. When driver pickup the user in his car
  //          originLatLng = user current location which will be also the current location of driver at the time
  //          destinationLatLng = user's drop off location
  Future<void> drawPolyLineFromOriginToDestination(LatLng originLatLng, LatLng destinationLatLng, bool darkTheme) async{
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Please wait...")
    );

    var directionDetailsInfo = await AssistantMethods.obtainedOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    polyLinePositionCoordinates.clear();
    if(decodedPolyLinePointsResultList.isNotEmpty){
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        polyLinePositionCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amber.shade400 : Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType:  JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5
      );
      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }else if(originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude)
      );
    }else if(originLatLng.latitude > destinationLatLng.latitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude)
      );
    }else{
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }
    newTripGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng
    );
    Circle destinationCircle = Circle(
        circleId: CircleId("destinationID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: destinationLatLng
    );
    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });

  }

  @override
  void initState() {
    super.initState();

    saveAssignedDriverDetailsToUserRideRequest();
  }

  //listen GeoLocator and store in global streamSubscriptionPosition and update the global driverCurrentPosition & onlineDriverCurrentPosition
  //update the Marker also
  //update the driverLocation in database "All Ride Requests". rideRequestId. "driverLocation"
  //call function  updateDurationTimeAtRealTime() for
  getDriverLocationAtRealTime(){
    LatLng oldLatLng = LatLng(0, 0);

    streamSubscriptionPosition = Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);

      Marker animatingMarker = Marker(
        markerId: MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: InfoWindow(title: "This is your position"),
      );
      setState(() {
        CameraPosition cameraPosition = CameraPosition(target: latLngLiveDriverPosition, zoom: 18);
        newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        
        setOfMarkers.removeWhere((element) => element.markerId.value == "AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();

      //updating driver location at realTime in database
      Map driverLatLngDataMap = {
        "latitude": onlineDriverCurrentPosition!.latitude.toString(),
        "longitude": onlineDriverCurrentPosition!.longitude.toString()
      };
      FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("driverLocation").set(driverLatLngDataMap);

    });
  }


  //if rideRequestStatus == "accepted" the destination location is user's pickup location; otherwise destination location is userDropOff address
  //find duration text using Assistant.obtainedOriginToDestinationDirectionDetails() and update into local durationFromOriginToDestinatio
  updateDurationTimeAtRealTime() async{
    if(isRequestDirectionDetails == false){
      isRequestDirectionDetails = true;

      if(onlineDriverCurrentPosition == null){
        return;
      }

      var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);

      var destinationLatLng;
      if(rideRequestStatus == "accepted"){
        destinationLatLng = widget.userRideRequestDetails!.originLatLng!;   //user's pickup location
      }else{
        destinationLatLng = widget.userRideRequestDetails!.destinationLatLng!;
      }

      var directionInformation = await AssistantMethods.obtainedOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
      if(directionInformation != null){
        setState(() {
          durationFromOriginToDestination = directionInformation.duration_text!;
        });
      }
      isRequestDirectionDetails = false;

    }
  }

  createDriverIconMarker(){
    if(iconAnimatedMarker == null){
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png").then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  //driverCurrentPosition is assigned in locateCurrentPosition() in home_tab.dart which use GeoLocator
  //creating value of DataBase "All Ride Requests" which will be use in UserApp
  //onlineDriverData object is created in func readCurrentDriverInformation() in home.dart which fetch data from database "drivers".uid
  saveAssignedDriverDetailsToUserRideRequest(){
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!);

    Map driverLocationDataMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString()
    };
    
    if(databaseReference.child("driverId") != "waiting"){
      databaseReference.child("driverLocation").set(driverLocationDataMap);
      
      databaseReference.child("status").set("accepted");
      databaseReference.child("driverId").set(onlineDriverData.id);
      databaseReference.child("driverName").set(onlineDriverData.name);
      databaseReference.child("driverPhone").set(onlineDriverData.phone);
      databaseReference.child("ratings").set(onlineDriverData.ratings);
      databaseReference.child("car_details").set(onlineDriverData.car_model.toString() + " " + onlineDriverData.car_number.toString() + " (" + onlineDriverData.car_color.toString() + ")");

      saveRideRequestIdToDriverHistory();
    }else{
      Fluttertoast.showToast(msg: "This ride request is already accepted by antoher driver. \n Reloading the App");
      Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
    }
  }

  //make a database "tripHistory" in "drivers" and set rideRequestId = true
  saveRideRequestIdToDriverHistory(){
    DatabaseReference tripHistoryRef = FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("tripHistory");
    tripHistoryRef.child(widget.userRideRequestDetails!.rideRequestId!).set(true);
  }


  //calculate the total fare amount with help of  AssistantMethods.obtainedOriginToDestinationDirectionDetails()
  //make a database of Name "fareAmount" in "All Ride Request" and set fare in userId; and "status" to ended
  
  endTripNow() async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(message: "Please wait...",)
    );

    //get the trip direction details = distance travelled
    var currentDriverPositionLatLng = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
    var tripDirectionDetails = await AssistantMethods.obtainedOriginToDestinationDirectionDetails(currentDriverPositionLatLng, widget.userRideRequestDetails!.originLatLng!);

    //fare amount
    double totalFareAmount = AssistantMethods.calculateFairAmountFromOriginToDestination(tripDirectionDetails);
    FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("fareAmount").set(totalFareAmount.toString());
    FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set("ended");
    Navigator.pop(context);

    //display fare amount in dialog box
    showDialog(
        context: context,
        builder: (BuildContext context) => FareAmountCollectionDialog(totalFareAmount: totalFareAmount,)
    );

    //save fare amount to driver total earning
    saveFareAmountToDriverEarning(totalFareAmount);
  }


  //go into database "drivers.earnings" if amount already exist then add current amount  in that set it
  //otherwise set "drivers.earnings" to current amount with help of .once()
  saveFareAmountToDriverEarning(totalFareAmount){
    FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap){
      if(snap.snapshot.value != null){
        double oldEarning = double.parse(snap.snapshot.value.toString());
        double driverTotalEarnings = totalFareAmount + oldEarning;
        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(driverTotalEarnings.toString());
      }
      else{
        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(totalFareAmount);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    createDriverIconMarker();
    return Scaffold(
      body: Stack(
        children: [
          //Google Map
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

              setState(() {
                mapPadding = 350;
              });

              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
              var userPickLatLng = widget.userRideRequestDetails!.originLatLng;

              drawPolyLineFromOriginToDestination(driverCurrentLatLng, userPickLatLng!, darkTheme);
              getDriverLocationAtRealTime();
            },
          ),

          //UI
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 18,
                      spreadRadius: 0.5,
                      offset: Offset(0.6, 0.6)
                    )
                  ]
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      //showing the duration
                      Text(
                        durationFromOriginToDestination,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkTheme ? Colors.amber.shade400 : Colors.black,
                        ),
                      ),

                      SizedBox(height: 10,),
                      Divider(thickness: 1, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),

                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.userRideRequestDetails!.userName!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: darkTheme ? Colors.amber.shade400 : Colors.black,
                            ),
                          ),
                          
                          IconButton(
                              onPressed: (){},
                              icon: Icon(
                                Icons.phone,
                                color: darkTheme ? Colors.amber.shade400 : Colors.black,
                              )
                          )
                        ],
                      ),

                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Image.asset(
                            "images/origin.png",
                            width: 30,
                            height: 30,
                          ),

                          SizedBox(width: 10,),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.userRideRequestDetails!.originAddress!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: darkTheme ? Colors.amberAccent : Colors.black,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Image.asset(
                            "images/destination.png",
                            width: 30,
                            height: 30,
                          ),

                          SizedBox(width: 10,),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.userRideRequestDetails!.destinationAddress!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: darkTheme ? Colors.amberAccent : Colors.black,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 10,),
                      Divider(thickness: 1, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),

                      SizedBox(height: 10,),
                      ElevatedButton.icon(
                          onPressed: () async{
                            //[driver has arrived pickup location] - Arrived Button
                            if(rideRequestStatus == "accepted"){
                              rideRequestStatus = "arrived";
                              FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set(rideRequestStatus);
                              setState(() {
                                buttonTitle = "Let's Go";
                                buttonColor = Colors.lightGreen;
                              });
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) => ProgressDialog(message: "Loading...",)
                              );

                              await drawPolyLineFromOriginToDestination(
                                  widget.userRideRequestDetails!.originLatLng!,
                                  widget.userRideRequestDetails!.destinationLatLng!,
                                  darkTheme
                              );
                              Navigator.pop(context);
                            }
                            //[user has picked from user's pickup location] -Let's go button
                            else if(rideRequestStatus == "arrived"){
                              rideRequestStatus = "ontrip";
                              FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set(rideRequestStatus);
                              setState(() {
                                buttonTitle = "End Trip";
                                buttonColor = Colors.red;
                              });
                            }
                            //[user/driver has reached dropOff location] - End Trip Button
                            else if(rideRequestStatus == "ontrip"){
                              endTripNow();
                            }
                          },
                          icon: Icon(Icons.directions_car, color: darkTheme ? Colors.black : Colors.white, size: 25,),
                          label: Text(
                            buttonTitle!,
                            style: TextStyle(
                              color: darkTheme ? Colors.black : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                            ),
                          )
                      )

                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
