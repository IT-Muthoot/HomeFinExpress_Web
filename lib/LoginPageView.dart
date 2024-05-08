import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homefin_express_web/Utils/StyleData.dart';
import 'HomePageView.dart';
import 'RegisterPageView.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController empCodeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final loginformKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  UnderlineInputBorder enb =  UnderlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   const BorderSide(color:  Colors.black38)
  );
  UnderlineInputBorder focus =  UnderlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:  const BorderSide(color: Color(0xff778287))
  );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: StyleData.appBarColor2,
        title: Center(child: Text('HomeFin Express',style: TextStyle(color: StyleData.appBarColor3,fontSize: 25),)),

      ),
      body: Center(
        child: Padding(
          // padding: const EdgeInsets.only(right: 60),
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: 400,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Same radius as ClipRRect
                    ),
                    elevation: 4,
                    child: SizedBox(
                      width: width * 0.3, // Set the desired width
                      height: height * 0.8,
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                           crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Image.asset(
                                  "assets/images/login_muthootlogo.png",
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.symmetric(horizontal: 40),
                                    child: Text(
                                      "LOGIN",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: StyleData.buttonColor,
                                          fontSize: 30
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),

                                  SizedBox(height:height * 0.03),
                                  Form(
                                    key: loginformKey,
                                    child: Column(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.symmetric(horizontal: 40),
                                          child: TextFormField(
                                            controller: empCodeController,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.singleLineFormatter,
                                              LengthLimitingTextInputFormatter(7),
                                              // Convert input to uppercase
                                              UppercaseTextInputFormatter(),
                                            ],
                                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                                            textInputAction: TextInputAction.next,
                                            cursorColor: Colors.black87,
                                            decoration: InputDecoration(
                                              labelText: "Employee Code",
                                              labelStyle: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54,
                                              ),
                                              prefixIcon: Icon(Icons.person_3_outlined, size: 18, color: Colors.black54),
                                              focusedBorder: focus,
                                              enabledBorder: enb,
                                              contentPadding: const EdgeInsets.only(left: 5,),
                                              hintStyle: const TextStyle(fontSize: 14, color: Colors.black54),
                                            ),
                                            validator: (isusercodevalid) {
                                              if (isusercodevalid.toString().isNotEmpty)
                                                return null;
                                              else
                                                return 'Enter valid Employee code';
                                            },
                                          ),
                                        ),

                                        SizedBox(height:height * 0.03),
                                        Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.symmetric(horizontal: 40),
                                          child: TextFormField(
                                            controller: passwordController,
                                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                                            cursorColor: Colors.black87,
                                            decoration: InputDecoration(
                                              focusedBorder: focus,
                                              enabledBorder: enb,
                                              labelText: "Password",
                                              prefixIcon: Icon(Ionicons.lock_closed_outline, size: 18, color: Colors.black54),
                                              contentPadding: const EdgeInsets.only(left: 5,),
                                              hintStyle: const TextStyle(fontSize: 14, color: Colors.black54),
                                              labelStyle: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black54,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                                  color: Colors.black54,
                                                ),
                                                onPressed: () {
                                                  // Toggle the password visibility
                                                  setState(() {
                                                    isPasswordVisible = !isPasswordVisible;
                                                  });
                                                },
                                              ),
                                            ),
                                            obscureText: !isPasswordVisible,
                                            validator: (isPasswordValid) {
                                              if (isPasswordValid.toString().isNotEmpty)
                                                return null;
                                              else if (isPasswordValid!.length < 8) {
                                                return 'Password must contain at least 8 characters';
                                              } else
                                                return 'Enter a valid password';
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),


                                  GestureDetector(
                                    onTap: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //       builder: (context) =>
                                      //       const ForgotPasswordView()),
                                      // );
                                    },
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                                      child: Text(
                                        "Forgot your password?",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: StyleData.buttonColor,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height:height * 0.05),

                                  GestureDetector(
                                    onTap: () async {
                                      if (loginformKey.currentState!.validate()) {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return Center(
                                              child: SpinKitFadingCircle(
                                                color: Colors.redAccent,
                                                size: 50.0,
                                              ),
                                            );
                                          },
                                        );
                                        SharedPreferences pref = await SharedPreferences.getInstance();
                                        CollectionReference users = FirebaseFirestore.instance.collection('managerLog');
                                        print('Employee Code from controller: ${empCodeController.text}');
                                        users.where("ManagerCode", isEqualTo: empCodeController.text.toUpperCase())
                                            .where("password", isEqualTo: passwordController.text)
                                            .get()
                                            .then((value)  {
                                          print('Query snapshot: ${value.docs}');
                                          if (value.docs.isNotEmpty) {
                                            //  pref.setString("token", credential.user!.uid);
                                            pref.setString("logintype",
                                                value.docs[0].get("userType") ?? "SalesManager");
                                            pref.setString("Managerlogintype",
                                                value.docs[0].get("userType") ?? "ManagerLogin");
                                            pref.setString("userID", value.docs[0].get("userId"));
                                            pref.getString("userID") ?? "";
                                            print("USERIDPrint");
                                            //  print(userId);
                                            pref.setString("password", passwordController.text);
                                            pref.setString("employeeCode", empCodeController.text);
                                            print('Document exists with employee code: $empCodeController');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => HomePageView(),
                                              ),
                                            );
                                          } else {
                                            Navigator.pop(context);
                                           customSuccessSnackBar("Enter valid credentials");
                                          }
                                        }).catchError((error) {
                                          print('Error getting document: $error');
                                        });
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 50.0,
                                        width: width * 0.5,
                                        decoration: new BoxDecoration(
                                            borderRadius: BorderRadius.circular(80.0),
                                            //color: StyleData.appBarColor3,
                                            gradient: new LinearGradient(
                                                colors: [
                                                  // Color.fromARGB(255, 168, 2, 2),
                                                  // Color.fromARGB(255, 206, 122, 122)
                                                  Color.fromARGB(255, 236, 154, 64),
                                                  Color.fromARGB(255, 255, 177, 41)
                                                ]
                                            )
                                        ),
                                        padding: const EdgeInsets.all(0),
                                        child: Text(
                                          "LOGIN",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold

                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Container(
                                    alignment: Alignment.centerRight,
                                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                                    child: GestureDetector(
                                      onTap: () => {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()))
                                      },
                                      child: Text(
                                        "Don't Have an Account? Sign up",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: StyleData.buttonColor,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void customSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: '',
          onPressed: () {
            // Code to execute.
          },
        ),
        content: Container(

          // margin: const EdgeInsets.only(left: 10),
          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.white)
          // ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 35,
                    width: 20,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white)
                    ),
                    child: const Icon(
                      Icons.error_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                      width: 230,
                      child: Text(msg)),
                  const SizedBox(
                    width: 10,
                  ),

                  // Icon(Icons.done,color: Colors.white,)
                ])),
        duration: const Duration(seconds: 2),
        // width:MediaQuery.of(context).size. width * 0.9, // Width of the SnackBar.
        // padding: const EdgeInsets.symmetric(
        //   horizontal: 8.0, // Inner padding for SnackBar content.
        // ),
        // behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: StyleData.appBarColor2,
        // backgroundColor: const Color(0xffee5b5b),
      ),
    );
  }

}
class UppercaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text!.toUpperCase(),
      selection: newValue.selection,
    );
  }
}