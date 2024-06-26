
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/NavigatorController.dart';
import 'CreditManagerPageView.dart';
import 'HomePageView.dart';
import 'LoginPageView.dart';

import 'package:http/http.dart' as http;

import 'Utils/StyleData.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  String? version = "";
  String? accessToken;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<User> handleSignInEmail(String username, String password) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
        email: username, password: password);
    final User user = result.user!;
    print(user);
    return user;
  }




  startApp() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? employeeCode = pref.getString("employeeCode");
    String? emailID = pref.getString("emailID");
    String? loginType = pref.getString("logintype");

    if ((employeeCode != null && employeeCode.isNotEmpty) || (emailID != null && emailID.isNotEmpty)) {
      // User is already logged in, navigate directly to the appropriate home page
      NavigatorController.pagePush(
        context,
        loginType == "SalesManager" ? HomePageView() : CreditManagerPageView(),
      );
    } else {
      // User is not logged in, navigate to the login page
      NavigatorController.pagePush(
        context,
        LoginPage(),
      );
    }
  }

  // navigateFunc() async {
  //   bool isIPAddressMatching = false;
  //   _auth
  //       .signInWithEmailAndPassword(
  //       email: "itcoblr@muthootgroup.com", password: "Muthoot@123\$")
  //       .then((value) async {
  //     final User user = value.user!;
  //     print(user.uid);
  //     try {
  //       final uri = Uri.parse('https://api.ipify.org');
  //       final response = await http.get(uri);
  //
  //       if (response.statusCode == 200) {
  //         final ipAddress = response.body;
  //         print('Local IP Address: $ipAddress');
  //
  //         final snapshot = await FirebaseFirestore.instance
  //             .collection('ipAddress')
  //             .where('ipAddress', isEqualTo: ipAddress)
  //             .get();
  //         print(snapshot.docs);
  //         isIPAddressMatching = snapshot.docs.isNotEmpty ? true : false;
  //         print(snapshot.docs);
  //
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) =>
  //                 isIPAddressMatching ? startApp() : MessagePage()));
  //       } else {
  //         print('Failed to retrieve local IP address.');
  //       }
  //     } catch (e) {
  //       print('Error: $e');
  //     }
  //   });
  // }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   startApp();
  //  navigateFunc();
   // startApp();
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () => NavigatorController.disableBackBt(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Stack(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 13, right: 15),
                        child: SizedBox(
                            height: height * 0.4,
                            child: Lottie.asset('assets/jsons/spalsh.json',))),
                      ),
                    SizedBox(
                        child: Image.asset(
                          'assets/images/HomeFin.png',
                          height: height * 0.1,
                          fit: BoxFit.fill,
                        )),
                    SizedBox(
                      height: height * 0.08,
                    )

                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                child: SizedBox(
                  width: width,
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                            height: height * 0.015,
                            child: Image.asset(
                              'assets/images/login_muthootlogo.png',
                            )),
                        Text(
                          'V$version',
                          style: TextStyle(color: Colors.black38, fontSize: 10),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int getExtendedVersionNumber(String version) {
  List versionCells = version.split('.');
  versionCells = versionCells.map((i) => int.parse(i)).toList();
  return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
}

class MessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeFin Express'),
        backgroundColor: StyleData.appBarColor2,
      ),
      body: const Center(
        child: Text('Access denied'),
      ),
    );
  }
}