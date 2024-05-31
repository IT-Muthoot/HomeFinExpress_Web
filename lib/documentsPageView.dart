

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
  final String token;
  const DocumentPageView({Key? key,
    required this.docId, required this.leadID, required this.token,})
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
  List<Map<String, dynamic>> documents = [];
  bool isQueryEntered = false;




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
            List<String> parts = key.split("-");
            if (parts.isNotEmpty && parts.last == "checklist") {
              filteredData[key] = value;
            }
            // Include additional keys here
            if ([
              "Application_Form",
              "Bank_Passbook",
              "Date_Of_Birth",
              "Login_Fee_Check",
              "Passport_Size_Photo",
              "Photo_Id_Proof",
              "Residence_Proof",
              "Salary_Slip",
              "Signature_Proof",
              "Copy_Of_Property",
              "Total_Work_Experience",
              "Qualification_Proof"
            ].contains(key)) {
              filteredData[key] = value;
            }
          });

          // documents = filteredData.keys.map((key) {
          //   return {
          //     'title': key.replaceAll("_", " "),
          //     'key': key,
          //     'isChecked': false,
          //     'queryController': TextEditingController(),
          //   };
          // }).toList();

          documents = filteredData.keys.map((key) {
            TextEditingController controller = TextEditingController();
            bool isChecked = false;
            String query = '';

            if (docData['Documents'] != null) {
              var documentList = docData['Documents'] as List<dynamic>;
              var matchingDoc = documentList.firstWhere(
                    (doc) => doc['key'] == key,
                orElse: () => null,
              );

              if (matchingDoc != null) {
                isChecked = matchingDoc['isChecked'] ?? false;
                query = matchingDoc['query'] ?? '';
                controller.text = query;
              }
            }

            return {
              'title': key.replaceAll("_", " "),
              'key': key,
              'isChecked': isChecked,
              'queryController': controller,
            };
          }).toList();

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

  Future<void> downloadDocument(String docId, String leadID) async {
    var map = <String, dynamic>{};
    map['DocId'] = docId;
    map['LUSR'] = 'HomeFin';

    http.Response response = await http.post(
      Uri.parse("https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
      body: map,
    );
    final data1 = response.bodyBytes;
    final mime = lookupMimeType('', headerBytes: data1);
    AnchorElement(
      href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}",
    )
      ..setAttribute(
        "download",
        (leadID.isNotEmpty)
            ? "$leadID.${mime?.split("/").last ?? 'file'}"
            : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now())}.${mime?.split("/").last ?? 'file'}",
      )
      ..click();
  }

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
            'Documents': documents.map((doc) => {
              'key': doc['key'],
              'isChecked': doc['isChecked'],
              'query': doc['queryController'].text,
            }).toList(),
          });
        });

        // setState(() {
        //   isVerified = true;
        // });
        sendNotificationToDevice1(FCMServerKey,widget.token);
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

  List<String> queryTexts = [];
  List<String> documentNames = [];
  Map<String, String> queryTextByDocumentName = {};
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
        //   await doc.reference.update({
        //     'QueryBy': 'Query By SM',
        //     'VerificationStatus': 'Push Back',
        //     'Documents': documents.map((doc) => {
        //       'key': doc['key'],
        //       'isChecked': doc['isChecked'],
        //       'query': doc['queryController'].text,
        //     }).toList(),
        //   });
        // });
          List<Map<String, dynamic>>  updatedDocuments = documents.map((doc) {
            return {
              'key': doc['key'],
              'isChecked': doc['isChecked'],
              'query': doc['queryController'].text,
            };
          }).toList();

          // Create a map to clear specific fields
          Map<String, dynamic> clearFields = {};

          // Iterate through documents to identify fields to clear
          documents.forEach((doc) {
            if (doc['queryController'].text.isNotEmpty) {
              clearFields[doc['key']] = '';
              queryTextByDocumentName[doc['key']] = doc['queryController'].text;
            }
          });

          await doc.reference.update({
            'QueryBy': 'Query By SM',
            'VerificationStatus': 'Push Back',
            'Documents': updatedDocuments,
            ...clearFields,  // Use spread operator to include clearFields
          });
        });

        setState(() {
          isQuery = true;
        });
        _showAlertDialogSuccess1(context);
        sendNotificationToDevice(FCMServerKey,widget.token, queryTextByDocumentName);
        print('Query updated successfully');
      } else {
        // Handle the case where no document with the specified LeadID is found
        print('No document found with LeadID: ${widget.leadID}');
      }
    } catch (e) {
      print('Error updating document: $e');
    }
  }

 // String FCMTOken = "dtC7SAuDRMS3faHIXwuD_8:APA91bEFq-NPddhhT0h5JuYGQykJq-pDX6PDOaxVzhNDvAhgahl9U6FgaOBCGtxJjlyRF-D3N_s1jXrefcLsZVpgJJC2ydjGr7abnkrU0HbnycQKJpjqHi1FxLEDj5mojqyxNXkdxMJH";
  String FCMServerKey = "AAAAvnuEuSw:APA91bGhzDJBFD0fM8U5D-WRsSYWG9egY7sJX_sL6VnGZ7AC7wrrgC5WmUFIK7-GttG_U4VmLSQ4_TRJy-SDtWD-bABrmIKU7bdg604i3IUgk6zVj-k0elas3fwHN1vmUy6egG0-O4cj";

  void sendNotificationToDevice(String FCMServerKey, String FCMToken, Map<String, String> documentNames) async {
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // Convert the documentNames map to a readable string with each key-value pair on a new line
    String documentNamesString = documentNames.entries.map((e) => '${e.key}: ${e.value}').join('\n');

    // Define your notification message
    Map<String, dynamic> notification = {
      'notification': {
        'title': '"HomeFin Express" Verification Status Updated',
        'body': '${ApplicantFirstName! + ' ' + ApplicantLastName!} - Query By SM:\n$documentNamesString',
        'icon': "https://firebasestorage.googleapis.com/v0/b/lms-application-be1ea.appspot.com/o/ic_launcher.png?alt=media&token=c37f6227-036f-4ed9-b757-bd1dc0c27809",
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
      'priority': 'high',
      'data': {
        'title': '"HomeFin Express" Verification Status Updated',
        'body': '${ApplicantFirstName! + ' ' + ApplicantLastName!} - Query By SM:\n$documentNamesString',
        // Add any additional data you want to send with the notification
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'screen': 'NotificationPageView'
      },
      'to': FCMToken, // FCM token of the device you want to send the notification to
    };

    // Encode the notification message
    final String notificationJson = jsonEncode(notification);

    // Send HTTP POST request to FCM endpoint
    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$FCMServerKey', // Include FCM server key in Authorization header
      },
      body: notificationJson,
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Error: ${response.body}');
    }
  }




  void sendNotificationToDevice1(String FCMServerKey, String FCMTOken,) async {
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    Map<String, dynamic> notification = {
      'notification': {
        'title': '"HomeFin Express" Verification Status Updated',
        'body': ApplicantFirstName! + ' ' + ApplicantLastName! +" - " + "Verification Completed By SM",
        'icon': "https://firebasestorage.googleapis.com/v0/b/lms-application-be1ea.appspot.com/o/ic_launcher.png?alt=media&token=c37f6227-036f-4ed9-b757-bd1dc0c27809",
        'click_action': 'FLUTTER_NOTIFICATION_CLICK'
      },
      'priority': 'high',
      'data': {
        'title': '"HomeFin Express" Verification Status Updated',
        'body': ApplicantFirstName! + ' ' + ApplicantLastName! +" - " + "Verification Completed By SM",
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'screen': 'NotificationPageView'
        // Add any additional data you want to send with the notification
      },
      'to': FCMTOken, // FCM token of the device you want to send the notification to
    };

    // Encode the notification message
    final String notificationJson = jsonEncode(notification);

    // Send HTTP POST request to FCM endpoint
    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$FCMServerKey', // Include FCM server key in Authorization header
      },
      body: notificationJson,
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Error: ${response.body}');
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
                        SizedBox(width: width * 0.4),
                        Column(
                          children: [
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    bool allDocumentsChecked = true;
                                    for (var doc in documents) {
                                      if (doc['isChecked'] != true) {
                                        allDocumentsChecked = false;
                                        break;
                                      }
                                    }
    if (allDocumentsChecked) {
    if ((verificationStatus == 'Sent for Verification' || verificationStatus == 'Verified' || verificationStatus == 'Push Back' ) &&
    (verifiedBy == 'Verified By SM' || verifiedBy == 'Verified By CM')) {

    } else {
    UpdatedVerificationStatus();
    }}else {
    _showAlertDialog(context);
    }


                                    // ((verificationStatus == 'Sent for Verification' || verificationStatus == 'Verified') &&  (verifiedBy == 'Verified By SM' || verifiedBy == 'Verified By CM'  )) ? _showAlertDialog(context) : UpdatedVerificationStatus();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: (verifiedBy == 'Verified By SM' || verifiedBy == 'Verified By CM') ? Colors.green[500] : Colors.green[500],
                                  ),
                                  child: Text(
                                    (verifiedBy == 'Verified By SM' || verifiedBy == 'Verified By CM') ? 'Verified' : 'Verify',
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: StyleData.boldFont),
                                  ),
                                ),
                                SizedBox(
                                  width: width * 0.02,
                                ),
                                ElevatedButton(
                                  onPressed: isQueryEntered
                                      ? () {
                                    if (verifiedBy == 'Verified By SM' || verifiedBy == 'Verified By CM') {
                                      // No action needed
                                    } else {
                                      if (verificationStatus == 'Push Back') {
                                        _showAlertDialog1(context);
                                      } else {
                                        UpdatedQueryStatus();
                                      }
                                    }
                                  }
                                      : null, // Disable the button if isQueryEntered is false
                                  style: ElevatedButton.styleFrom(
                                    primary: StyleData.buttonColor, // Ensure `StyleData` is properly defined
                                  ),
                                  child: Text(
                                    'Push Back',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: StyleData.boldFont, // Ensure `StyleData` is properly defined
                                    ),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Card(
                        elevation: 3,
                        child: Container(
                          width: width * 0.95,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Loan Application Documents Heading
                                if (filteredData.keys.any((key) => [
                                  "Application_Form",
                                  "Bank_Passbook",
                                  "Date_Of_Birth",
                                  "Login_Fee_Check",
                                  "Passport_Size_Photo",
                                  "Photo_Id_Proof",
                                  "Residence_Proof",
                                  "Salary_Slip",
                                  "Signature_Proof",
                                  "Copy_Of_Property",
                                  "Total_Work_Experience",
                                  "Qualification_Proof",
                                ].contains(key)))
                                  Column(
                                    children: [
                                      Text(
                                        "Loan Application Document",
                                        style: TextStyle(
                                          color: StyleData.appBarColor2,
                                          fontFamily: StyleData.boldFont,
                                          fontSize: 17,
                                        ),
                                      ),
                                      Table(
                                        border: TableBorder.all(color: Colors.grey),
                                        children: documents
                                            .where((doc) =>
                                        filteredData.containsKey(doc['key']) &&
                                            [
                                              "Application_Form",
                                              "Bank_Passbook",
                                              "Date_Of_Birth",
                                              "Login_Fee_Check",
                                              "Passport_Size_Photo",
                                              "Photo_Id_Proof",
                                              "Residence_Proof",
                                              "Salary_Slip",
                                              "Signature_Proof",
                                              "Copy_Of_Property",
                                              "Total_Work_Experience",
                                              "Qualification_Proof",
                                            ].contains(doc['key']))
                                            .map((doc) {
                                          return TableRow(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        doc['title'],
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily: 'YourBoldFontFamily',
                                                          fontSize: 17,
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        (docData != null && docData.containsKey(doc['key']) && docData[doc['key']].toString().isNotEmpty)
                                                            ? InkWell(
                                                          onTap: () async {
                                                            String docId = docData[doc['key']].toString();
                                                            await downloadDocument(docId, docData['LeadID']);
                                                          },
                                                          child: Column(
                                                            children: [
                                                              Icon(
                                                                Icons.download_for_offline,
                                                                color: Colors.green,
                                                              ),
                                                              Text("Download"),
                                                            ],
                                                          ),
                                                        )
                                                            : Column(
                                                          children: [
                                                            Icon(
                                                              Icons.pending,
                                                              color: Colors.red.shade300,
                                                            ),
                                                            Text("Pending   "),
                                                          ],
                                                        ),
                                                        VerticalDivider(
                                                          color: Colors.grey,
                                                          thickness: 1,
                                                          width: 20,
                                                          indent: 5,
                                                          endIndent: 5,
                                                        ),
                                                        verifiedBy == 'Verified By SM' || verifiedBy == 'Verified By CM' ?
                                                        Column(
                                                          children: [
                                                            Checkbox(
                                                              value: doc['isChecked'],
                                                              activeColor: StyleData.appBarColor2,
                                                              onChanged: (value) {
                                                              },
                                                            ),
                                                            Text('Verified'),
                                                          ],
                                                        ) :
                                                        Column(
                                                          children: [
                                                            Checkbox(
                                                              value: doc['isChecked'],
                                                              activeColor: StyleData.appBarColor2,
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  doc['isChecked'] = value!;
                                                                });
                                                                if (doc['isChecked']) {
                                                                  setState(() {
                                                                    doc['queryController'].clear();
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                            Text('Verify'),
                                                          ],
                                                        ),
                                                        VerticalDivider(
                                                          color: Colors.grey,
                                                          thickness: 1,
                                                          width: 20,
                                                          indent: 5,
                                                          endIndent: 5,
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: TextField(
                                                        controller: doc['queryController'],
                                                        onChanged: (value) {
                                                     setState(() {
                                                       isQueryEntered = value.isNotEmpty;
                                                     });
                                                        },
                                                        decoration: InputDecoration(
                                                          hintText: "Enter your query here",
                                                          // focusedBorder: focus,
                                                          // enabledBorder: enb,
                                                          border: OutlineInputBorder(
                                                            borderSide:
                                                            BorderSide(color: Colors.black12),
                                                          ),
                                                           focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: Colors.black12,
                                                            ),
                                                          ),
                                                        ),
                                                        maxLines: 1,
                                                        enabled: !doc['isChecked'],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),

                                // Technical Checklist Heading
                                if (filteredData.keys.any((key) => key.contains('checklist')))
                                  Column(
                                    children: [
                                      Text(
                                        "Technical Checklist",
                                        style: TextStyle(
                                          color: StyleData.appBarColor2,
                                          fontFamily: StyleData.boldFont,
                                          fontSize: 17,
                                        ),
                                      ),
                                      Table(
                                        border: TableBorder.all(color: Colors.grey),
                                        children: documents
                                            .where((doc) =>
                                        filteredData.containsKey(doc['key']) &&
                                            doc['key'].contains('checklist'))
                                            .map((doc) {
                                          return TableRow(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        doc['title'],
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily: 'YourBoldFontFamily',
                                                          fontSize: 17,
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        (docData != null && docData.containsKey(doc['key']) && docData[doc['key']].toString().isNotEmpty)
                                                            ? InkWell(
                                                          onTap: () async {
                                                            String docId = docData[doc['key']].toString();
                                                            await downloadDocument(docId, docData['LeadID']);
                                                          },
                                                          child: Column(
                                                            children: [
                                                              Icon(
                                                                Icons.download_for_offline,
                                                                color: Colors.green,
                                                              ),
                                                              Text("Download"),
                                                            ],
                                                          ),
                                                        )
                                                            : Column(
                                                          children: [
                                                            Icon(
                                                              Icons.pending,
                                                              color: Colors.red.shade300,
                                                            ),
                                                            Text("Pending   "),
                                                          ],
                                                        ),
                                                        VerticalDivider(
                                                          color: Colors.grey,
                                                          thickness: 1,
                                                          width: 20,
                                                          indent: 5,
                                                          endIndent: 5,
                                                        ),
                                                        verifiedBy == 'Verified By SM' || verifiedBy == 'Verified By CM'  ?
                                                        Column(
                                                          children: [
                                                            Checkbox(
                                                              value: doc['isChecked'],
                                                              activeColor: StyleData.appBarColor2,
                                                              onChanged: (value) {
                                                              },
                                                            ),
                                                            Text('Verified'),
                                                          ],
                                                        ) :
                                                        Column(
                                                          children: [
                                                            Checkbox(
                                                              value: doc['isChecked'],
                                                              activeColor: StyleData.appBarColor2,
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  doc['isChecked'] = value!;
                                                                });
                                                                if (doc['isChecked']) {
                                                                  setState(() {
                                                                    doc['queryController'].clear();
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                            Text('Verify'),
                                                          ],
                                                        ),
                                                        VerticalDivider(
                                                          color: Colors.grey,
                                                          thickness: 1,
                                                          width: 20,
                                                          indent: 5,
                                                          endIndent: 5,
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: TextField(
                                                        controller: doc['queryController'],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            isQueryEntered = value.isNotEmpty;
                                                          });
                                                        },
                                                        decoration: InputDecoration(
                                                          hintText: "Enter your query here",
                                                          border: OutlineInputBorder(
                                                            borderSide:
                                                            BorderSide(color: Colors.black12),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                              color: Colors.black12,
                                                            ),
                                                          ),
                                                        ),
                                                        maxLines: 1,
                                                        enabled: !doc['isChecked'],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),


            ],
          ),
        ),
      )
      ),
    );
  }
  void _showAlertDialog1(BuildContext context) {
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
                          color: Colors.yellow,
                          shape: BoxShape.circle
                      ),
                      child: Center(
                        child: Icon(Icons.warning,color: Colors.white,),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Query has been already sent', textAlign: TextAlign.center,style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold)),
                  //  SizedBox(height: 8),

                  SizedBox(height: 5),
                  SizedBox(
                    height: 25,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
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
  void _showAlertDialog(BuildContext context) {
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
                          color: Colors.yellow,
                          shape: BoxShape.circle
                      ),
                      child: Center(
                        child: Icon(Icons.warning,color: Colors.white,),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
             Text('Please Verify all the documents', textAlign: TextAlign.center,style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold)),
                  //  SizedBox(height: 8),

                  SizedBox(height: 5),
                  SizedBox(
                    height: 25,
                    child: ElevatedButton(
                      onPressed: () {
                     Navigator.pop(context);
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
  void _showAlertDialog2(BuildContext context) {
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
                          color: Colors.yellow,
                          shape: BoxShape.circle
                      ),
                      child: Center(
                        child: Icon(Icons.warning,color: Colors.white,),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Please enter your Query', textAlign: TextAlign.center,style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold)),
                  //  SizedBox(height: 8),

                  SizedBox(height: 5),
                  SizedBox(
                    height: 25,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
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

// Expanded(
//   child : GridView.builder(
//     shrinkWrap: true,
//     physics: NeverScrollableScrollPhysics(),
//     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//       crossAxisCount: 2,
//       mainAxisSpacing: 0,
//       crossAxisSpacing: 0,
//       childAspectRatio: 3.0, // Adjust aspect ratio to give more space to keys
//     ),
//     itemCount: filteredData.length,
//     itemBuilder: (BuildContext context, int index) {
//       var key = filteredData.keys.toList()[index];
//       var value = filteredData[key];
//       return Container(
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Text(
//                   key,
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontFamily: StyleData.boldFont,
//                     fontSize: 17,
//                   ),
//                 ),
//               ),
//               // Text(value.toString()),
//               InkWell(
//                 onTap: () async {
//                   // print(docData);
//                   // print("bjksjjjjjjjj");
//
//                   // if (docData.containsKey('Bank_Passbook')) {
//                   //   docId = docData['Bank_Passbook'].toString();
//                   //   // "${docData['Application_Form'].toString()}";
//                   // }
//                   docId = value.toString();
//                   print(docId);
//                   // New Implementation
//                   var map = <String, dynamic>{};
//                   map['DocId'] = docId;
//                   map['LUSR'] = 'HomeFin';
//
//                   http.Response response = await http.post(
//                     Uri.parse(
//                         "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                     body: map,
//                   );
//                   final data1 = response.bodyBytes;
//                   final mime =
//                   lookupMimeType('', headerBytes: data1);
//                   // print(mime);
//                   if (docId.toString().contains(",")) {
//                     AnchorElement(
//                         href:
//                         "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                       ..setAttribute(
//                           "download",
//                           (docData['LeadID'] != null &&
//                               docData['LeadID'].isNotEmpty)
//                               ? "${docData['LeadID']}.zip"
//                               : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                       ..click();
//                   } else {
//                     AnchorElement(
//                         href:
//                         "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                       ..setAttribute(
//                           "download",
//                           (docData['LeadID'] != null &&
//                               docData['LeadID'].isNotEmpty)
//                               ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                               : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                       ..click();
//                   }
//                 },
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.download_for_offline,
//                       color: Colors.green,
//                     ),
//                     Text("Download")
//                   ],
//                 ),
//               )// Assuming value is a string, adjust accordingly
//             ],
//           ),
//         ),
//       );
//     },
//   ),
// ),

// SizedBox(
//   width: width * 0.1,
// ),
// Visibility(
//    visible : QueryStatus == true && QueryUpdatedByRO == "Query By SM",
//   child: Padding(
//     padding: const EdgeInsets.all(22.0),
//     child: Container(
//       padding: EdgeInsets.all(10.0),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Query",
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18.0,
//                 color: StyleData.appBarColor2
//             ),
//           ),
//           SizedBox(height: 8.0),
//           Text(
//             '$Query',
//             style: TextStyle(
//               fontStyle: FontStyle.italic,
//               fontSize: 16.0,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     ),
//   ),
// )

// Card(
//   elevation: 3,
//   child: Container(
//     height: height * 0.9,
//     width: width * 0.95,
//     color: Colors.white,
//     child: Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             "Mandatory Documents",
//             style: TextStyle(
//               color:  StyleData.appBarColor2,
//               fontFamily: StyleData.boldFont,
//               fontSize: 17,
//             ),
//           ),
//           Table(
//             border: TableBorder.all(color: Colors.grey),
//             children: [
//               TableRow(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Application Form",
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontFamily: StyleData.boldFont,
//                               fontSize: 17,
//                             ),
//                           ),
//                         ),
//                         Row(
//                           children: [
//                             (docData != null && docData.containsKey('Application_Form'))
//                                 ? InkWell(
//                               onTap: () async {
//                                 // print(docData);
//                                 // print("bjksjjjjjjjj");
//
//                                 if (docData.containsKey('Application_Form')) {
//                                   docId = docData['Application_Form'].toString();
//                                   // "${docData['Application_Form'].toString()}";
//                                 }
//                                 print(docId);
//                                 // New Implementation
//                                 var map = <String, dynamic>{};
//                                 map['DocId'] = docId;
//                                 map['LUSR'] = 'HomeFin';
//
//                                 http.Response response = await http.post(
//                                   Uri.parse(
//                                       "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                                   body: map,
//                                 );
//                                 final data1 = response.bodyBytes;
//                                 final mime =
//                                 lookupMimeType('', headerBytes: data1);
//                                 // print(mime);
//                                 if (docId.toString().contains(",")) {
//                                   AnchorElement(
//                                       href:
//                                       "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                     ..setAttribute(
//                                         "download",
//                                         (docData['LeadID'] != null &&
//                                             docData['LeadID'].isNotEmpty)
//                                             ? "${docData['LeadID']}.zip"
//                                             : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                                     ..click();
//                                 } else {
//                                   AnchorElement(
//                                       href:
//                                       "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                     ..setAttribute(
//                                         "download",
//                                         (docData['LeadID'] != null &&
//                                             docData['LeadID'].isNotEmpty)
//                                             ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                                             : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                                     ..click();
//                                 }
//                               },
//                               child: Column(
//                                 children: [
//                                   Icon(
//                                     Icons.download_for_offline,
//                                     color: Colors.green,
//                                   ),
//                                   Text("Download")
//                                 ],
//                               ),
//                             )
//                                 : Column(
//                               children: [
//                                 Icon(
//                                   Icons.pending,
//                                   color: Colors.red.shade300,
//                                 ),
//                                 Text("No File")
//                               ],
//                             ),
//                             VerticalDivider(
//                               color: Colors.grey,
//                               thickness: 1,
//                               width: 20,
//                               indent: 5,
//                               endIndent: 5,
//                             ),
//                             Column(
//                               children: [
//                                 Checkbox(
//                                   value: _isApplicationChecked,
//                                   activeColor: StyleData.appBarColor,
//                                   onChanged: (value) {
//                                     setState(() {
//                                       _isApplicationChecked = value!;
//                                     });
//                                   },
//                                 ),
//                                 Text('Verify'),
//                               ],
//                             ),
//                             VerticalDivider(
//                               color: Colors.grey,
//                               thickness: 1,
//                               width: 20,
//                               indent: 5,
//                               endIndent: 5,
//                             ),
//                           ]
//                         ),
//                         Expanded(
//                           child: TextField(
//                             decoration: InputDecoration(
//                               hintText: "Enter your query here",
//                               border: OutlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.black12),
//                               ),
//                             ),
//                             maxLines: 2, // Adjust the number of lines as needed
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Second cell content
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Bank Passbook (Latest 6 months)",
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontFamily: StyleData.boldFont,
//                               fontSize: 17,
//                             ),
//                           ),
//                         ),
//                         VerticalDivider(
//                           color: Colors.grey,
//                           thickness: 1, // Adjust the thickness as needed
//                           width: 20, // Space for the divider
//                           indent: 5, // Top indent
//                           endIndent: 5, // Bottom indent
//                         ),
//                         Row(
//                             children : [
//                               (docData != null && docData.containsKey('Bank_Passbook'))
//                                   ? InkWell(
//                                 onTap: () async {
//                                   if (docData.containsKey('Bank_Passbook')) {
//                                     docId = docData['Bank_Passbook'].toString();
//                                   }
//                                   print(docId);
//
//                                   var map = <String, dynamic>{};
//                                   map['DocId'] = docId;
//                                   map['LUSR'] = 'HomeFin';
//
//                                   http.Response response = await http.post(
//                                     Uri.parse("https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                                     body: map,
//                                   );
//                                   final data1 = response.bodyBytes;
//                                   final mime = lookupMimeType('', headerBytes: data1);
//
//                                   if (docId.toString().contains(",")) {
//                                     AnchorElement(
//                                       href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}",
//                                     )
//                                       ..setAttribute(
//                                           "download",
//                                           (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                               ? "${docData['LeadID']}.zip"
//                                               : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                                       ..click();
//                                   } else {
//                                     AnchorElement(
//                                       href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}",
//                                     )
//                                       ..setAttribute(
//                                           "download",
//                                           (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                               ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                                               : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                                       ..click();
//                                   }
//                                 },
//                                 child: Column(
//                                   children: [
//                                     Icon(
//                                       Icons.download_for_offline,
//                                       color: Colors.green,
//                                     ),
//                                     Text("Download")
//                                   ],
//                                 ),
//                               )
//                                   : Column(
//                                 children: [
//                                   Icon(
//                                     Icons.pending,
//                                     color: Colors.red.shade300,
//                                   ),
//                                   Text("No File")
//                                 ],
//                               ),
//                               VerticalDivider(
//                                 color: Colors.grey,
//                                 thickness: 1,
//                                 width: 20,
//                                 indent: 5,
//                                 endIndent: 5,
//                               ),
//                               Column(
//                                 children: [
//                                   Checkbox(
//                                     value: _isBankPassBookChecked,
//                                     activeColor: StyleData.appBarColor,
//                                     onChanged: (value) {
//                                       setState(() {
//                                         _isBankPassBookChecked = value!;
//                                       });
//                                     },
//                                   ),
//                                   Text('Verify'),
//                                 ],
//                               ),
//                             ]
//                         ),
//
//                         VerticalDivider(
//                           color: Colors.grey,
//                           thickness: 1,
//                           width: 20,
//                           indent: 5,
//                           endIndent: 5,
//                         ),
//                         Expanded(
//                           child: TextField(
//                             controller: queryReason,
//                             decoration: InputDecoration(
//                               hintText: "Enter your query here",
//                               border: OutlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.black12),
//                               ),
//                             ),
//                             maxLines: 2, // Adjust the number of lines as needed
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ],
//           ),
//           Table(
//             border: TableBorder.all(color: Colors.grey),
//             children: [
//               TableRow(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child:  Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Date of Birth Proof",
//                             style: TextStyle(
//                               color:  Colors.black,
//                               fontFamily: StyleData.boldFont,
//                               fontSize: 17,
//                             ),
//                           ),
//                         ),
//                         (docData != null && docData.containsKey('Date_Of_Birth')) ?
//                         InkWell(
//                           onTap: () async {
//                             // print(docData);
//                             // print("bjksjjjjjjjj");
//
//                             if (docData.containsKey(
//                                 'Date_Of_Birth')) {
//                               docId = docData['Date_Of_Birth'].toString();
//                               // "${docData['Application_Form'].toString()}";
//                             }
//                             print(docId);
//                             // New Implementation
//                             var map = <String,
//                                 dynamic>{};
//                             map['DocId'] = docId;
//                             map['LUSR'] = 'HomeFin';
//
//                             http.Response
//                             response =
//                             await http.post(
//                               Uri.parse(
//                                   "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                               body: map,
//                             );
//                             final data1 = response
//                                 .bodyBytes;
//                             final mime =
//                             lookupMimeType('',
//                                 headerBytes:
//                                 data1);
//                             // print(mime);
//                             if (docId.toString().contains(",")) {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.zip"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                                 ..click();
//                             } else {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                                 ..click();
//                             }
//
//                           },
//                           child: Column(
//                             children: [
//                               Icon(
//                                   Icons.download_for_offline,
//                                   color: Colors.green
//                               ),
//                               Text("Download")
//                             ],
//                           ),
//                         ) :  Column(
//                           children: [
//                             Icon(
//                               Icons.pending,
//                               color: Colors.red.shade300,
//                             ),
//                             Text("No File")
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                   // Second cell content
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child:  Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Login Fee Cheque",
//                             style: TextStyle(
//                               color:  Colors.black,
//                               fontFamily: StyleData.boldFont,
//                               fontSize: 17,
//                             ),
//                           ),
//                         ),
//                         (docData != null && docData.containsKey('Login_Fee_Check')) ?
//                         InkWell(
//                           onTap: () async {
//                             // print(docData);
//                             // print("bjksjjjjjjjj");
//
//                             if (docData.containsKey(
//                                 'Login_Fee_Check')) {
//                               docId = docData['Login_Fee_Check'].toString();
//                               // "${docData['Application_Form'].toString()}";
//                             }
//                             print(docId);
//                             // New Implementation
//                             var map = <String,
//                                 dynamic>{};
//                             map['DocId'] = docId;
//                             map['LUSR'] = 'HomeFin';
//
//                             http.Response
//                             response =
//                             await http.post(
//                               Uri.parse(
//                                   "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                               body: map,
//                             );
//                             final data1 = response
//                                 .bodyBytes;
//                             final mime =
//                             lookupMimeType('',
//                                 headerBytes:
//                                 data1);
//                             // print(mime);
//                             if (docId.toString().contains(",")) {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.zip"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                                 ..click();
//                             } else {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                                 ..click();
//                             }
//
//                           },
//                           child: Column(
//                             children: [
//                               Icon(
//                                   Icons.download_for_offline,
//                                   color: Colors.green
//                               ),
//                               Text("Download")
//                             ],
//                           ),
//                         ) :  Column(
//                           children: [
//                             Icon(
//                               Icons.pending,
//                               color: Colors.red.shade300,
//                             ),
//                             Text("No File")
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Table(
//             border: TableBorder.all(color: Colors.grey),
//             children: [
//               TableRow(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child:  Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Passport Size Color Photograph",
//                             style: TextStyle(
//                               color:  Colors.black,
//                               fontFamily: StyleData.boldFont,
//                               fontSize: 17,
//                             ),
//                           ),
//                         ),
//                         (docData != null && docData.containsKey('Passport_Size_Photo')) ?
//                         InkWell(
//                           onTap: () async {
//                             // print(docData);
//                             // print("bjksjjjjjjjj");
//
//                             if (docData.containsKey(
//                                 'Passport_Size_Photo')) {
//                               docId = docData['Passport_Size_Photo'].toString();
//                               // "${docData['Application_Form'].toString()}";
//                             }
//                             print(docId);
//                             // New Implementation
//                             var map = <String,
//                                 dynamic>{};
//                             map['DocId'] = docId;
//                             map['LUSR'] = 'HomeFin';
//
//                             http.Response
//                             response =
//                             await http.post(
//                               Uri.parse(
//                                   "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                               body: map,
//                             );
//                             final data1 = response
//                                 .bodyBytes;
//                             final mime =
//                             lookupMimeType('',
//                                 headerBytes:
//                                 data1);
//                             // print(mime);
//                             if (docId.toString().contains(",")) {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.zip"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                                 ..click();
//                             } else {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                                 ..click();
//                             }
//
//                           },
//                           child: Column(
//                             children: [
//                               Icon(
//                                   Icons.download_for_offline,
//                                   color: Colors.green
//                               ),
//                               Text("Download")
//                             ],
//                           ),
//                         ) :  Column(
//                           children: [
//                             Icon(
//                               Icons.pending,
//                               color: Colors.red.shade300,
//                             ),
//                             Text("No File")
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                   // Second cell content
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child:  Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Photo ID Proof",
//                             style: TextStyle(
//                               color:  Colors.black,
//                               fontFamily: StyleData.boldFont,
//                               fontSize: 17,
//                             ),
//                           ),
//                         ),
//                         (docData != null && docData.containsKey('Photo_Id_Proof')) ?
//                         InkWell(
//                           onTap: () async {
//                             // print(docData);
//                             // print("bjksjjjjjjjj");
//
//                             if (docData.containsKey(
//                                 'Photo_Id_Proof')) {
//                               docId = docData['Photo_Id_Proof'].toString();
//                               // "${docData['Application_Form'].toString()}";
//                             }
//                             print(docId);
//                             // New Implementation
//                             var map = <String,
//                                 dynamic>{};
//                             map['DocId'] = docId;
//                             map['LUSR'] = 'HomeFin';
//
//                             http.Response
//                             response =
//                             await http.post(
//                               Uri.parse(
//                                   "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                               body: map,
//                             );
//                             final data1 = response
//                                 .bodyBytes;
//                             final mime =
//                             lookupMimeType('',
//                                 headerBytes:
//                                 data1);
//                             // print(mime);
//                             if (docId.toString().contains(",")) {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.zip"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                                 ..click();
//                             } else {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                                 ..click();
//                             }
//
//                           },
//                           child: Column(
//                             children: [
//                               Icon(
//                                   Icons.download_for_offline,
//                                   color: Colors.green
//                               ),
//                               Text("Download")
//                             ],
//                           ),
//                         ) :  Column(
//                           children: [
//                             Icon(
//                               Icons.pending,
//                               color: Colors.red.shade300,
//                             ),
//                             Text("No File")
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Table(
//             border: TableBorder.all(color: Colors.grey),
//             children: [
//               TableRow(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child:  Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Residence Proof",
//                             style: TextStyle(
//                               color:  Colors.black,
//                               fontFamily: StyleData.boldFont,
//                               fontSize: 17,
//                             ),
//                           ),
//                         ),
//                         (docData != null && docData.containsKey('Residence_Proof')) ?
//                         InkWell(
//                           onTap: () async {
//                             // print(docData);
//                             // print("bjksjjjjjjjj");
//
//                             if (docData.containsKey(
//                                 'Residence_Proof')) {
//                               docId = docData['Residence_Proof'].toString();
//                               // "${docData['Application_Form'].toString()}";
//                             }
//                             print(docId);
//                             // New Implementation
//                             var map = <String,
//                                 dynamic>{};
//                             map['DocId'] = docId;
//                             map['LUSR'] = 'HomeFin';
//
//                             http.Response
//                             response =
//                             await http.post(
//                               Uri.parse(
//                                   "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                               body: map,
//                             );
//                             final data1 = response
//                                 .bodyBytes;
//                             final mime =
//                             lookupMimeType('',
//                                 headerBytes:
//                                 data1);
//                             // print(mime);
//                             if (docId.toString().contains(",")) {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.zip"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                                 ..click();
//                             } else {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                                 ..click();
//                             }
//
//                           },
//                           child: Column(
//                             children: [
//                               Icon(
//                                   Icons.download_for_offline,
//                                   color: Colors.green
//                               ),
//                               Text("Download")
//                             ],
//                           ),
//                         ) :  Column(
//                           children: [
//                             Icon(
//                               Icons.pending,
//                               color: Colors.red.shade300,
//                             ),
//                             Text("No File")
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                   // Second cell content
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child:  Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Salary Slip 3 Month",
//                             style: TextStyle(
//                               color:  Colors.black,
//                               fontFamily: StyleData.boldFont,
//                               fontSize: 17,
//                             ),
//                           ),
//                         ),
//                         (docData != null && docData.containsKey('Salary_Slip')) ?
//                         InkWell(
//                           onTap: () async {
//                             // print(docData);
//                             // print("bjksjjjjjjjj");
//
//                             if (docData.containsKey(
//                                 'Salary_Slip')) {
//                               docId = docData['Salary_Slip'].toString();
//                               // "${docData['Application_Form'].toString()}";
//                             }
//                             print(docId);
//                             // New Implementation
//                             var map = <String,
//                                 dynamic>{};
//                             map['DocId'] = docId;
//                             map['LUSR'] = 'HomeFin';
//
//                             http.Response
//                             response =
//                             await http.post(
//                               Uri.parse(
//                                   "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                               body: map,
//                             );
//                             final data1 = response
//                                 .bodyBytes;
//                             final mime =
//                             lookupMimeType('',
//                                 headerBytes:
//                                 data1);
//                             // print(mime);
//                             if (docId.toString().contains(",")) {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.zip"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                                 ..click();
//                             } else {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                                 ..click();
//                             }
//
//                           },
//                           child: Column(
//                             children: [
//                               Icon(
//                                   Icons.download_for_offline,
//                                   color: Colors.green
//                               ),
//                               Text("Download")
//                             ],
//                           ),
//                         ) :  Column(
//                           children: [
//                             Icon(
//                               Icons.pending,
//                               color: Colors.red.shade300,
//                             ),
//                             Text("No File")
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Table(
//             border: TableBorder.all(color: Colors.grey),
//             children: [
//               TableRow(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child:     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Signature Proof",
//                             style: TextStyle(
//                               color:  Colors.black,
//                               fontFamily: StyleData.boldFont,
//                               fontSize: 17,
//                             ),
//                           ),
//                         ),
//                         (docData != null && docData.containsKey('Signature_Proof')) ?
//                         InkWell(
//                           onTap: () async {
//                             // print(docData);
//                             // print("bjksjjjjjjjj");
//
//                             if (docData.containsKey(
//                                 'Signature_Proof')) {
//                               docId = docData['Signature_Proof'].toString();
//                               // "${docData['Application_Form'].toString()}";
//                             }
//                             print(docId);
//                             // New Implementation
//                             var map = <String,
//                                 dynamic>{};
//                             map['DocId'] = docId;
//                             map['LUSR'] = 'HomeFin';
//
//                             http.Response
//                             response =
//                             await http.post(
//                               Uri.parse(
//                                   "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                               body: map,
//                             );
//                             final data1 = response
//                                 .bodyBytes;
//                             final mime =
//                             lookupMimeType('',
//                                 headerBytes:
//                                 data1);
//                             // print(mime);
//                             if (docId.toString().contains(",")) {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.zip"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                                 ..click();
//                             } else {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                                 ..click();
//                             }
//
//                           },
//                           child: Column(
//                             children: [
//                               Icon(
//                                   Icons.download_for_offline,
//                                   color: Colors.green
//                               ),
//                               Text("Download")
//                             ],
//                           ),
//                         ) :  Column(
//                           children: [
//                             Icon(
//                               Icons.pending,
//                               color: Colors.red.shade300,
//                             ),
//                             Text("No File")
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                   // Second cell content
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child:  Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Text(
//             "Optional Documents",
//             style: TextStyle(
//               color:  StyleData.appBarColor2,
//               fontFamily: StyleData.boldFont,
//               fontSize: 17,
//             ),
//           ),
//           Table(
//             border: TableBorder.all(color: Colors.grey),
//             children: [
//               TableRow(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child:  Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Copy Of Property",
//                             style: TextStyle(
//                               color:  Colors.black,
//                               fontFamily: StyleData.boldFont,
//                               fontSize: 17,
//                             ),
//                           ),
//                         ),
//                         (docData != null && docData.containsKey('Copy_Of_Property')) ?
//                         InkWell(
//                           onTap: () async {
//                             // print(docData);
//                             // print("bjksjjjjjjjj");
//
//                             if (docData.containsKey(
//                                 'Copy_Of_Property')) {
//                               docId = docData['Copy_Of_Property'].toString();
//                               // "${docData['Application_Form'].toString()}";
//                             }
//                             print(docId);
//                             // New Implementation
//                             var map = <String,
//                                 dynamic>{};
//                             map['DocId'] = docId;
//                             map['LUSR'] = 'HomeFin';
//
//                             http.Response
//                             response =
//                             await http.post(
//                               Uri.parse(
//                                   "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                               body: map,
//                             );
//                             final data1 = response
//                                 .bodyBytes;
//                             final mime =
//                             lookupMimeType('',
//                                 headerBytes:
//                                 data1);
//                             // print(mime);
//                             if (docId.toString().contains(",")) {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.zip"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                                 ..click();
//                             } else {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                                 ..click();
//                             }
//
//                           },
//                           child: Column(
//                             children: [
//                               Icon(
//                                   Icons.download_for_offline,
//                                   color: Colors.green
//                               ),
//                               Text("Download")
//                             ],
//                           ),
//                         ) :  Column(
//                           children: [
//                             Icon(
//                               Icons.pending,
//                               color: Colors.red.shade300,
//                             ),
//                             Text("No File")
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                   // Second cell content
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Total Work Experience",
//                             style: TextStyle(
//                               color:  Colors.black,
//                               fontFamily: StyleData.boldFont,
//                               fontSize: 17,
//                             ),
//                           ),
//                         ),
//                         (docData != null && docData.containsKey('Total_Work_Experience')) ?
//                         InkWell(
//                           onTap: () async {
//                             // print(docData);
//                             // print("bjksjjjjjjjj");
//
//                             if (docData.containsKey(
//                                 'Total_Work_Experience')) {
//                               docId = docData['Total_Work_Experience'].toString();
//                               // "${docData['Application_Form'].toString()}";
//                             }
//                             print(docId);
//                             // New Implementation
//                             var map = <String,
//                                 dynamic>{};
//                             map['DocId'] = docId;
//                             map['LUSR'] = 'HomeFin';
//
//                             http.Response
//                             response =
//                             await http.post(
//                               Uri.parse(
//                                   "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                               body: map,
//                             );
//                             final data1 = response
//                                 .bodyBytes;
//                             final mime =
//                             lookupMimeType('',
//                                 headerBytes:
//                                 data1);
//                             // print(mime);
//                             if (docId.toString().contains(",")) {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.zip"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                                 ..click();
//                             } else {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                                 ..click();
//                             }
//
//                           },
//                           child: Column(
//                             children: [
//                               Icon(
//                                   Icons.download_for_offline,
//                                   color: Colors.green
//                               ),
//                               Text("Download")
//                             ],
//                           ),
//                         ) :  Column(
//                           children: [
//                             Icon(
//                               Icons.pending,
//                               color: Colors.red.shade300,
//                             ),
//                             Text("No File")
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           Table(
//             border: TableBorder.all(color: Colors.grey),
//             children: [
//               TableRow(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child:    Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Work Experience",
//                             style: TextStyle(
//                               color:  Colors.black,
//                               fontFamily: StyleData.boldFont,
//                               fontSize: 17,
//                             ),
//                           ),
//                         ),
//                         (docData != null && docData.containsKey('Work_Experience')) ?
//                         InkWell(
//                           onTap: () async {
//                             // print(docData);
//                             // print("bjksjjjjjjjj");
//
//                             if (docData.containsKey(
//                                 'Work_Experience')) {
//                               docId = docData['Work_Experience'].toString();
//                               // "${docData['Application_Form'].toString()}";
//                             }
//                             print(docId);
//                             // New Implementation
//                             var map = <String,
//                                 dynamic>{};
//                             map['DocId'] = docId;
//                             map['LUSR'] = 'HomeFin';
//
//                             http.Response
//                             response =
//                             await http.post(
//                               Uri.parse(
//                                   "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                               body: map,
//                             );
//                             final data1 = response
//                                 .bodyBytes;
//                             final mime =
//                             lookupMimeType('',
//                                 headerBytes:
//                                 data1);
//                             // print(mime);
//                             if (docId.toString().contains(",")) {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.zip"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                                 ..click();
//                             } else {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                                 ..click();
//                             }
//
//                           },
//                           child: Column(
//                             children: [
//                               Icon(
//                                   Icons.download_for_offline,
//                                   color: Colors.green
//                               ),
//                               Text("Download")
//                             ],
//                           ),
//                         ) :  Column(
//                           children: [
//                             Icon(
//                               Icons.pending,
//                               color: Colors.red.shade300,
//                             ),
//                             Text("No File")
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                   // Second cell content
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child:  Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Qualification Proof",
//                             style: TextStyle(
//                               color:  Colors.black,
//                               fontFamily: StyleData.boldFont,
//                               fontSize: 17,
//                             ),
//                           ),
//                         ),
//                         (docData != null && docData.containsKey('Qualification_Proof')) ?
//                         InkWell(
//                           onTap: () async {
//                             // print(docData);
//                             // print("bjksjjjjjjjj");
//
//                             if (docData.containsKey(
//                                 'Qualification_Proof')) {
//                               docId = docData['Qualification_Proof'].toString();
//                               // "${docData['Application_Form'].toString()}";
//                             }
//                             print(docId);
//                             // New Implementation
//                             var map = <String,
//                                 dynamic>{};
//                             map['DocId'] = docId;
//                             map['LUSR'] = 'HomeFin';
//
//                             http.Response
//                             response =
//                             await http.post(
//                               Uri.parse(
//                                   "https://6cpduvi80d.execute-api.ap-south-1.amazonaws.com/dms/downloaddoc"),
//                               body: map,
//                             );
//                             final data1 = response
//                                 .bodyBytes;
//                             final mime =
//                             lookupMimeType('',
//                                 headerBytes:
//                                 data1);
//                             // print(mime);
//                             if (docId.toString().contains(",")) {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.zip"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.zip")
//                                 ..click();
//                             } else {
//                               AnchorElement(
//                                   href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(response.bodyBytes)}")
//                                 ..setAttribute(
//                                     "download",
//                                     (docData['LeadID'] != null && docData['LeadID'].isNotEmpty)
//                                         ? "${docData['LeadID']}.${mime.toString().split("/").last}"
//                                         : "Documents_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}.${mime.toString().split("/").last}")
//                                 ..click();
//                             }
//
//                           },
//                           child: Column(
//                             children: [
//                               Icon(
//                                   Icons.download_for_offline,
//                                   color: Colors.green
//                               ),
//                               Text("Download")
//                             ],
//                           ),
//                         ) :  Column(
//                           children: [
//                             Icon(
//                               Icons.pending,
//                               color: Colors.red.shade300,
//                             ),
//                             Text("No File")
//                           ],
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//   ),
// ),