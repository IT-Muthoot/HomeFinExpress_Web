import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/StyleData.dart';
import 'LoginPageView.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  TextEditingController ReportingManagerName = TextEditingController();
  TextEditingController ReportingManagerCode = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController1 = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();
  TextEditingController confirmpasswordController1 = TextEditingController();
  TextEditingController branchcode = TextEditingController();
  TextEditingController branchcode1 = TextEditingController();
  TextEditingController branchName = TextEditingController();
  TextEditingController region1 = TextEditingController();
  TextEditingController zoneName = TextEditingController();
  TextEditingController creditEmailID = TextEditingController();
  final registerformKey = GlobalKey<FormState>();
  final registerformKey1 = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  final List<String> userType = [
    'RO',
    'RM',
  ];
  String? selectedUserType;


  List employeeList = [];
  List creditList = [];
  List<dynamic> outputList1 = [];
  List<dynamic> outputCreditList = [];

  List employeeList2 = [];
  List outputList2 = [];

  String? Designation;
  String? RegionName;
  String? Zone;

  String? Designation1;
  String? RegionName1;
  String? Zone1;

  bool isSalesManager = false;


  getEmployee1Details(String emp) async {
    FirebaseFirestore.instance
        .collection("employeeMapping")
        .doc("employeeMapping")
        .get()
        .then((value) async {
      for (var element in value.data()!["employeeMapping"]) {
        setState(() {
          employeeList.add(element);
        });
      }

      setState(() {
        outputList1 =
            employeeList.where((o) => o['Reporting Manager Code'] == ReportingManagerCode.text).toList();
        ReportingManagerName.text = outputList1[0]['Reporting Manager Name'];
        branchcode.text = outputList1[0]['BRANCH CODE'];
        Designation = outputList1[0]['DSGN_NAME'];
        RegionName = outputList1[0]['REGION'];
        Zone = outputList1[0]['ZONE'];
      });
     // print("Output List " + outputList1.toString());

    });
  }

  


  String? selectedOption;


  @override
  void initState() {
    // TODO: implement initState
   // fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body:
      SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 3,
                child: Container(
                  width: width * 0.3,
                  height: height * 1.1,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                "REGISTER",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: StyleData.buttonColor,
                                    fontSize: 30
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            // Column(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   children: [
                            //     RadioListTile<String>(
                            //       title: Text('SM'),
                            //       value: 'SM',
                            //       activeColor: StyleData.appBarColor,
                            //       groupValue: selectedOption,
                            //       onChanged: (value) {
                            //         setState(() {
                            //           selectedOption = value!;
                            //         });
                            //       },
                            //     ),
                            //     RadioListTile<String>(
                            //       title: Text('CM'),
                            //       value: 'CM',
                            //       activeColor: StyleData.appBarColor,
                            //       groupValue: selectedOption,
                            //       onChanged: (value) {
                            //         setState(() {
                            //           selectedOption = value!;
                            //         });
                            //       },
                            //     ),
                            //   ],
                            // ),
                            Form(
                              key: registerformKey,
                              child: Column(
                                children: [
                                  SizedBox(height: height * 0.03),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(horizontal: 40),
                                    child: TextFormField(
                                      controller: ReportingManagerCode,
                                      decoration: InputDecoration(
                                          labelText: "Employee Code *"
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.singleLineFormatter,
                                        LengthLimitingTextInputFormatter(7),
                                        UppercaseInputFormatter(),
                                      ],
                                      onChanged: (empCode) {
                                        getEmployee1Details(empCode);
                                      },
                                      validator: (isusernamevalid) {
                                        if (isusernamevalid.toString().isNotEmpty)
                                          return null;
                                        else
                                          return 'Enter valid Employee code';
                                      },
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(horizontal: 40),
                                    child: TextFormField(
                                      controller: ReportingManagerName,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                          labelText: "Employee Name *"
                                      ),

                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(horizontal: 40),
                                    child: TextFormField(
                                      controller: branchcode,
                                     readOnly: true,
                                      decoration: InputDecoration(
                                          labelText: "Branch Code *"
                                      ),
                                    ),
                                  ),
                                  // Container(
                                  //   alignment: Alignment.center,
                                  //   margin: EdgeInsets.symmetric(horizontal: 40),
                                  //   child: TextFormField(
                                  //     controller: mobileNumber,
                                  //     keyboardType: TextInputType.phone,
                                  //     inputFormatters: [
                                  //       FilteringTextInputFormatter.digitsOnly,
                                  //       LengthLimitingTextInputFormatter(10),
                                  //     ],
                                  //     decoration: InputDecoration(
                                  //         labelText: "Mobile Number *"
                                  //     ),
                                  //     validator: (isusernamevalid) {
                                  //       if (isusernamevalid.toString().isNotEmpty)
                                  //         return null;
                                  //       else
                                  //         return 'Enter valid mobile Number';
                                  //     },
                                  //   ),
                                  // ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(horizontal: 40),
                                    child: TextFormField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                          labelText: "Useremail *"
                                      ),
                                      validator: (value) {
                                        String p =
                                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

                                        RegExp regExp = RegExp(p);

                                        if (!regExp.hasMatch(value!)) {
                                          return "Enter valid email id";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(horizontal: 40),
                                    child: TextFormField(
                                      controller: passwordController,
                                      decoration: InputDecoration(
                                          labelText: "Password *",
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
                                      validator: (ispasswordvalid) {
                                        if (ispasswordvalid.toString().isNotEmpty)
                                          return null;
                                        else
                                          return 'Enter valid password';
                                      },
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.symmetric(horizontal: 40),
                                    child: TextFormField(
                                      controller: confirmpasswordController,
                                      decoration: InputDecoration(
                                          labelText: "Confirm Password *",
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                            color: Colors.black54,
                                          ),
                                          onPressed: () {
                                            // Toggle the password visibility
                                            setState(() {
                                              isConfirmPasswordVisible = !isConfirmPasswordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: !isConfirmPasswordVisible,
                                      validator: (isconfirmpasswordvalid) {
                                        if (isconfirmpasswordvalid.toString().isNotEmpty)
                                          return null;
                                        else if (passwordController !=
                                            confirmpasswordController) {
                                          return 'Confirm password must match to the password';
                                        } else
                                          return 'Enter valid confirm password';
                                      },
                                    ),
                                  ),
                                  SizedBox(height: height * 0.05),
                                ],
                              ),
                            ),

                            Visibility(
                              visible: selectedOption == 'CM',
                              child: Form(
                                key: registerformKey1,
                                child: Column(
                                  children: [
                                    SizedBox(height: height * 0.03),
                                    Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.symmetric(horizontal: 40),
                                      child: TextFormField(
                                        controller: creditEmailID,
                                        decoration: InputDecoration(
                                            labelText: "Email Id *"
                                        ),
                                        validator: (isusernamevalid) {
                                          if (isusernamevalid.toString().isNotEmpty)
                                            return null;
                                          else
                                            return 'Enter valid email ID';
                                        },
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.symmetric(horizontal: 40),
                                      child: TextFormField(
                                        controller: branchcode1,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                            labelText: "Branch Code *"
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.symmetric(horizontal: 40),
                                      child: TextFormField(
                                        controller: passwordController1,
                                        decoration: InputDecoration(
                                          labelText: "Password *",
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
                                        validator: (ispasswordvalid) {
                                          if (ispasswordvalid.toString().isNotEmpty)
                                            return null;
                                          else
                                            return 'Enter valid password';
                                        },
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.symmetric(horizontal: 40),
                                      child: TextFormField(
                                        controller: confirmpasswordController1,
                                        decoration: InputDecoration(
                                          labelText: "Confirm Password *",
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                              color: Colors.black54,
                                            ),
                                            onPressed: () {
                                              // Toggle the password visibility
                                              setState(() {
                                                isConfirmPasswordVisible = !isConfirmPasswordVisible;
                                              });
                                            },
                                          ),
                                        ),
                                        obscureText: !isConfirmPasswordVisible,
                                        validator: (isconfirmpasswordvalid) {
                                          if (isconfirmpasswordvalid.toString().isNotEmpty)
                                            return null;
                                          else if (passwordController !=
                                              confirmpasswordController) {
                                            return 'Confirm password must match to the password';
                                          } else
                                            return 'Enter valid confirm password';
                                        },
                                      ),
                                    ),
                                    SizedBox(height: height * 0.05),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                print("Helloo");
                                if (registerformKey.currentState!.validate() ) {
                                  if(passwordController.text == confirmpasswordController.text)
                                    {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return Center(
                                            child: SpinKitFadingCircle(
                                              color: Colors.redAccent, // choose your preferred color
                                              size: 50.0,
                                            ),
                                          );
                                        },
                                      );
                                      try {
                                        final credential = await FirebaseAuth.instance
                                            .createUserWithEmailAndPassword(
                                          email: emailController.text,
                                          password: passwordController.text,
                                        );
                                        print("Helloo");
                                        if (credential.user!.uid != "") {
                                          CollectionReference users = FirebaseFirestore
                                              .instance
                                              .collection('managerLog');
                                         if(Designation != "CreditManager")
                                           {
                                             Map<String, dynamic> params = {
                                               "ManagerName": ReportingManagerName.text,
                                               "ManagerCode": ReportingManagerCode.text,
                                               //   "MobileNumber": mobileNumber.text,
                                               "email": emailController.text,
                                               "password": passwordController.text,
                                               "branchCode": branchcode.text,
                                               "confirmPassword": confirmpasswordController.text,
                                               "designation": Designation,
                                               "Region": RegionName,
                                               "Zone": Zone,
                                               "userId": credential.user!.uid,
                                               "createdDate": Timestamp.now(),
                                               "userType": "SalesManager",
                                             };
                                             users.add(params);
                                           }
                                         else {
                                           Map<String, dynamic> params = {
                                             "ManagerName": ReportingManagerName.text,
                                             "ManagerCode": ReportingManagerCode.text,
                                             //   "MobileNumber": mobileNumber.text,
                                             "email": emailController.text,
                                             "password": passwordController.text,
                                             "branchCode": branchcode.text,
                                             "confirmPassword": confirmpasswordController.text,
                                             "designation": Designation,
                                             "Region": RegionName,
                                             "Zone": Zone,
                                             "userId": credential.user!.uid,
                                             "createdDate": Timestamp.now(),
                                             "userType": "CreditManager",
                                           };
                                           users.add(params);
                                         }
                                          customSuccessSnackBar1("Registered Successfully");
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LoginPage(),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        }
                                        Navigator.pop(context);
                                      } on FirebaseAuthException catch (e) {
                                        if (e.code == 'weak-password') {
                                          customSuccessSnackBar("The password provided is too weak.");
                                        } else if (e.code == 'email-already-in-use') {
                                          customSuccessSnackBar("The account already exists for that email.");
                                        }
                                        Navigator.pop(context);
                                      } catch (e) {
                                        customSuccessSnackBar("Something went wrong, try again later");
                                        print(e);
                                      }
                                      Navigator.pop(context);
                                    }
                                  else
                                  {
                                    customSuccessSnackBar("Password & Confirm password must be same");
                                  }
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
                                      gradient: new LinearGradient(
                                          colors: [
                                            //       Color.fromARGB(255, 255, 136, 34),
                                            Color.fromARGB(255, 236, 139, 34),
                                            Color.fromARGB(255, 255, 177, 41)
                                          ]
                                      )
                                  ),
                                  padding: const EdgeInsets.all(0),
                                  child: Text(
                                    "SIGN UP",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
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
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()))
                                },
                                child: Text(
                                  "Already Have an Account? Sign in",
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

    );
  }
  void customSuccessSnackBar1(String msg) {
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
                    height: 40,
                    width: 27,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white)
                    ),
                    child: const Icon(
                      Icons.done_outline,
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
        backgroundColor: Colors.green,
        // backgroundColor: const Color(0xffee5b5b),
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
                    height: 40,
                    width: 27,
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
        backgroundColor: const Color(0xfff88405),
        // backgroundColor: const Color(0xffee5b5b),
      ),
    );
  }
}

class UppercaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text!.toUpperCase(),
      selection: newValue.selection,
    );
  }
}