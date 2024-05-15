
import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/NavigatorController.dart';
import 'CreditManagerPageView.dart';
import 'HomePageView.dart';
import 'LoginPageView.dart';

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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startApp();
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
