import 'dart:io';

import '../category_list/CategorytListScreen.dart';
import '../signup/RegisterModel.dart';
import 'package:flutter/material.dart';
import '../login/ForgotPassword.dart';
import '../shapes/ShapeComponent.dart';
import '../signup/SignUpScreen.dart';
import '../userdata/UserPrefs.dart';
import '../util/AppColors.dart';
import '../util/Consts.dart';
import '../util/Util.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //===========================
  String userEmail = "";
  String userPassword = "";
  String forgotEmail = "";
  String deviceToken;
  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  getToken() async {
    if (Platform.isIOS == TargetPlatform.iOS ||
        Platform.isMacOS == TargetPlatform.macOS) {
      print('FlutterFire Messaging Example: Getting APNs token...');
      String token = await FirebaseMessaging.instance.getAPNSToken();
      setState(() {
        deviceToken = token;
      });
      print('FlutterFire Messaging Example: Got APNs token: $token');
    } else if (Platform.isAndroid) {
      FirebaseMessaging.instance.getToken().then((token) {
        print(token);
        setState(() {
          deviceToken = token;
        });
      });
    } else {
      print(
          'FlutterFire Messaging Example: Getting an APNs token is only supported on iOS and macOS platforms.');
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  //========== Login handler =========
  void loginUser(BuildContext context) async {
    if (userEmail.trim() == "") {
      showCustomToast("Please enter email.");
      return;
    }
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (isNumeric(userEmail) && !regExp.hasMatch(userEmail)) {
      showCustomToast("Pleaase enter a valid phone number");
      return;
    } else if (!isEmail(userEmail)) {
      showCustomToast("Pleaase enter a valid email");
      return;
    }
    if (userPassword.trim() == "") {
      showCustomToast("Pleaase enter password");
      return;
    }
    var requestParam =
        "?email=" + userEmail.trim() + "&password=" + userPassword.trim();

    requestParam += "&device_token=" + deviceToken;

    print(Uri.parse(Consts.LOGIN_USER + requestParam));
    final http.Response response = await http.get(
      Uri.parse(Consts.LOGIN_USER + requestParam),
    );
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverMessage = responseData['message'];
      if (responseData['status'] == "success") {
        var userData = responseData['userdata'];
        RegisterUserModel registerUserModel = RegisterUserModel();

        registerUserModel.userId = userData['user_id'];
        registerUserModel.firstname = userData['firstname'];
        registerUserModel.lastname = userData['lastname'];
        registerUserModel.email = userData['email'];
        registerUserModel.userType = userData['user_type'];
        registerUserModel.phone = userData['phone'];
        saveUserLoginPrefs(registerUserModel);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CategorytListScreen(),
          ),
        );
      } else {
        showCustomToast(serverMessage);
      }
    } else {
      showCustomToast("Error while conneting to server");
      print("Error getting response  ${response.statusCode}");
      throw Exception("Error getting response  ${response.statusCode}");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    deviceToken = "";
    getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // drawer: Navigation(),
      appBar: AppBar(
        title: Text("Vedic"),
        actions: <Widget>[],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "images/image_bg.png",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              shapeComponet(context, Consts.shapeHeight),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 40.0,
                  left: 40,
                  right: 40,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(3),
                        ),
                        border: Border.all(
                            color: AppColors.loginContainerBorder, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: loginForm(context),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget navDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          // Important: Remove any padding from the ListView.

          padding: EdgeInsets.only(top: 10),
          children: <Widget>[
            // DrawerHeader(
            //   child: Text('Drawer Header'),
            //   decoration: BoxDecoration(
            //     color: Colors.blue,
            //   ),
            // ),
            ListTile(
              title: Text(
                'Item 1',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text(
                'Item 2',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget loginForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 60,
        ),
        Theme(
          data: ThemeData(
            primaryColor: Colors.redAccent,
            primaryColorDark: Colors.red,
          ),
          child: new TextField(
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0XFFD4DFE8),
                  width: 2,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0XFFD4DFE8),
                  width: 2,
                ),
              ),
              hintText: 'Mobile / Email',
              hintStyle: TextStyle(
                color: Colors.black,
              ),
            ),
            onChanged: (value) => {
              setState(
                () {
                  userEmail = value;
                },
              )
            },
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Theme(
          data: ThemeData(
            primaryColor: Colors.redAccent,
            primaryColorDark: Colors.red,
          ),
          child: new TextField(
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0XFFD4DFE8),
                  width: 2,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0XFFD4DFE8),
                  width: 2,
                ),
              ),
              hintText: 'Password',
              hintStyle: TextStyle(
                color: Colors.black,
              ),
            ),
            obscureText: true,
            onChanged: (value) => {
              setState(
                () {
                  userPassword = value;
                },
              )
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: _forgotDialogPopup,
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: AppColors.forgotPasswordColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.appMainColor,
          ),
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: TextButton(
            onPressed: () {
              loginUser(context);
              ;
            },
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(
                color: AppColors.loginTextColor,
                fontSize: 15,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            InkWell(
              onTap: () {
                Navigator.pop(
                  context,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpScreen(),
                  ),
                );
              },
              child: Text(
                "Sign up",
                style: TextStyle(
                  color: AppColors.forgotPasswordColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 80,
        ),
      ],
    );
  }

  void _forgotDialogPopup() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return Theme(
                data: Theme.of(context).copyWith(
                  dialogBackgroundColor: Colors.white,
                ),
                child: AlertDialog(
                  title: Text(
                    "Forgot password",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  content: StatefulBuilder(
                    // You need this, notice the parameters below:
                    builder: (BuildContext context, StateSetter setState) {
                      return ForgotPassword();
                    },
                  ),
                ),
              );
            });
      },
    );
  }
}
