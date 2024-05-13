

import 'dart:convert';
import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homefin_express_web/HomePageView.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import '../Utils/StyleData.dart';

class DocumentPageView extends StatefulWidget {
  final String docId;
  final String leadID;
  const DocumentPageView({Key? key,
    required this.docId, required this.leadID})
      : super(key: key);

  @override
  State<DocumentPageView> createState() => _DocumentPageViewState();
}

class _DocumentPageViewState extends State<DocumentPageView> {
  bool isVerification = false;
  String? docId;
  bool downloading = false;

  TextEditingController queryReason = TextEditingController();

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
  String? verificationStatus;
  String? verifiedBy;
  String? Query;
  bool? QueryStatus;
  String? QueryUpdatedByRO;
  var docData;
  Map<String, dynamic> filteredData = {};

  void fetchData() async {
    print("KEYVALUE");
    try {
      if (widget.leadID != null) {
        CollectionReference users = FirebaseFirestore.instance.collection('convertedLeads');
        QuerySnapshot snapshot = await users.where("LeadID", isEqualTo: widget.leadID).get();
        if (snapshot.docs.isNotEmpty) {
          setState(() {
            docData = snapshot.docs.first.data();
          });

          ApplicantFirstName = docData["firstName"] ?? "";
          LeadID = docData["LeadID"] ?? "";
          ApplicantLastName = docData["lastName"] ?? "";
          CustomerNumber = docData["customerNumber"] ?? "";
          DateOfBirth = docData["dateOfBirth"] ?? "";
          Gender = docData["gender"] ?? "";
          HomeFinBranchCode = docData["homeFinBranchCode"] ?? "";
          LeadAmount = docData["leadAmount"] ?? "";
          LeadSource = docData["leadSource"] ?? "";
          panCardNumber = docData["panCardNumber"] ?? "";
          aadharNumber = docData["aadharNumber"] ?? "";
          verificationStatus = docData["VerificationStatus"] ?? "";
          verifiedBy = docData["VerifiedBy"] ?? "";
          Query = docData["Query"] ?? "";
          QueryStatus = docData["isQuery"];
          QueryUpdatedByRO = docData["QueryBy"] ?? "";

          docData.forEach((key, value) {
            print("jhfvjsf");
            List<String> parts = key.split("-");
            if (parts.isNotEmpty && parts.last == "checklist") {
              filteredData[key] = value;
            }
          });
        } else {
          print("LeadID does not exist in the database.");
        }
      } else {
        // Handle the case where widget.leadID is null
        print("widget.leadID is null.");
      }
    } catch (e) {
      print("An error occurred: $e");
      // Handle the error here
    }
  }



  // void fetchdata() async {
  //   CollectionReference users =
  //   FirebaseFirestore.instance.collection('convertedLeads');
  //   users.doc(widget.docId).get().then((value) async {
  //     setState(() {
  //       docData = value.data();
  //     });
  //     ApplicantFirstName = docData["firstName"] ?? "";
  //     LeadID  = docData["LeadID"] ?? "";
  //     ApplicantLastName = docData["lastName"] ?? "";
  //     CustomerNumber = docData["customerNumber"] ?? "";
  //     DateOfBirth = docData["dateOfBirth"] ?? "";
  //     Gender = docData["gender"] ?? "";
  //     HomeFinBranchCode = docData["homeFinBranchCode"] ?? "";
  //     LeadAmount = docData["leadAmount"] ?? "";
  //     LeadSource = docData["leadSource"] ?? "";
  //     panCardNumber = docData["panCardNumber"] ?? "";
  //     aadharNumber = docData["aadharNumber"] ?? "";
  //     verificationStatus = docData["VerificationStatus"] ?? "";
  //     Query = docData["Query"] ?? "";
  //     QueryStatus = docData["isQuery"] ?? "";
  //     QueryUpdatedByRO = docData["QueryBy"] ?? "";
  //     //  print(_leadSource.text);
  //     print(ApplicantFirstName);
  //     print(LeadID);
  //
  //
  //     // Using for Technical Checklist
  //
  //     docData.forEach((key, value) {
  //       List<String> parts = key.split("-");
  //       if (parts.isNotEmpty && parts.last == "checklist") {
  //         filteredData[key] = value;
  //       }
  //     });
  //
  //   });
  //
  // }

  String? selectedDoc;

  // bool isVerified = false;
  bool isQuery = false;

  void UpdatedVerificationStatus() async {
    try {
      // Reference to the documents in the "convertedLeads" collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('convertedLeads')
          .where('LeadID', isEqualTo: widget.leadID)
          .get();

      // Check if documents exist
      if (querySnapshot.docs.isNotEmpty) {
        // Update each document with the new field and value
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.update({
            'VerificationStatus': 'Sent for Verification',
            'VerifiedBy': 'Verified By SM',
          });
        });

        // setState(() {
        //   isVerified = true;
        // });
        _showAlertDialogSuccess(context);
        print('Documents updated successfully');
      } else {
        // Handle the case where no document with the specified LeadID is found
        print('No document found with LeadID: ${widget.leadID}');
      }
    } catch (e) {
      print('Error updating document: $e');
    }
  }


  // void UpdatedVerificationStatus() async {
  //   try {
  //     // Reference to the document in the "convertedLeads" collection
  //     DocumentReference docRef = FirebaseFirestore.instance.collection('convertedLeads').doc(widget.docId);
  //
  //     // Update the document with the new field and value
  //     await docRef.update({
  //       'VerificationStatus': 'Sent for Verification',
  //       'VerifiedBy': 'Verified By SM',
  //     });
  //     setState(() {
  //       isVerified = true;
  //     });
  //     _showAlertDialogSuccess(context);
  //     print('Document updated successfully');
  //
  //   } catch (e) {
  //     print('Error updating document: $e');
  //   }
  // }

  // void UpdatedQueryStatus() async {
  //   try {
  //     DocumentReference docRef = FirebaseFirestore.instance.collection('convertedLeads').doc(widget.docId);
  //     await docRef.update({
  //       'Query': queryReason.text,
  //       'isQuery': true,
  //       'QueryBy': 'Query By SM',
  //     });
  //     setState(() {
  //       isQuery = true;
  //     });
  //     _showAlertDialogSuccess1(context);
  //     print('Query updated successfully');
  //   } catch (e) {
  //     print('Error updating document: $e');
  //   }
  // }
  void UpdatedQueryStatus() async {
    try {
      // Reference to the documents in the "convertedLeads" collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('convertedLeads')
          .where('LeadID', isEqualTo: widget.leadID)
          .get();

      // Check if documents exist
      if (querySnapshot.docs.isNotEmpty) {
        // Update each document with the new field and value
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.update({
            'Query': queryReason.text,
            'isQuery': true,
            'QueryBy': 'Query By SM',
            'VerificationStatus': 'Pending',
          });
        });

        setState(() {
          isQuery = true;
        });
        _showAlertDialogSuccess1(context);
        print('Query updated successfully');
      } else {
        // Handle the case where no document with the specified LeadID is found
        print('No document found with LeadID: ${widget.leadID}');
      }
    } catch (e) {
      print('Error updating document: $e');
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    color: Colors.white,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width * 0.3,
                          child: Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                                border: Border.all(color: Colors.black12), // Grey border
                              ),
                              child: Card(
                                elevation: 1, // No elevation
                                margin: EdgeInsets.all(0), // No margin
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                                ),
                                child: Container(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Lead ID: ",
                                              style: TextStyle(color: Colors.black87, fontSize: 16, fontFamily: StyleData.boldFont),
                                            ),
                                            Text(
                                              LeadID ?? "",
                                              style: TextStyle(color: StyleData.appBarColor2, fontSize: 16, fontFamily: StyleData.boldFont),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              "Applicant Name: ",
                                              style: TextStyle(color: Colors.black38, fontSize: 13),
                                            ),
                                            Text(
                                              ((ApplicantFirstName ?? '') + ' ' + (ApplicantLastName ?? '')) ?? "",
                                              style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: StyleData.boldFont),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              "Mobile Number: ",
                                              style: TextStyle(color: Colors.black38, fontSize: 13),
                                            ),
                                            Text(
                                              CustomerNumber ?? "",
                                              style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: StyleData.boldFont),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              "Date Of Birth: ",
                                              style: TextStyle(color: Colors.black38, fontSize: 13),
                                            ),
                                            Text(
                                              DateOfBirth ?? "",
                                              style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: StyleData.boldFont),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              "PAN Number: ",
                                              style: TextStyle(color: Colors.black38, fontSize: 13),
                                            ),
                                            Text(
                                              panCardNumber ?? "",
                                              style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: StyleData.boldFont),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              "Aadhar Number: ",
                                              style: TextStyle(color: Colors.black38, fontSize: 13),
                                            ),
                                            Text(
                                              aadharNumber ?? "",
                                              style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: StyleData.boldFont),
                                            ),
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
                        SizedBox(width: width * 0.4),
                        Column(
                          children: [
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    (verificationStatus == 'Sent for Verification' &&  verifiedBy == 'Verified By SM') ? "" : UpdatedVerificationStatus();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: verifiedBy == 'Verified By SM' ? Colors.green[500] : Colors.green[500],
                                  ),
                                  child: Text(
                                    verifiedBy == 'Verified By SM' ? 'Verified' : 'Verify',
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: StyleData.boldFont),
                                  ),
                                ),
                                SizedBox(
                                  width: width * 0.02,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    verifiedBy == 'Verified By SM' ? "" :
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: Text("Query",style: TextStyle(color: StyleData.appBarColor3),),
                                          contentPadding: EdgeInsets.all(16), // Set fixed padding
                                          content: SizedBox(
                                            width: 400, // Set fixed width
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  controller: queryReason,
                                                  decoration: InputDecoration(
                                                    hintText: "Enter your query here",
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.black12
                                                        )
                                                    ), // Add border to text field
                                                  ),
                                                  maxLines: 3, // Adjust the number of lines as needed
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                              child: Text("Cancel"),
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.grey,
                                                onPrimary: Colors.white, // Set text color to white
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                UpdatedQueryStatus();
                                              },
                                              child: Text("Submit"),
                                              style: ElevatedButton.styleFrom(
                                                primary: StyleData.buttonColor,
                                                onPrimary: Colors.white, // Set text color to white
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: StyleData.buttonColor,
                                  ),
                                  child: Text(
                                    'Query',
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: StyleData.boldFont),
                                  ),
                                ),
                                SizedBox(
                                  width: width * 0.02,
                                ),
                                Visibility(
                                  visible: QueryUpdatedByRO == 'Updated',
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.orange,
                                    ),
                                    onPressed: () {  },
                                    child: Text(
                                      'Updated',
                                      style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: StyleData.boldFont),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height : height * 0.05
                            ),
                            // Query != null
                            //     ? SizedBox(
                            //   width: width * 0.25,
                            //   child: Container(
                            //     decoration: BoxDecoration(
                            //       color: Colors.white,
                            //       borderRadius: BorderRadius.circular(8.0), // Rounded corners
                            //       border: Border.all(color: Colors.black), // Grey border
                            //     ),
                            //     child: Card(
                            //       elevation: 1, // No elevation
                            //       margin: EdgeInsets.all(0), // No margin
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(8.0), // Rounded corners
                            //       ),
                            //       child: Container(
                            //         color: Colors.white,
                            //         child: Padding(
                            //           padding: const EdgeInsets.all(8.0),
                            //           child: Row(
                            //             crossAxisAlignment: CrossAxisAlignment.start,
                            //             children: [
                            //               Text(
                            //                 "Query: ",
                            //                 style: TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.bold),
                            //               ),
                            //               Flexible( // Wrap the Text widget in a Flexible widget
                            //                 child: Text(
                            //                   Query ?? "",
                            //                   style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: StyleData.boldFont),
                            //                 ),
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // )
                            //     : SizedBox.shrink(),



                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: width * 0.035,
                        ),
                        Card(
                          elevation: 3,
                          child: Container(
                            height: height * 0.85,
                            width: width * 0.45,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Mandatory Documents",
                                    style: TextStyle(
                                      color:  StyleData.appBarColor2,
                                      fontFamily: StyleData.boldFont,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Table(
                                    border: TableBorder.all(color: Colors.grey),
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Application Form",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: StyleData.boldFont,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                                (docData != null && docData.containsKey('Application_Form'))
                                                    ? InkWell(
                                                  onTap: () async {
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
                                                    if (docData.containsKey('Application_Form')) {
                                                      docId = docData['Application_Form'].toString();
                                                      // "${docData['Application_Form'].toString()}";
                                                    }
                                                    print(docId);
                                                    // New Implementation
                                                    var map = <String, dynamic>{};
                                                    map['DocId'] = docId;
                                                    map['LUSR'] = 'HomeFin';
                    
                                                    http.Response response = await http.post(
                                                      Uri.parse(
                                                          "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
                                                      body: map,
                                                    );
                                                    final data1 = response.bodyBytes;
                                                    final mime =
                                                    lookupMimeType('', headerBytes: data1);
                                                    // print(mime);
                                                    if (docId.toString().contains(",")) {
                                                      AnchorElement(
                                                          href:
                                                          "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                                        ..setAttribute(
                                                            "download",
                                                            (docData['LeadID'] != null &&
                                                                docData['LeadID'].isNotEmpty)
                                                                ? "${docData['LeadID']}.zip"
                                                                : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                                                        ..click();
                                                    } else {
                                                      AnchorElement(
                                                          href:
                                                          "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                                        ..setAttribute(
                                                            "download",
                                                            (docData['LeadID'] != null &&
                                                                docData['LeadID'].isNotEmpty)
                                                                ? "${docData['LeadID']}.${mime.toString().split("/").last}"
                                                                : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                                                        ..click();
                                                    }
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.download_for_offline,
                                                        color: Colors.green,
                                                      ),
                                                      Text("Download")
                                                    ],
                                                  ),
                                                )
                                                    : Column(
                                                  children: [
                                                    Icon(
                                                      Icons.pending,
                                                      color: Colors.red.shade300,
                                                    ),
                                                    Text("No File")
                                                  ],
                                                ),
                                                // ElevatedButton(
                                                //   onPressed: () {
                                                //     if (verificationStatus != 'Verified') {
                                                //       verificationStatus == 'Verified' ? "" : UpdatedVerificationStatus();
                                                //     }
                                                //   },
                                                //   style: ElevatedButton.styleFrom(
                                                //     primary: verificationStatus == 'Verified' ? Colors.green[500] : Colors.green[500],
                                                //   ),
                                                //   child: Text(
                                                //      'Verify',
                                                //     style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: StyleData.boldFont),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                          // Second cell content
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Bank Passbook (Latest 6 months)",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: StyleData.boldFont,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                                (docData != null && docData.containsKey('Bank_Passbook'))
                                                    ? InkWell(
                                                  onTap: () async {
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
                                                    if (docData.containsKey('Bank_Passbook')) {
                                                      docId = docData['Bank_Passbook'].toString();
                                                      // "${docData['Application_Form'].toString()}";
                                                    }
                                                    print(docId);
                                                    // New Implementation
                                                    var map = <String, dynamic>{};
                                                    map['DocId'] = docId;
                                                    map['LUSR'] = 'HomeFin';
                    
                                                    http.Response response = await http.post(
                                                      Uri.parse(
                                                          "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
                                                      body: map,
                                                    );
                                                    final data1 = response.bodyBytes;
                                                    final mime =
                                                    lookupMimeType('', headerBytes: data1);
                                                    // print(mime);
                                                    if (docId.toString().contains(",")) {
                                                      AnchorElement(
                                                          href:
                                                          "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                                        ..setAttribute(
                                                            "download",
                                                            (docData['LeadID'] != null &&
                                                                docData['LeadID'].isNotEmpty)
                                                                ? "${docData['LeadID']}.zip"
                                                                : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                                                        ..click();
                                                    } else {
                                                      AnchorElement(
                                                          href:
                                                          "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                                        ..setAttribute(
                                                            "download",
                                                            (docData['LeadID'] != null &&
                                                                docData['LeadID'].isNotEmpty)
                                                                ? "${docData['LeadID']}.${mime.toString().split("/").last}"
                                                                : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                                                        ..click();
                                                    }
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.download_for_offline,
                                                        color: Colors.green,
                                                      ),
                                                      Text("Download")
                                                    ],
                                                  ),
                                                )
                                                    : Column(
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
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Table(
                                    border: TableBorder.all(color: Colors.grey),
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:  Row(
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
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
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
                                                    // print(mime);
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
                                          ),
                                          // Second cell content
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:  Row(
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
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
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
                                                    // print(mime);
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
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Table(
                                    border: TableBorder.all(color: Colors.grey),
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:  Row(
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
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
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
                                                    // print(mime);
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
                                          ),
                                          // Second cell content
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:  Row(
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
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
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
                                                    // print(mime);
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
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Table(
                                    border: TableBorder.all(color: Colors.grey),
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:  Row(
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
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
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
                                                    // print(mime);
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
                                          ),
                                          // Second cell content
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:  Row(
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
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
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
                                                    // print(mime);
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
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Table(
                                    border: TableBorder.all(color: Colors.grey),
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:     Row(
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
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
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
                                                    // print(mime);
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
                                          ),
                                          // Second cell content
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:  Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "Optional Documents",
                                    style: TextStyle(
                                      color:  StyleData.appBarColor2,
                                      fontFamily: StyleData.boldFont,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Table(
                                    border: TableBorder.all(color: Colors.grey),
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:  Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Copy Of Property",
                                                    style: TextStyle(
                                                      color:  Colors.black,
                                                      fontFamily: StyleData.boldFont,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                                (docData != null && docData.containsKey('Copy_Of_Property')) ?
                                                InkWell(
                                                  onTap: () async {
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
                                                    if (docData.containsKey(
                                                        'Copy_Of_Property')) {
                                                      docId = docData['Copy_Of_Property'].toString();
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
                                                    // print(mime);
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
                                          ),
                                          // Second cell content
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Total Work Experience",
                                                    style: TextStyle(
                                                      color:  Colors.black,
                                                      fontFamily: StyleData.boldFont,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                                (docData != null && docData.containsKey('Total_Work_Experience')) ?
                                                InkWell(
                                                  onTap: () async {
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
                                                    if (docData.containsKey(
                                                        'Total_Work_Experience')) {
                                                      docId = docData['Total_Work_Experience'].toString();
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
                                                    // print(mime);
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
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Table(
                                    border: TableBorder.all(color: Colors.grey),
                                    children: [
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:    Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Work Experience",
                                                    style: TextStyle(
                                                      color:  Colors.black,
                                                      fontFamily: StyleData.boldFont,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                                (docData != null && docData.containsKey('Work_Experience')) ?
                                                InkWell(
                                                  onTap: () async {
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
                                                    if (docData.containsKey(
                                                        'Work_Experience')) {
                                                      docId = docData['Work_Experience'].toString();
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
                                                    // print(mime);
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
                                          ),
                                          // Second cell content
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:  Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Qualification Proof",
                                                    style: TextStyle(
                                                      color:  Colors.black,
                                                      fontFamily: StyleData.boldFont,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                                (docData != null && docData.containsKey('Qualification_Proof')) ?
                                                InkWell(
                                                  onTap: () async {
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
                                                    if (docData.containsKey(
                                                        'Qualification_Proof')) {
                                                      docId = docData['Qualification_Proof'].toString();
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
                                                    // print(mime);
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
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            width: width * 0.001,
                        ),
                        Card(
                          elevation: 3,
                          child: Container(
                            height: height * 0.85,
                            width: width * 0.45,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Technical Checklist",
                                    style: TextStyle(
                                      color:  StyleData.appBarColor2,
                                      fontFamily: StyleData.boldFont,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Expanded(
                                    child : GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 0,
                                        crossAxisSpacing: 0,
                                        childAspectRatio: 3.0, // Adjust aspect ratio to give more space to keys
                                      ),
                                      itemCount: filteredData.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        var key = filteredData.keys.toList()[index];
                                        var value = filteredData[key];
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    key,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontFamily: StyleData.boldFont,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                                // Text(value.toString()),
                                                InkWell(
                                                  onTap: () async {
                                                    // print(docData);
                                                    // print("bjksjjjjjjjj");
                    
                                                    // if (docData.containsKey('Bank_Passbook')) {
                                                    //   docId = docData['Bank_Passbook'].toString();
                                                    //   // "${docData['Application_Form'].toString()}";
                                                    // }
                                                    docId = value.toString();
                                                    print(docId);
                                                    // New Implementation
                                                    var map = <String, dynamic>{};
                                                    map['DocId'] = docId;
                                                    map['LUSR'] = 'HomeFin';
                    
                                                    http.Response response = await http.post(
                                                      Uri.parse(
                                                          "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
                                                      body: map,
                                                    );
                                                    final data1 = response.bodyBytes;
                                                    final mime =
                                                    lookupMimeType('', headerBytes: data1);
                                                    // print(mime);
                                                    if (docId.toString().contains(",")) {
                                                      AnchorElement(
                                                          href:
                                                          "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                                        ..setAttribute(
                                                            "download",
                                                            (docData['LeadID'] != null &&
                                                                docData['LeadID'].isNotEmpty)
                                                                ? "${docData['LeadID']}.zip"
                                                                : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
                                                        ..click();
                                                    } else {
                                                      AnchorElement(
                                                          href:
                                                          "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
                                                        ..setAttribute(
                                                            "download",
                                                            (docData['LeadID'] != null &&
                                                                docData['LeadID'].isNotEmpty)
                                                                ? "${docData['LeadID']}.${mime.toString().split("/").last}"
                                                                : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
                                                        ..click();
                                                    }
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.download_for_offline,
                                                        color: Colors.green,
                                                      ),
                                                      Text("Download")
                                                    ],
                                                  ),
                                                )// Assuming value is a string, adjust accordingly
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: width * 0.1,
              ),
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Query",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                            color: StyleData.appBarColor2
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        '$Query',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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
                  // print(docData);
                  // print("bjksjjjjjjjj");
                  if (docData.containsKey(
                      'Application_Form')) {
                    docId = docData['Application_Form'].toString();
                    // "${docData['Application_Form'].toString()}";
                  }
                    print(docId);
                  if (docData["Bank_Passbook"]) {
                    docId =
                    "$docId,${docData["Bank_Passbook"]}";
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
                  // print(mime);
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

  void _showAlertDialogSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: Colors.white,
            elevation: 0, // No shadow
            content: Container(
              height:190,
              width: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child:
                    Container(
                      height: 80,
                      width: 60,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle
                      ),
                      child: Center(
                        child: Icon(Icons.done,color: Colors.white,),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Verification completed successfully ', textAlign: TextAlign.center,style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold)),
                  //  SizedBox(height: 8),

                  SizedBox(height: 5),
                  SizedBox(
                    height: 25,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomePageView(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAlertDialogSuccess1(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: Colors.white,
            elevation: 0, // No shadow
            content: Container(
              height:190,
              width: 200,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child:
                    Container(
                      height: 80,
                      width: 60,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle
                      ),
                      child: Center(
                        child: Icon(Icons.done,color: Colors.white,),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Query Sent ', textAlign: TextAlign.center,style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold)),
                  //  SizedBox(height: 8),

                  SizedBox(height: 5),
                  SizedBox(
                    height: 25,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomePageView(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
