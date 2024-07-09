import 'package:driver_ride/global/global.dart';
import 'package:driver_ride/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();

  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");

  Future<void> showDriverNameDialogAlert(BuildContext context, String name){
    nameTextEditingController.text = name;
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: TextStyle(color: Colors.red),),
              ),

              TextButton(
                onPressed: (){
                  userRef.child(firebaseAuth.currentUser!.uid).update({
                    "name": nameTextEditingController.text.trim(),
                  }).then((value){
                    nameTextEditingController.clear();
                    Fluttertoast.showToast(msg: "Updated succesfully. \n Reload app to see the changes");
                  }).catchError((errorMessage){
                    Fluttertoast.showToast(msg: "Error occured. \n $errorMessage");
                  });
                  Navigator.pop(context);
                },
                child: Text("OK", style: TextStyle(color: Colors.black),),
              ),

            ],
          );
        }
    );
  }

  Future<void> showDriverPhoneDialogAlert(BuildContext context, String phone){
    phoneTextEditingController.text = phone;
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: phoneTextEditingController,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: TextStyle(color: Colors.red),),
              ),

              TextButton(
                onPressed: (){
                  userRef.child(firebaseAuth.currentUser!.uid).update({
                    "name": phoneTextEditingController.text.trim(),
                  }).then((value){
                    phoneTextEditingController.clear();
                    Fluttertoast.showToast(msg: "Updated succesfully. \n Reload app to see the changes");
                  }).catchError((errorMessage){
                    Fluttertoast.showToast(msg: "Error occured. \n $errorMessage");
                  });
                  Navigator.pop(context);
                },
                child: Text("OK", style: TextStyle(color: Colors.black),),
              ),

            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false, //size keyboard according to scaffold
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: darkTheme ? Colors.amber[400] : Colors.black,
            ),
          ),
          title: Text("Profile Screen", style: TextStyle(color: darkTheme ? Colors.amber.shade400 : Colors.black, fontWeight: FontWeight.bold),),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        color: darkTheme ? Colors.amber.shade400 : Colors.lightBlue,
                        shape: BoxShape.circle
                      ),
                      child: Icon(Icons.person, color: darkTheme ? Colors.black : Colors.white,),
                    ),

                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${onlineDriverData.name}",
                          style: TextStyle(
                            color: darkTheme ? Colors.amber[400] : Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        ),

                        IconButton(
                          onPressed: (){
                            showDriverNameDialogAlert(context, onlineDriverData.name!);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: darkTheme ? Colors.amber[400] : Colors.blue,
                          ),
                        )
                      ],
                    ),

                    Divider(thickness: 1,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${onlineDriverData.phone!}",
                          style: TextStyle(
                              color: darkTheme ? Colors.amber[400] : Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                        IconButton(
                          onPressed: (){
                            showDriverNameDialogAlert(context, onlineDriverData.phone!);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: darkTheme ? Colors.amber[400] : Colors.blue,
                          ),
                        )
                      ],
                    ),

                    Divider(thickness: 1,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${onlineDriverData.address}",
                          style: TextStyle(
                              color: darkTheme ? Colors.amber[400] : Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                        IconButton(
                          onPressed: (){
                            showDriverNameDialogAlert(context, onlineDriverData.address!);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: darkTheme ? Colors.amber[400] : Colors.blue,
                          ),
                        )
                      ],
                    ),

                    Divider(thickness: 1,),
                    Text("${userModelCurrentInfo!.email}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Divider(thickness: 1,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${onlineDriverData.car_model!} \n ${onlineDriverData.car_color} \n (${onlineDriverData.car_number})",
                          style: TextStyle(
                              color: darkTheme ? Colors.amber[400] : Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        ),

                        Image.asset(
                          onlineDriverData.car_type == "Car" ? "images/Car.png"
                              : onlineDriverData.car_type == "CNG" ? "images/CNG.png"
                              : "images/Bike.png",
                          scale: 2,
                        ),
                      ],
                    ),

                    SizedBox(height: 20,),
                    ElevatedButton(
                        onPressed: (){
                          firebaseAuth.signOut();
                          Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent
                        ),
                        child: Text("Log Out")
                    )

                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
