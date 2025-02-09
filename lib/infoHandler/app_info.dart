import 'package:flutter/cupertino.dart';

import '../models/directions.dart';
import '../models/trips_history_model.dart';


class AppInfo extends ChangeNotifier{
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;
  String driverTotalEarning = "0";
  String driverAverageRatings = "0";
  List<String> historyTripsKeyList = [];
  List<TripsHistoryModel> allTripsHistoryInformationList = [];

 void updatePickUpLocationAddress(Directions userPickUpAddress){
   userPickUpLocation = userPickUpAddress;
   notifyListeners();
 }
  void updateDropOffLocationAddress(Directions dropOffAddress){
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  updateOverAllTripsCounter(int overAllTripsCounter){
    countTotalTrips = overAllTripsCounter;
    notifyListeners();
  }

  updateOverAllTripsKeys(List<String> tripKeysList){
    historyTripsKeyList = tripKeysList;
    notifyListeners();
  }

  updateOverAllTripsHistoryInformation(TripsHistoryModel eachTripHistory){
    allTripsHistoryInformationList.add(eachTripHistory);
    notifyListeners();
  }

  updateDriverTotalEarnings(String driverEarnings){
   driverTotalEarning = driverEarnings;
  }

  updateDriverAverageRating(String driverRatings){
   driverAverageRatings = driverRatings;
  }

}