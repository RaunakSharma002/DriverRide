import 'package:driver_ride/Assistants/request_assistant.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../models/direction_details_info.dart';
import '../models/directions.dart';
import '../models/user_model.dart';

class AssistantMethods {
    static void readCurrentOnlineUserInfo() async {
      currentUser = firebaseAuth.currentUser;
      DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(currentUser!.uid);

      userRef.once().then((snap){
        if(snap.snapshot.value != null){
           userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
        }
      });
    }

    static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async{
      String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
      String humanReadableAddress = "";

      var requestResponse = await RequestAssistant.recieveRequest(apiUrl);

      if(requestResponse != "failedResponse"){
        humanReadableAddress =  requestResponse["results"][0]["formatted_address"];//fromatted_addresss

        Directions userPickupAddress = Directions();
        userPickupAddress.locationLatitude = position.latitude;
        userPickupAddress.locationLongitude = position.longitude;
        userPickupAddress.locationName = humanReadableAddress;

        Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickupAddress);
      }
      return humanReadableAddress;
    }

    static Future<DirectionDetailsInfo> obtainedOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async{
      String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
      var responseDirectionApi = await RequestAssistant.recieveRequest(urlOriginToDestinationDirectionDetails);

      // if(responseDirectionApi == "failedResponse"){
      //   return null;
      // }

      DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
      directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

      directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
      directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

      directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
      directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

      return directionDetailsInfo;
    }


    //pause the updating driverRealTimeLocation and unset the driver's location form database "activeDrive" in geofire
    static pauseLiveLocationUpdates() {
      streamSubscriptionPosition!.pause(); //pause the updating of driverRealTimeLocation
      Geofire.removeLocation(firebaseAuth.currentUser!.uid);  //unset the driver's location from database "activeDriver" in geofire
    }

}