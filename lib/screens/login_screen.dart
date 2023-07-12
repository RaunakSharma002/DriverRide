import 'package:driver_ride/screens/register_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';


import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import 'forget_password_screen.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  //Declare a global key
  final _formKey = GlobalKey<FormState>();

  void _submit () async{
    //validate all the form fields
    if(_formKey.currentState!.validate()){
      await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim()
      ).then((auth) async{

        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("drivers");
        userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async{
          final snap = value.snapshot;
          if(snap.value != null){
            currentUser = auth.user;
            await Fluttertoast.showToast(msg: "Successfully Logged In");
            Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
          }
          else{
            await Fluttertoast.showToast(msg: "No record exist with this email");
            firebaseAuth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
          }
        });

      }).catchError((errorMessage){
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
      });
    }
    else{
      Fluttertoast.showToast(msg: "Not all fields are valid");
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
          padding: EdgeInsets.all(0.0),
          children: [
            Column(
              children: [
                Image.asset(darkTheme ? 'images/city_dark.jpg' : 'images/city.jpg'),

                SizedBox(height: 20,),

                Text(
                  "Login",
                  style: TextStyle(
                    color: darkTheme ? Colors.amber[400] : Colors.blue,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
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
                                LengthLimitingTextInputFormatter(100),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Email',
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
                                  return 'Email can\'t be empty';
                                }
                                if(EmailValidator.validate(text) == true){
                                  return null;
                                }
                                if(text.length < 2){
                                  return 'Please enter valid email';
                                }
                                if(text.length > 99){
                                  return 'Email can\'t be more than 100';
                                }
                              },
                              onChanged: (text) => setState(() {
                                emailTextEditingController.text = text;
                              }),
                            ),
                            SizedBox(height: 10,),

                            TextFormField(
                              obscureText: !_passwordVisible,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Password',
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
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: darkTheme ? Colors.amber[400] : Colors.grey,
                                  ),
                                  onPressed: (){
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (text){
                                if(text == null || text.isEmpty){
                                  return 'Password can\'t be empty';
                                }
                                if(text.length < 6){
                                  return 'Please enter valid password';
                                }
                                if(text.length > 49){
                                  return 'Password can\'t be more than 50';
                                }
                                return null;
                              },
                              onChanged: (text) => setState(() {
                                passwordTextEditingController.text = text;
                              }),
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
                                "Login",
                                style: TextStyle(
                                  fontSize: 20,

                                ),
                              ),
                            ),
                            SizedBox(height: 10,),

                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (c) => ForgetPasswordScreen()));
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
                                  "Doesn't have an account?",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 5,),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (c) => RegisterScreen()));
                                  },
                                  child: Text(
                                    "Register",
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
            ),
          ],
        ),
      ),
    );
  }
}



