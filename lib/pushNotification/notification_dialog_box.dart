import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver_ride/Assistants/assistant_methods.dart';
import 'package:driver_ride/global/global.dart';
import 'package:driver_ride/models/user_ride_request_information.dart';
import 'package:driver_ride/screens/new_trip_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NotificationDialogBox({this.userRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        margin: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: darkTheme ? Colors.black : Colors.white
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              onlineDriverData.car_type == "Car" ? "images/Car1.png"
                  :onlineDriverData.car_type == "CNG" ? "images/CNG.png"
                  :"images/Bike.png",
            ),

            SizedBox(height: 10,),
            Text( //title
              "New Ride Request",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.amber[400] : Colors.blue
              ),
            ),

            SizedBox(height: 14,),
            Divider(
              height: 2,
              thickness: 2,
              color: darkTheme ? Colors.amber[400] : Colors.blue,
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset("images/origin.png",
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
                              color: darkTheme ? Colors.amber[400] : Colors.blue
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Image.asset("images/destination.png",
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
                                color: darkTheme ? Colors.amber[400] : Colors.blue
                            ),
                          ),
                        ),
                      )
                    ],
                  )

                ],
              ),
            ),

            Divider(
              height: 2,
              thickness: 2,
                color: darkTheme ? Colors.amber[400] : Colors.blue
            ),

            //button for cancelling and accepting the ride request
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: (){
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer = AssetsAudioPlayer();

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red
                      ),
                      child: Text(
                        "Cancel".toUpperCase(),
                        style: TextStyle(fontSize: 15),
                      )
                  ),

                  SizedBox(width: 20,),
                  ElevatedButton(
                      onPressed: (){
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer = AssetsAudioPlayer();

                        acceptRideRequest(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green
                      ),
                      child: Text(
                        "Accept".toUpperCase(),
                        style: TextStyle(fontSize: 15),
                      )
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


  //go database of drivers -> newRidStatus  and make "idle" to "accepted" and remove driver from geoFire database "activeDriver"
  acceptRideRequest(BuildContext context){
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap)
    {
        if(snap.snapshot.value == "idle"){
          FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("newRideStatus").set("accepted");

          AssistantMethods.pauseLiveLocationUpdates();

          //trip started now: send driver to new tripScreen
          Navigator.push(context, MaterialPageRoute(builder: (c) => NewTripScreen(
              userRideRequestDetails: widget.userRideRequestDetails,
          )));
        }
        else{
          Fluttertoast.showToast(msg: "The ride request does not exists.");
        }
    });
  }


}




