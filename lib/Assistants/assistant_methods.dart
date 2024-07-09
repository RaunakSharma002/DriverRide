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
import '../models/trips_history_model.dart';
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

    static double calculateFairAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){
      double timeTravelledFairAmountPerMinute = (directionDetailsInfo.duration_value! /60) * 0.1;
      double distanceTravelledFairAmountPerKilometer = (directionDetailsInfo.distance_value! /1000) * 0.1;

      double totalFareAmount = timeTravelledFairAmountPerMinute + distanceTravelledFairAmountPerKilometer;
      double localCurrencyTotalFare = totalFareAmount * 107;

      if(driverVehicleType == "Bike"){
        double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 0.8);
        return resultFareAmount;
      }
      else if(driverVehicleType == "CNG"){
        double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 1.5);
        return resultFareAmount;
      }
      else if(driverVehicleType == "Bike"){
        double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 2);
        return resultFareAmount;
      }
      else{
        return localCurrencyTotalFare.truncate().toDouble();
      }
    }

    //retrieve the trip key from online user
    //trip key = ride request id
    static void readTripsKeysForOnlineDriver(context){
      FirebaseDatabase.instance.ref().child("All Ride Requests").orderByChild("driverId").equalTo(firebaseAuth.currentUser!.uid).once().then((snap){
        if(snap.snapshot.value != null){
          Map keysTripsId = snap.snapshot.value as Map;

          //count total number of trips and share it with Provider
          int overAllTripsCounter = keysTripsId.length;
          Provider.of<AppInfo>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);

          //Share trips key with provider
          List<String> tripsKeysList = [];
          keysTripsId.forEach((key, value) {
            tripsKeysList.add(key);
          });
          Provider.of<AppInfo>(context, listen: false).updateOverAllTripsKeys(tripsKeysList);

          //get trips keys data - read trips complete information
          readTripsHistoryInformation(context);
        }
      });
    }

    static void readTripsHistoryInformation(context){
      var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeyList;

      for(String eachKey in tripsAllKeys){
        FirebaseDatabase.instance.ref()
            .child("All Ride Requests")
            .child(eachKey)
            .once()
            .then((snap)
        {
          var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

          if((snap.snapshot.value as Map)["status"] == "ended"){
            //update or add each history to overAllTrips History data list
            Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
          }
        });
      }
    }

    //read Driver Earning
    static void readDriverEarnings(context){
      FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap){
        if(snap.snapshot.value != null){
         String driverEarnings = snap.snapshot.value.toString();
         Provider.of<AppInfo>(context, listen: false).updateDriverTotalEarnings(driverEarnings);

          readTripsKeysForOnlineDriver(context);
        }
      });
    }

    static void readDriverRatings(context){
      FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("ratings").once().then((snap){
        if(snap.snapshot.value != null){
          String driverRatings = snap.snapshot.value.toString();
          Provider.of<AppInfo>(context, listen: false).updateDriverAverageRating(driverRatings);
        }
      });
    }

}