
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver_ride/global/global.dart';
import 'package:driver_ride/models/user_ride_request_information.dart';
import 'package:driver_ride/pushNotification/notification_dialog_box.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //when app is closed use "FirebaseMessaging.instance.getInitialMessage()", when already opened then use "onMessage", when in background then use "onMessageOpenedApp"
  //listen RemoteMessage of rideRequestId with help of readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context)
  Future initializeCloudMessaging(BuildContext context) async {

    //1. Terminated
    //when app is closed and open directly from push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage) {
      if(remoteMessage != null){
        readUserRideRequestInformation(remoteMessage.data["rideRequestId"], context); //rideRequestId is coming from userApp from AssistantMethod.pushNotification
      }
    });

    //2. Foreground
    //When the app is open and receive the push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
    });

    //3. BackGround
    //when the app is in the background and open directly from push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);
    });

  }


  //userRideRequestId come from "All Ride Requests" database save in User app when user Book a ride then driverId=waiting
  //when driverId==waiting or match with currentUser id (driver) then play notification with help of audioPlayer package
  //make model (class) of userRideRequestInformation and make an object userRideRequestDetails from it
  //fetch all data from database "All Ride Requests" and store into object userRideRequestDetails
  //then show notificationDialogBox
  //push object userRideRequestDetails into NotificationDialogBox so that it can extract information through it
  readUserRideRequestInformation(String userRideRequestId, BuildContext context){
    FirebaseDatabase.instance.ref().child("All Ride Requests").child(userRideRequestId).child("driverId").onValue.listen((event) {
      if(event.snapshot.value == "waiting" || event.snapshot.value == firebaseAuth.currentUser!.uid){
        FirebaseDatabase.instance.ref().child("All Ride Requests").child(userRideRequestId).once().then((snapData){
          if(snapData.snapshot.value != null){

            audioPlayer.open(Audio("music/music_notification.mp3"));
            audioPlayer.play();

            double originLat = double.parse((snapData.snapshot.value! as Map)["origin"]["latitude"]);
            double originLng = double.parse((snapData.snapshot.value! as Map)["origin"]["longitude"]);
            String originAddress = (snapData.snapshot.value! as Map)["originAddress"];

            double destinationLat = double.parse((snapData.snapshot.value! as Map)["destination"]["latitude"]);
            double destinationLng = double.parse((snapData.snapshot.value! as Map)["destination"]["longitude"]);
            String destinationAddress = (snapData.snapshot.value! as Map)["destinationAddress"];

            String userName = (snapData.snapshot.value! as Map)["userName"];
            String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

            String? rideRequestId = snapData.snapshot.key;

            UserRideRequestInformation userRideRequestDetails = UserRideRequestInformation();
            userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
            userRideRequestDetails.originAddress = originAddress;
            userRideRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
            userRideRequestDetails.destinationAddress = destinationAddress;
            userRideRequestDetails.userName = userName;
            userRideRequestDetails.userPhone = userPhone;

            userRideRequestDetails.rideRequestId = rideRequestId;

            showDialog(
                context: context,
                builder: (BuildContext context) => NotificationDialogBox(userRideRequestDetails: userRideRequestDetails,)
            );
          }else{
            Fluttertoast.showToast(msg: "This Ride Request Id do not exists.");
          }
        });
      }
      else{
        Fluttertoast.showToast(msg: "This Ride Request has been cancled");
        Navigator.pop(context);
      }
    });
  }

  //Firebase generate token for each device, and device can get it through FirebaseMessaging.instance().getToken()
  //go to database drivers -> token and set token to registrationToken
  //make a topic of "allDrivers" and "allUsers" in FCM for subscribing
  Future generateAndGetToken() async {
    String? registrationToken = await messaging.getToken();
    print("FCM registration token: ${registrationToken}");

    FirebaseDatabase.instance.ref()
      .child("drivers")
      .child(firebaseAuth.currentUser!.uid)
      .child("token")
      .set(registrationToken);

    messaging.subscribeToTopic("allDrivers"); //subscribe the topic which all user can call and listen
    messaging.subscribeToTopic("allUsers"); //if not already exists then it create automatically by this
  }
}

