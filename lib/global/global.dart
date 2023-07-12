import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver_ride/models/driver_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

StreamSubscription<Position>? streamSubscriptionPosition;//for real time driver location with help of Geolocator
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

AssetsAudioPlayer audioPlayer = AssetsAudioPlayer(); //for play notification music

UserModel? userModelCurrentInfo;

Position? driverCurrentPosition;

DriverData onlineDriverData = DriverData();
String? driverVehicleType = "";