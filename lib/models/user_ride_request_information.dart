import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformation{
  LatLng? originLatLng;
  LatLng? destinationLatLng;
  String? originAddress;
  String? destinationAddress;
  String? rideRequestId;
  String? userName;
  String? userPhone;

  UserRideRequestInformation({this.originLatLng, this.destinationAddress, this.originAddress, this.destinationLatLng, this.rideRequestId, this.userName, this.userPhone});
}