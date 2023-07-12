import 'package:driver_ride/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';


class DrawerScreen extends StatelessWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      child: Drawer(
        child: Padding(
          padding: EdgeInsets.fromLTRB(30, 50, 0, 20),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      shape: BoxShape.circle
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 20,),
                  Text(
                    userModelCurrentInfo!.name!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),

                  SizedBox(height: 10,),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (c) => ProfileScreen()));
                    },
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  SizedBox(height: 30,),
                  Text("Your Trips", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  SizedBox(height: 15,),
                  Text("Payements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  SizedBox(height: 15,),
                  Text("Notification", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  SizedBox(height: 15,),
                  Text("Promos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  SizedBox(height: 15,),
                  Text("Help", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  SizedBox(height: 15,),
                  Text("Free Tips", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                ],
              ),

              SizedBox(height: 30,),
              GestureDetector(
                onTap: (){
                  firebaseAuth.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
                },
                child: Text("Log Out",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
