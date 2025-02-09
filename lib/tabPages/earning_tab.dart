import 'package:driver_ride/global/global.dart';
import 'package:driver_ride/infoHandler/app_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/trips_history_screen.dart';

class EarningTabPage extends StatefulWidget {
  const EarningTabPage({Key? key}) : super(key: key);

  @override
  State<EarningTabPage> createState() => _EarningTabPageState();
}

class _EarningTabPageState extends State<EarningTabPage> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      color: darkTheme ? Colors.amberAccent : Colors.lightBlueAccent,
      child: Column(
        children: [
          //earnings
          Container(
            color: darkTheme ? Colors.black : Colors.lightBlue,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  Text(
                    "Your Earnings",
                    style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : Colors.white,
                      fontSize: 16
                    ),
                  ),

                  const SizedBox(height: 10,),
                  Text(
                    "\₹" + Provider.of<AppInfo>(context, listen: false).driverTotalEarning,
                    style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ),
          ),

          //Total no. of trips
          ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (c)=> TripsHistoryScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white54
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Image.asset(
                      onlineDriverData.car_type == "Car" ? "images/Car1.png"
                          : onlineDriverData.car_type == "CNG" ? "images/CNG.png"
                          : "images/Bike.png",
                      scale: 2,
                    ),

                    SizedBox(width: 10,),
                    Text(
                      "Trips Completed",
                      style: TextStyle(
                        color:  Colors.black54
                      ),
                    ),
                    
                    Expanded(
                      child: Container(
                        child: Text(
                          Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length.toString(),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
          )
        ],
      ),
    );
  }
}
