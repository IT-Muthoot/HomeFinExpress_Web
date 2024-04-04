import 'dart:convert';
import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/StyleData.dart';
import 'LoginPageView.dart';
import 'documentsPageView.dart';


class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {

  bool consentCRIF = true;
  bool consentKYC = true;

  String? docId;
  var data;


  CollectionReference convertedLeads =
  FirebaseFirestore.instance.collection('convertedLeads');

  List<QueryDocumentSnapshot> documents = [];
  bool usersVisibility = true;
  String searchText = '';
  TextEditingController _searchController = TextEditingController();

  var userType;
  List<DocumentSnapshot> ListOfLeads = [];
  TextEditingController searchKEY = TextEditingController();
  String? ManagerName;
  String? BranchCode;
  String? EmployeeName;
  String? Designation;
  String? VerificationStatus;


  void fetchdata() async {
    CollectionReference users = FirebaseFirestore.instance.collection('convertedLeads');
    SharedPreferences pref = await SharedPreferences.getInstance();
    // var userId = pref.getString("token");
    var userId = pref.getString("userID");
    var managerEmployeeCode = pref.getString("employeeCode");
    setState(() {
      userType = pref.getString("logintype");
   //   userType = pref.getString("Managerlogintype");
    });
    print(userType);
    if (userType == "user") {
      users.where("ManagerCode", isEqualTo: managerEmployeeCode).get().then((value) {
        setState(() {
          ListOfLeads = value.docs;
          data = value.docs;
          ManagerName = ListOfLeads[0]["ManagerName"] ?? "";
          BranchCode  = ListOfLeads[0]["homeFinBranchCode"] ?? "";
          EmployeeName  = ListOfLeads[0]["EmployeeName"] ?? "";
          Designation  = ListOfLeads[0]["Designation"] ?? "";
        });
              print(ManagerName);
              print(BranchCode);
              print(EmployeeName);
              print(Designation);

        for (var i = 0; value.docs.length > i; i++) {
          print(value.docs[i].data());
        }
      });
    } else {
      users.get().then((value) {
        setState(() {
          ListOfLeads = value.docs;
        });
        for (var i = 0; value.docs.length > i; i++) {
          print(value.docs[i].data());
        }
      });
    }
  }

  // void fetchdata1() async {
  //   CollectionReference users = FirebaseFirestore.instance.collection(
  //       'convertedLeads');
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //
  //   var userId = pref.getString("userID");
  //   var employeeCode = pref.getString(
  //       "employeeCode"); // Retrieve entered employee code
  //   print("Retrieve entered employee code");
  //   print(employeeCode);
  //   setState(() {
  //     userType = pref.getString("logintype");
  //   });
  //
  //   if (userType == "user") {
  //     Query query;
  //     if (employeeCode != null) {
  //       query = users.where("userId", isEqualTo: userId).where(
  //           "ManagerCode", isEqualTo: employeeCode);
  //     } else {
  //       query = users.where("userId", isEqualTo: userId);
  //     }
  //     query.get().then((value) {
  //       setState(() {
  //         ListOfLeads = value.docs;
  //       });
  //       for (var i = 0; value.docs.length > i; i++) {
  //         print(value.docs[i].data());
  //       }
  //     });
  //   } else {
  //     users.get().then((value) {
  //       setState(() {
  //         ListOfLeads = value.docs;
  //       });
  //       for (var i = 0; value.docs.length > i; i++) {
  //         print(value.docs[i].data());
  //       }
  //     });
  //   }
  // }

  List<DocumentSnapshot> searchListOfLeads = [];
  void _runFilter(String enteredKeyword) {
    var data = ListOfLeads.where((row) => (row["firstName"]
        .toString()
        .toUpperCase()
        .contains(enteredKeyword.toUpperCase())||
        row["LeadID"]
            .toString()
            .toUpperCase()
            .contains(enteredKeyword.toUpperCase()) || row["productCategory"]
        .toString()
        .toUpperCase()
        .contains(enteredKeyword.toUpperCase())  || row["VisitID"]
        .toString()
        .toUpperCase()
        .contains(enteredKeyword.toUpperCase()) || row["EmployeeName"]
        .toString()
        .toUpperCase()
        .contains(enteredKeyword.toUpperCase()))).toList() ;
    setState(() {
      searchListOfLeads = data;
    });
  }

  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  Future<void> _selectDate(BuildContext context, int type) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now, // Set the initialDate to today
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue, // Your custom yellow color
            hintColor: Color(0xff973232),
            colorScheme: ColorScheme.light(primary: Color(0xff973232)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Color(0xff973232),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (type == 1) {
          _startDateController.text = formatDate(pickedDate.toLocal().toString());
        } else {
          _endDateController.text = formatDate(pickedDate.toLocal().toString());
        }
      });
    }
  }
  String formatDate(String dateString) {
    try {
      // Assuming dateString is in the format 'yyyy-MM-dd HH:mm:ss.SSS'
      DateTime date = DateTime.parse(dateString);

      final formatter = DateFormat('yyyy-MM-dd');
      return formatter.format(date);
    } catch (e) {
      print("Error parsing date: $e");
      return " --";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchdata();
    super.initState();
    bool listVisibility = true;
    _startDateController.text = formatDate(DateTime.now().toLocal().toString());
    _endDateController.text = formatDate(DateTime.now().toLocal().toString());
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        // Navigate to HomePageView when back button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePageView(),
          ),
        );
        // Prevent the default back navigation
        return false;
      },
      child: Scaffold(
        appBar:  AppBar(
          backgroundColor: StyleData.appBarColor2,
          leading: Padding(
            padding: const EdgeInsets.all(19.0),
            child: InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(),
                  ),
                );
              },
              child:  Icon(Icons.logout, size: 30,color: Colors.white,),),
          ),
          title: Text("Lead Details",style: TextStyle(color: Colors.white,fontSize: 18,fontFamily: StyleData.boldFont),),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: width * 0.05,
                  ),
                  Builder(
                    builder: (context) {
                      String countText = ManagerName.toString();
                      double textWidth = countText.length * 8.0; // Adjust 8.0 based on your font size and preference
                      print(BranchCode);
                      print(EmployeeName);
                      print(Designation);
                      return Container(
                        width: textWidth + 100, // Adjust padding as needed
                        height: height * 0.036,
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(10),
                        //   color: Colors.white24,
                        // ),
                        child: Center(
                          child: Text(
                            countText,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      );
                    },
                  ),


                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.01,
              ),
              Row(
                children: [
                  Container(
                    width: width * 0.3,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchKEY,
                        style: const TextStyle(fontSize: 14,color: Colors.black54),
                        cursorColor: Colors.black87,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          labelStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.black54
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color:Colors.black54)),
                          contentPadding: const EdgeInsets.only(left: 1,),
                          hintStyle: const TextStyle(fontSize: 14,color: Colors.black54),
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {},
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: new BorderSide(color: Colors.grey)),
                        ),
                        onChanged: (value) {
                          _runFilter(value);
                        },
                      ),
                    ),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     Padding(
                  //       padding: EdgeInsets.only(right: 8.0),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.end,
                  //         children: [
                  //           // Text(
                  //           //   'From',
                  //           //   style: TextStyle(
                  //           //     fontSize: 16,
                  //           //  //   fontWeight: FontWeight.bold,
                  //           //   ),
                  //           // ),
                  //           // SizedBox(height: 4), // Adjust spacing as needed
                  //           Container(
                  //             height: height * 0.07,
                  //             width: width * 0.15,
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(30.0),
                  //               gradient: LinearGradient(
                  //                 colors: [
                  //                   Color.fromARGB(255, 236, 225, 215),
                  //                   Color.fromARGB(255, 227, 222, 215)
                  //                 ],
                  //               ),
                  //             ),
                  //             child: Padding(
                  //               padding: EdgeInsets.symmetric(horizontal: 8.0),
                  //               child: TextFormField(
                  //                 controller: _startDateController,
                  //                 readOnly: true,
                  //                 onTap: () => _selectDate(context, 1),
                  //                 decoration: InputDecoration(
                  //                   labelText: '',
                  //                   suffixIcon: Icon(Icons.calendar_today, size: 20,),
                  //                   focusedBorder: InputBorder.none,
                  //                   border: InputBorder.none,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //
                  //     Padding(
                  //       padding: EdgeInsets.only(right: 8.0),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.end,
                  //         children: [
                  //           // Text(
                  //           //   'To',
                  //           //   style: TextStyle(
                  //           //     fontSize: 16,
                  //           //   //  fontWeight: FontWeight.bold,
                  //           //   ),
                  //           // ),
                  //           // SizedBox(height: 4), // Adjust spacing as needed
                  //           Container(
                  //             height: height * 0.07,
                  //             width: width * 0.15,
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(30.0),
                  //               gradient: LinearGradient(
                  //                 colors: [
                  //                   Color.fromARGB(255, 236, 225, 215),
                  //                   Color.fromARGB(255, 227, 222, 215)
                  //                 ],
                  //               ),
                  //             ),
                  //             child: Padding(
                  //               padding: EdgeInsets.symmetric(horizontal: 8.0),
                  //               child: TextFormField(
                  //                 controller: _endDateController,
                  //                 readOnly: true,
                  //                 onTap: () => _selectDate(context,2),
                  //                 decoration: InputDecoration(
                  //                     labelText: '',
                  //                     suffixIcon: Icon(Icons.calendar_today,size: 20,),
                  //                     border: InputBorder.none
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
               Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "Total Leads",
                          style: TextStyle(
                            color: Colors.black26,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: width * 0.05,
                            ),
                            Builder(
                              builder: (context) {
                                String countText = searchKEY.text.isEmpty ? ListOfLeads.length.toString() : searchListOfLeads.length.toString();
                                double textWidth = countText.length * 8.0; // Adjust 8.0 based on your font size and preference

                                return Container(
                                  width: textWidth + 20, // Adjust padding as needed
                                  height: height * 0.036,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black,
                                  ),
                                  child: Center(
                                    child: Text(
                                      countText,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),


                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.01,
              ),
              SizedBox(
                height: height * 0.9,
                width: MediaQuery.of(context).size.width,
                child:ListOfLeads.isNotEmpty ?
                Scrollbar(
                  thickness: 8.5,
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  controller: ScrollController(),
                  child: ListView.builder(
                    itemCount: searchKEY.text.isEmpty
                        ? ListOfLeads.length
                        : searchListOfLeads.length,

                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                      searchKEY.text.isEmpty ?  ListOfLeads[index].data()  as Map<String, dynamic> : searchListOfLeads[index].data()
                      as Map<String, dynamic>;
                      ListOfLeads.sort((a, b) =>
                          (b['createdDateTime'] as Timestamp).compareTo(a['createdDateTime'] as Timestamp));
                      return
                        InkWell(
                        onTap: () {
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          EmployeeName.toString(),
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14.0,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          " - ",
                                          style: TextStyle(
                                            color: Colors.black26,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          BranchCode.toString(),
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14.0,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                    Icons.star,
                                                    color: Colors.yellow.shade800
                                                ),
                                                Text(
                                                  "VisitID",
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14.0,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                                Text(
                                                  " - ",
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14.0,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                                Text(
                                                  ListOfLeads[index]["VisitID"],
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14.0,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Lead ID",
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14.0,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                                Text(
                                                  " - ",
                                                  style: TextStyle(
                                                    color: Colors.black26,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  searchKEY.text.isEmpty
                                                      ? ListOfLeads[index]["LeadID"]
                                                      : searchListOfLeads[index]["LeadID"],
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14.0,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ],
                                            ),

                                          ],
                                        ),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: width * 0.15,
                                            ),
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Applicant Name",
                                                      style: TextStyle(
                                                        color: Colors.red.shade300,
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  searchKEY.text.isEmpty
                                                      ? ListOfLeads[index]["firstName"] + " " + ListOfLeads[index]["lastName"]
                                                      : searchListOfLeads[index]["firstName"] + " " + ListOfLeads[index]["lastName"],
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: width * 0.05,
                                            ),
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Product Category",
                                                      style: TextStyle(
                                                        color: Colors.red.shade300,
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  searchKEY.text.isEmpty
                                                      ? ListOfLeads[index]["productCategory"]
                                                      : searchListOfLeads[index]["productCategory"],
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // SizedBox(
                                            //   width: width * 0.5,
                                            // ),
                                            SizedBox(
                                              width: width * 0.2,
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                if (data.containsKey(
                                                    'Application_Form')) {
                                                  docId = data[
                                                  'Application_Form']
                                                      .toString();
                                                }
                                                if (data.containsKey(
                                                    'Bank_PassBook')) {
                                                  docId =
                                                  "$docId,${data['Bank_PassBook'].toString()}";
                                                }
                                                if (data.containsKey(
                                                    'Date_Of_Birth')) {
                                                  docId =
                                                  "$docId,${data['Date_Of_Birth'].toString()}";
                                                }
                                                if (data.containsKey(
                                                    'Login_Fee_Check')) {
                                                  docId =
                                                  "$docId,${data['Login_Fee_Check'].toString()}";
                                                }
                                                if (data.containsKey(
                                                    'Passport_Size_Photo')) {
                                                  docId =
                                                  "$docId,${data['Passport_Size_Photo'].toString()}";
                                                }
                                                if (data.containsKey(
                                                    'Photo_Id_Proof')) {
                                                  docId =
                                                  "$docId,${data['Photo_Id_Proof'].toString()}";
                                                }
                                                if (data.containsKey(
                                                    'Residence_Proof')) {
                                                  docId =
                                                  "$docId,${data['Residence_Proof'].toString()}";
                                                }
                                                if (data.containsKey(
                                                    'Salary_Slip')) {
                                                  docId =
                                                  "$docId,${data['Salary_Slip'].toString()}";
                                                }
                                                if (data.containsKey(
                                                    'Signature_Proof')) {
                                                  docId =
                                                  "$docId,${data['Signature_Proof'].toString()}";
                                                }
                                                print(docId);
                                                // New Implementation

                                                var map = <String,
                                                    dynamic>{};
                                                map['DocId'] = docId;
                                                map['LUSR'] = 'SBL';

                                                http.Response
                                                response =
                                                await http.post(
                                                  Uri.parse(
                                                      "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
                                                  body: map,
                                                );
                                                final data1 = response
                                                    .bodyBytes;
                                                final mime =
                                                lookupMimeType('',
                                                    headerBytes:
                                                    data1);
                                                if (docId
                                                    .toString()
                                                    .contains(",")) {
                                                  AnchorElement(
                                                      href:
                                                      "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                                    ..setAttribute(
                                                        "download",
                                                        data.containsKey(
                                                            'LeadID')
                                                            ? "${data['LeadID']}.zip"
                                                            : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                                                    ..click();
                                                } else {
                                                  AnchorElement(
                                                      href:
                                                      "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                                    ..setAttribute(
                                                        "download",
                                                        data.containsKey(
                                                            'LeadID')
                                                            ? "${data['LeadID']}.${mime.toString().split("/").last}"
                                                            : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                                                    ..click();
                                                }
                                              },
                                              icon: Column(
                                                children: [
                                                  Icon(
                                                      Icons.download_for_offline_rounded,
                                                      color: Colors.red.shade300
                                                  ),
                                                  Text(
                                                   "Download All" ,
                                                    style: TextStyle(
                                                      color: Colors.black26,
                                                      fontSize: 14.0,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => DocumentPageView(
                                                      docId: searchKEY.text.isEmpty ? ListOfLeads[index].id : searchListOfLeads[index].id,
                                                    )));
                                          },
                                          child: Column(
                                            children: [
                                              Icon(
                                                  Icons.visibility,
                                                  color: Colors.red.shade300
                                              ),
                                              Text(
                                                "View" ,
                                                style: TextStyle(
                                                  color: Colors.black26,
                                                  fontSize: 14.0,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ListOfLeads[index]["VerificationStatus"] == 'Verified' ?
                                        Card(
                                          child: Container(
                                            width: width * 0.06,
                                            color: Colors.white,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                searchKEY.text.isEmpty ? ListOfLeads[index]["VerificationStatus"] : searchListOfLeads[index]["VerificationStatus"],
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 14.0,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ) : Card(
                                          child: Container(
                                            width: width * 0.06,
                                            color: Colors.white,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                searchKEY.text.isEmpty ? ListOfLeads[index]["VerificationStatus"] : searchListOfLeads[index]["VerificationStatus"],
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14.0,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                //
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //
                                //
                                //
                                //   ],
                                // ),
                                // Center(
                                //
                                //   child: Text(
                                //     searchKEY.text.isEmpty
                                //         ? ListOfLeads[index]["LeadID"]
                                //         : searchListOfLeads[index]["LeadID"],
                                //     style: TextStyle(
                                //       color: Colors.black54,
                                //       fontSize: 14.0,
                                //       fontFamily: 'Poppins',
                                //     ),
                                //   ),
                                // ),
                                Divider(
                                  color: StyleData.appBarColor2,
                                  thickness: 0.3,
                                ),

                              ],
                            ),
                          ),
                        ),

                      );
                    },
                  ),
                )
                    : Center(
                  child: const Text(
                    'No Data found',
                    style: TextStyle(fontSize: 24),
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
