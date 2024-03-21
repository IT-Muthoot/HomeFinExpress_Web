

import 'dart:convert';
import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homefine_lms_web/HomePageView.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import '../Utils/StyleData.dart';

class DocumentPageView extends StatefulWidget {
  final String docId;
  const DocumentPageView({Key? key,
    required this.docId})
      : super(key: key);

  @override
  State<DocumentPageView> createState() => _DocumentPageViewState();
}

class _DocumentPageViewState extends State<DocumentPageView> {
  bool isVerification = false;
  String? docId;
  bool downloading = false;

  var userType;
  List<DocumentSnapshot> ListOfLeads = [];
  String? LeadID;
  String? ApplicantFirstName;
  String? ApplicantLastName;
  String? ApplicantFullName;
  String? CustomerNumber;
  String? DateOfBirth;
  String? Gender;
  String? HomeFinBranchCode;
  String? LeadAmount;
  String? LeadSource;
  String? panCardNumber;
  String? salutation;
  String? productCategory;
  String? products;
  String? mobileNumber;
  String? aadharNumber;
  String? applicationform;
  String? bankPassbook;
  var docData;

  void fetchdata() async {
    CollectionReference users =
    FirebaseFirestore.instance.collection('convertedLeads');
    users.doc(widget.docId).get().then((value) async {
      setState(() {
        docData = value.data();
      });
      ApplicantFirstName = docData["firstName"] ?? "";
      LeadID  = docData["LeadID"] ?? "";
      ApplicantLastName = docData["lastName"] ?? "";
      CustomerNumber = docData["customerNumber"] ?? "";
      DateOfBirth = docData["dateOfBirth"] ?? "";
      Gender = docData["gender"] ?? "";
      HomeFinBranchCode = docData["homeFinBranchCode"] ?? "";
      LeadAmount = docData["leadAmount"] ?? "";
      LeadSource = docData["leadSource"] ?? "";
      panCardNumber = docData["panCardNumber"] ?? "";
      aadharNumber = docData["aadharNumber"] ?? "";
      //  print(_leadSource.text);
      print(ApplicantFirstName);
      print(LeadID);

    });
    // CollectionReference users = FirebaseFirestore.instance.collection('convertedLeads');
    // SharedPreferences pref = await SharedPreferences.getInstance();
    // // var userId = pref.getString("token");
    // var userId = pref.getString("userID");
    // setState(() {
    //   userType = pref.getString("logintype");
    // });
    // print(userType);
    // if (userType == "user") {
    //   users.where("userId", isEqualTo: userId).get().then((value) {
    //     setState(() {
    //       ListOfLeads = value.docs;
    //     });
    //     for (var i = 0; value.docs.length > i; i++) {
    //       print(value.docs[i].data());
    //       setState(() {
    //         LeadID = ListOfLeads[i]['LeadID'];
    //          ApplicantFirstName = ListOfLeads[i]['firstName'] ;
    //          ApplicantLastName = ListOfLeads[i]['lastName'] ;
    //         CustomerNumber = ListOfLeads[i]['customerNumber'];
    //         DateOfBirth = ListOfLeads[i]['dateOfBirth'];
    //         Gender = ListOfLeads[i]['gender'];
    //         HomeFinBranchCode = ListOfLeads[i]['homeFinBranchCode'];
    //         LeadAmount = ListOfLeads[i]['leadAmount'];
    //         LeadSource = ListOfLeads[i]['leadSource'];
    //         panCardNumber = ListOfLeads[i]['panCardNumber'];
    //         salutation = ListOfLeads[i]['salutation'];
    //         productCategory = ListOfLeads[i]['productCategory'];
    //         products = ListOfLeads[i]['products'];
    //         aadharNumber = ListOfLeads[i]['aadharNumber'];
    //         print(LeadID);
    //         print(ApplicantFirstName);
    //       });
    //     }
    //   });
    // } else {
    //   users.get().then((value) {
    //     setState(() {
    //       ListOfLeads = value.docs;
    //     });
    //     for (var i = 0; value.docs.length > i; i++) {
    //       print(value.docs[i].data());
    //     }
    //   });
    // }
  }

  String? selectedDoc;




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        // Navigate to ApplicantDetailsView when back button is pressed
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ApplicantDetailsView(),
        //   ),
        // );
        // Prevent the default back navigation
        return false;
      },
      child: SafeArea(child: Scaffold(
        appBar:  AppBar(
          backgroundColor: StyleData.appBarColor2,
          title: Text("Applicant Detail",style: TextStyle(color: Colors.white,fontSize: 18,fontFamily: StyleData.boldFont),),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(19.0),
            child: GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HomePageView(),
                  ),
                );
              },
              child:  Container(
                child: Image.asset(
                  'assets/images/arrow.png',
                ),
              ),),
          ),

        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text("Lead ID - ",style: TextStyle(color: Colors.black87,fontSize: 16,fontFamily: StyleData.boldFont),),
                              Text(LeadID ?? "",style: TextStyle(color: StyleData.appBarColor2,fontSize: 16,fontFamily: StyleData.boldFont),),
                            ],
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Row(
                            children: [
                              Text("Applicant Name   - ",style: TextStyle(color: Colors.black38,fontSize: 13,),),
                            //  Spacer(),
                            //   SizedBox(
                            //     width: width * 0.06,
                            //   ),
                              Text((ApplicantFirstName ?? '') + ' ' + (ApplicantLastName ?? '') ?? "",style: TextStyle(color:Colors.black,fontSize: 15,fontFamily: StyleData.boldFont),),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Mobile Number    -",style: TextStyle(color: Colors.black38,fontSize: 13,),),
                            //  Spacer(),
                              Text(CustomerNumber ?? "",style: TextStyle(color:Colors.black,fontSize: 15,fontFamily: StyleData.boldFont),),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Date Of Birth        -",style: TextStyle(color: Colors.black38,fontSize: 13,),),
                             // Spacer(),
                              Text(DateOfBirth ?? "",style: TextStyle(color:Colors.black,fontSize: 15,fontFamily: StyleData.boldFont),),
                            ],
                          ),
                          Divider(
                            thickness: 0.4,
                          ),
                          Row(
                            children: [
                              Text("PAN Number         -",style: TextStyle(color: Colors.black38,fontSize: 13),),
                            //  Spacer(),
                              Text(panCardNumber ?? "",style: TextStyle(color:Colors.black,fontSize: 15,fontFamily: StyleData.boldFont),),
                            ],
                          ),
                          Row(
                            children: [
                              Text("Aadhar Number    -",style: TextStyle(color: Colors.black38,fontSize: 13),),
                            //  Spacer(),
                              Text(aadharNumber ?? "",style: TextStyle(color:Colors.black,fontSize: 15,fontFamily: StyleData.boldFont),),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Card(
                  elevation: 3,
                  child: Container(
                    height: height * 1,
                    width: width * 0.5,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Documents",
                            style: TextStyle(
                              color:  StyleData.appBarColor2,
                              fontFamily: StyleData.boldFont,
                              fontSize: 17,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "Application Form",
                                  style: TextStyle(
                                    color:  Colors.black,
                                    fontFamily: StyleData.boldFont,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              (docData != null && docData.containsKey('Application_Form')) ?
                              InkWell(
                                onTap: () async {
                                  print(docData);
                                  print("bjksjjjjjjjj");

                                  if (docData.containsKey(
                                      'Application_Form')) {
                                    docId = docData['Application_Form'].toString();
                                    // "${docData['Application_Form'].toString()}";
                                  }
                                  print(docId);
                                  // New Implementation
                                  var map = <String,
                                      dynamic>{};
                                  map['DocId'] = docId;
                                  map['LUSR'] = 'HomeFin';

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
                                  print(mime);
                                  if (docId.toString().contains(",")) {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.zip"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                                      ..click();
                                  } else {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.${mime.toString().split("/").last}"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                                      ..click();
                                  }

                                },
                                child: const Column(
                                  children: [
                                    Icon(
                                        Icons.download_for_offline,
                                        color: Colors.green
                                    ),
                                    Text("Download")
                                  ],
                                ),
                              ) :  Column(
                                children: [
                                  Icon(
                                    Icons.pending,
                                    color: Colors.red.shade300,
                                  ),
                                  Text("No File")
                                ],
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1.5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "Bank Passbook (Latest 6 months)",
                                  style: TextStyle(
                                    color:  Colors.black,
                                    fontFamily: StyleData.boldFont,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              (docData != null && docData.containsKey('Bank_PassBook')) ?
                              InkWell(
                                onTap: () async {
                                  print(docData);
                                  print("bjksjjjjjjjj");

                                  if (docData.containsKey(
                                      'Bank_PassBook')) {
                                    docId = docData['Bank_PassBook'].toString();
                                    // "${docData['Application_Form'].toString()}";
                                  }
                                  print(docId);
                                  // New Implementation
                                  var map = <String,
                                      dynamic>{};
                                  map['DocId'] = docId;
                                  map['LUSR'] = 'HomeFin';

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
                                  print(mime);
                                  if (docId.toString().contains(",")) {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.zip"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                                      ..click();
                                  } else {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.${mime.toString().split("/").last}"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                                      ..click();
                                  }

                                },
                                child: Column(
                                  children: [
                                    Icon(
                                        Icons.download_for_offline,
                                        color: Colors.green
                                    ),
                                    Text("Download")
                                  ],
                                ),
                              ) :  Column(
                                children: [
                                  Icon(
                                    Icons.pending,
                                    color: Colors.red.shade300,
                                  ),
                                  Text("No File")
                                ],
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1.5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "Date of Birth Proof",
                                  style: TextStyle(
                                    color:  Colors.black,
                                    fontFamily: StyleData.boldFont,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              (docData != null && docData.containsKey('Date_Of_Birth')) ?
                              InkWell(
                                onTap: () async {
                                  print(docData);
                                  print("bjksjjjjjjjj");

                                  if (docData.containsKey(
                                      'Date_Of_Birth')) {
                                    docId = docData['Date_Of_Birth'].toString();
                                    // "${docData['Application_Form'].toString()}";
                                  }
                                  print(docId);
                                  // New Implementation
                                  var map = <String,
                                      dynamic>{};
                                  map['DocId'] = docId;
                                  map['LUSR'] = 'HomeFin';

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
                                  print(mime);
                                  if (docId.toString().contains(",")) {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.zip"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                                      ..click();
                                  } else {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.${mime.toString().split("/").last}"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                                      ..click();
                                  }

                                },
                                child: Column(
                                  children: [
                                    Icon(
                                        Icons.download_for_offline,
                                        color: Colors.green
                                    ),
                                    Text("Download")
                                  ],
                                ),
                              ) :  Column(
                                children: [
                                  Icon(
                                    Icons.pending,
                                    color: Colors.red.shade300,
                                  ),
                                  Text("No File")
                                ],
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1.5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "Login Fee Cheque",
                                  style: TextStyle(
                                    color:  Colors.black,
                                    fontFamily: StyleData.boldFont,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              (docData != null && docData.containsKey('Login_Fee_Check')) ?
                              InkWell(
                                onTap: () async {
                                  print(docData);
                                  print("bjksjjjjjjjj");

                                  if (docData.containsKey(
                                      'Login_Fee_Check')) {
                                    docId = docData['Login_Fee_Check'].toString();
                                    // "${docData['Application_Form'].toString()}";
                                  }
                                  print(docId);
                                  // New Implementation
                                  var map = <String,
                                      dynamic>{};
                                  map['DocId'] = docId;
                                  map['LUSR'] = 'HomeFin';

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
                                  print(mime);
                                  if (docId.toString().contains(",")) {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.zip"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                                      ..click();
                                  } else {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.${mime.toString().split("/").last}"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                                      ..click();
                                  }

                                },
                                child: Column(
                                  children: [
                                    Icon(
                                        Icons.download_for_offline,
                                        color: Colors.green
                                    ),
                                    Text("Download")
                                  ],
                                ),
                              ) :  Column(
                                children: [
                                  Icon(
                                    Icons.pending,
                                    color: Colors.red.shade300,
                                  ),
                                  Text("No File")
                                ],
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1.5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "Passport Size Color Photograph",
                                  style: TextStyle(
                                    color:  Colors.black,
                                    fontFamily: StyleData.boldFont,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              (docData != null && docData.containsKey('Passport_Size_Photo')) ?
                              InkWell(
                                onTap: () async {
                                  print(docData);
                                  print("bjksjjjjjjjj");

                                  if (docData.containsKey(
                                      'Passport_Size_Photo')) {
                                    docId = docData['Passport_Size_Photo'].toString();
                                    // "${docData['Application_Form'].toString()}";
                                  }
                                  print(docId);
                                  // New Implementation
                                  var map = <String,
                                      dynamic>{};
                                  map['DocId'] = docId;
                                  map['LUSR'] = 'HomeFin';

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
                                  print(mime);
                                  if (docId.toString().contains(",")) {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.zip"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                                      ..click();
                                  } else {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.${mime.toString().split("/").last}"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                                      ..click();
                                  }

                                },
                                child: Column(
                                  children: [
                                    Icon(
                                        Icons.download_for_offline,
                                        color: Colors.green
                                    ),
                                    Text("Download")
                                  ],
                                ),
                              ) :  Column(
                                children: [
                                  Icon(
                                    Icons.pending,
                                    color: Colors.red.shade300,
                                  ),
                                  Text("No File")
                                ],
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1.5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "Photo ID Proof",
                                  style: TextStyle(
                                    color:  Colors.black,
                                    fontFamily: StyleData.boldFont,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              (docData != null && docData.containsKey('Photo_Id_Proof')) ?
                              InkWell(
                                onTap: () async {
                                  print(docData);
                                  print("bjksjjjjjjjj");

                                  if (docData.containsKey(
                                      'Photo_Id_Proof')) {
                                    docId = docData['Photo_Id_Proof'].toString();
                                    // "${docData['Application_Form'].toString()}";
                                  }
                                  print(docId);
                                  // New Implementation
                                  var map = <String,
                                      dynamic>{};
                                  map['DocId'] = docId;
                                  map['LUSR'] = 'HomeFin';

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
                                  print(mime);
                                  if (docId.toString().contains(",")) {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.zip"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                                      ..click();
                                  } else {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.${mime.toString().split("/").last}"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                                      ..click();
                                  }

                                },
                                child: Column(
                                  children: [
                                    Icon(
                                        Icons.download_for_offline,
                                        color: Colors.green
                                    ),
                                    Text("Download")
                                  ],
                                ),
                              ) :  Column(
                                children: [
                                  Icon(
                                    Icons.pending,
                                    color: Colors.red.shade300,
                                  ),
                                  Text("No File")
                                ],
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1.5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "Residence Proof",
                                  style: TextStyle(
                                    color:  Colors.black,
                                    fontFamily: StyleData.boldFont,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              (docData != null && docData.containsKey('Residence_Proof')) ?
                              InkWell(
                                onTap: () async {
                                  print(docData);
                                  print("bjksjjjjjjjj");

                                  if (docData.containsKey(
                                      'Residence_Proof')) {
                                    docId = docData['Residence_Proof'].toString();
                                    // "${docData['Application_Form'].toString()}";
                                  }
                                  print(docId);
                                  // New Implementation
                                  var map = <String,
                                      dynamic>{};
                                  map['DocId'] = docId;
                                  map['LUSR'] = 'HomeFin';

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
                                  print(mime);
                                  if (docId.toString().contains(",")) {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.zip"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                                      ..click();
                                  } else {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.${mime.toString().split("/").last}"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                                      ..click();
                                  }

                                },
                                child: Column(
                                  children: [
                                    Icon(
                                        Icons.download_for_offline,
                                        color: Colors.green
                                    ),
                                    Text("Download")
                                  ],
                                ),
                              ) :  Column(
                                children: [
                                  Icon(
                                    Icons.pending,
                                    color: Colors.red.shade300,
                                  ),
                                  Text("No File")
                                ],
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1.5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "Salary Slip 3 Month",
                                  style: TextStyle(
                                    color:  Colors.black,
                                    fontFamily: StyleData.boldFont,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              (docData != null && docData.containsKey('Salary_Slip')) ?
                              InkWell(
                                onTap: () async {
                                  print(docData);
                                  print("bjksjjjjjjjj");

                                  if (docData.containsKey(
                                      'Salary_Slip')) {
                                    docId = docData['Salary_Slip'].toString();
                                    // "${docData['Application_Form'].toString()}";
                                  }
                                  print(docId);
                                  // New Implementation
                                  var map = <String,
                                      dynamic>{};
                                  map['DocId'] = docId;
                                  map['LUSR'] = 'HomeFin';

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
                                  print(mime);
                                  if (docId.toString().contains(",")) {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.zip"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                                      ..click();
                                  } else {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.${mime.toString().split("/").last}"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                                      ..click();
                                  }

                                },
                                child: Column(
                                  children: [
                                    Icon(
                                        Icons.download_for_offline,
                                        color: Colors.green
                                    ),
                                    Text("Download")
                                  ],
                                ),
                              ) :  Column(
                                children: [
                                  Icon(
                                    Icons.pending,
                                    color: Colors.red.shade300,
                                  ),
                                  Text("No File")
                                ],
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1.5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  "Signature Proof",
                                  style: TextStyle(
                                    color:  Colors.black,
                                    fontFamily: StyleData.boldFont,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              (docData != null && docData.containsKey('Signature_Proof')) ?
                              InkWell(
                                onTap: () async {
                                  print(docData);
                                  print("bjksjjjjjjjj");

                                  if (docData.containsKey(
                                      'Signature_Proof')) {
                                    docId = docData['Signature_Proof'].toString();
                                    // "${docData['Application_Form'].toString()}";
                                  }
                                  print(docId);
                                  // New Implementation
                                  var map = <String,
                                      dynamic>{};
                                  map['DocId'] = docId;
                                  map['LUSR'] = 'HomeFin';

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
                                  print(mime);
                                  if (docId.toString().contains(",")) {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.zip"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                                      ..click();
                                  } else {
                                    AnchorElement(
                                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                      ..setAttribute(
                                          "download",
                                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                                              ? "${docData['LeadID']}.${mime.toString().split("/").last}"
                                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                                      ..click();
                                  }

                                },
                                child: Column(
                                  children: [
                                    Icon(
                                        Icons.download_for_offline,
                                        color: Colors.green
                                    ),
                                    Text("Download")
                                  ],
                                ),
                              ) :  Column(
                                children: [
                                  Icon(
                                    Icons.pending,
                                    color: Colors.red.shade300,
                                  ),
                                  Text("No File")
                                ],
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                            thickness: 1.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      )
      ),
    );
  }


  // buildListItem('Application Form'),
  // buildListItem('Bank Passbook (Latest 6 months)'),
  // buildListItem('Date of Birth Proof'),
  // buildListItem('Login Fee Cheque'),
  // buildListItem('Passport Size Color Photograph'),
  // buildListItem('Photo ID Proof'),
  // buildListItem('Residence Proof'),
  // buildListItem('Salary Slip 3 Month'),
  // buildListItem('Signature Proof'),
  Widget buildListItem(String text) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              InkWell(
                onTap: () async {
                  print(docData);
                  print("bjksjjjjjjjj");
                  if (docData.containsKey(
                      'Application_Form')) {
                    docId = docData['Application_Form'].toString();
                    // "${docData['Application_Form'].toString()}";
                  }
                    print(docId);
                  if (docData["Bank_PassBook"]) {
                    docId =
                    "$docId,${docData["Bank_PassBook"]}";
                  }
                  // if (data.containsKey(
                  //     'Date_Of_Birth')) {
                  //   docId =
                  //   "$docId,${data['Date_Of_Birth'].toString()}";
                  // }
                  // if (data.containsKey(
                  //     'Login_Fee_Check')) {
                  //   docId =
                  //   "$docId,${data['Login_Fee_Check'].toString()}";
                  // }
                  // if (data.containsKey(
                  //     'Passport_Size_Photo')) {
                  //   docId =
                  //   "$docId,${data['Passport_Size_Photo'].toString()}";
                  // }
                  // if (data.containsKey(
                  //     'Photo_Id_Proof')) {
                  //   docId =
                  //   "$docId,${data['Photo_Id_Proof'].toString()}";
                  // }
                  // if (data.containsKey(
                  //     'Residence_Proof')) {
                  //   docId =
                  //   "$docId,${data['Residence_Proof'].toString()}";
                  // }
                  // if (data.containsKey(
                  //     'Salary_Slip')) {
                  //   docId =
                  //   "$docId,${data['Salary_Slip'].toString()}";
                  // }
                  // if (data.containsKey(
                  //     'Signature_Proof')) {
                  //   docId =
                  //   "$docId,${data['Signature_Proof'].toString()}";
                  // }
                  // if (data.containsKey(
                  //     'Copy_Of_Property')) {
                  //   docId =
                  //   "$docId,${data['Copy_Of_Property'].toString()}";
                  // }
                  // if (data.containsKey(
                  //     'Total_Work_Experience')) {
                  //   docId =
                  //   "$docId,${data['Total_Work_Experience'].toString()}";
                  // }
                  // if (data.containsKey(
                  //     'Work_Experience')) {
                  //   docId =
                  //   "$docId,${data['Work_Experience'].toString()}";
                  // }
                  print(docId);
                  // New Implementation

                  var map = <String,
                      dynamic>{};
                  map['DocId'] = docId;
                  map['LUSR'] = 'HomeFin';

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
                  print(mime);
                  if (docId.toString().contains(",")) {
                    AnchorElement(
                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                      ..setAttribute(
                          "download",
                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                              ? "${docData['LeadID']}.zip"
                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                      ..click();
                  } else {
                    AnchorElement(
                        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                      ..setAttribute(
                          "download",
                          (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
                              ? "${docData['LeadID']}.${mime.toString().split("/").last}"
                              : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                      ..click();
                  }

                },
                child: Icon(
                    Icons.download_for_offline,
                    color: Colors.red.shade300
                ),
              ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }


}
