import 'package:driver_ride/global/global.dart';
import 'package:driver_ride/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({Key? key}) : super(key: key);

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  final carModelTextEditingController = TextEditingController();
  final carNumeberTextEditingController = TextEditingController();
  final carColorTextEditingController = TextEditingController();

  List<String> carTypes = ["Car", "CNG", "Bike"];
  String? selectedCarType;

  final _formKey = GlobalKey<FormState>();

  _submit(){
    if(_formKey.currentState!.validate()){
      Map driverCarInfoMap = {
        "car_model": carModelTextEditingController.text.trim(),
        "car_number": carNumeberTextEditingController.text.trim(),
        "car_color": carColorTextEditingController.text.trim(),
        // "type": selectedCarType!.trim(),    //added by me remove after
      };

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");
      userRef.child(firebaseAuth.currentUser!.uid).child("car_details").set(driverCarInfoMap);

      Fluttertoast.showToast(msg: "Car details has been saved. Congratulation");
      Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));

    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(darkTheme ? 'images/city_dark.jpg' : 'images/city.jpg'),

                SizedBox(height: 20,),
                Text(
                  "Add Car details",
                  style: TextStyle(
                    color: darkTheme ? Colors.amber[400] : Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Car Model',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: darkTheme ? Colors.black45 : Colors.grey[200],
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40.0),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )
                                ),
                                prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amber[400] : Colors.grey,),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text){
                                if(text == null || text.isEmpty){
                                  return 'Name can\'t be empty';
                                }
                                if(text.length < 2){
                                  return 'Please enter valid name';
                                }
                                if(text.length > 49){
                                  return 'Name can\'t be more than 50';
                                }
                              },
                              onChanged: (text) => setState(() {
                                carModelTextEditingController.text = text;
                              }),
                            ),
                            SizedBox(height: 10,),

                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Car Number',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: darkTheme ? Colors.black45 : Colors.grey[200],
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40.0),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )
                                ),
                                prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amber[400] : Colors.grey,),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text){
                                if(text == null || text.isEmpty){
                                  return 'Name can\'t be empty';
                                }
                                if(text.length < 2){
                                  return 'Please enter valid name';
                                }
                                if(text.length > 49){
                                  return 'Name can\'t be more than 50';
                                }
                              },
                              onChanged: (text) => setState(() {
                                carNumeberTextEditingController.text = text;
                              }),
                            ),
                            SizedBox(height: 10,),

                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Car Color',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: darkTheme ? Colors.black45 : Colors.grey[200],
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40.0),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )
                                ),
                                prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amber[400] : Colors.grey,),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text){
                                if(text == null || text.isEmpty){
                                  return 'Name can\'t be empty';
                                }
                                if(text.length < 2){
                                  return 'Please enter valid name';
                                }
                                if(text.length > 49){
                                  return 'Name can\'t be more than 50';
                                }
                              },
                              onChanged: (text) => setState(() {
                                carColorTextEditingController.text = text;
                              }),
                            ),
                            SizedBox(height: 10,),

                            DropdownButtonFormField(
                                decoration: InputDecoration(
                                  hintText: "Please choose your Car type",
                                  prefixIcon: Icon(Icons.car_crash, color: darkTheme ? Colors.amber[400] : Colors.grey,),
                                  filled: true,
                                  fillColor: darkTheme ? Colors.black45 : Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )
                                  )
                                ),
                                items: carTypes.map((car){
                                  return DropdownMenuItem(
                                    child: Text(
                                      car,
                                      style: TextStyle(
                                        color: Colors.grey
                                      ),
                                    ),
                                    value: car,
                                  );
                                }).toList(),
                                onChanged: (newValue){
                                  setState(() {
                                    selectedCarType = newValue.toString();
                                  });
                                }
                            ),
                            SizedBox(height: 10,),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: darkTheme ? Colors.amber[400] : Colors.blue,
                                onPrimary: darkTheme ? Colors.black : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              onPressed: (){
                                _submit();
                              },
                              child: Text(
                                "Confirm",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),

                            GestureDetector(
                              onTap: (){
                                // Navigator.push(context, MaterialPageRoute(builder: (c) => ForgetPasswordScreen()));
                              },
                              child: Text(
                                "Forget Password",
                                style: TextStyle(
                                  color: darkTheme ? Colors.amber[400] : Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Have an account?",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 5,),
                                GestureDetector(
                                  onTap: (){
                                    // Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                                  },
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: darkTheme ? Colors.amber[400] : Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
