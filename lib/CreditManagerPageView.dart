import 'dart:convert';
import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../Utils/StyleData.dart';
import 'LoginPageView.dart';
import 'Utils/CustomeSnackBar.dart';
import 'creditDocumentPageView.dart';
import 'documentsPageView.dart';


class CreditManagerPageView extends StatefulWidget {
  const CreditManagerPageView({super.key});

  @override
  State<CreditManagerPageView> createState() => _CreditManagerPageViewState();
}

class _CreditManagerPageViewState extends State<CreditManagerPageView> {

  bool consentCRIF = true;
  bool consentKYC = true;

  String? docId;
  var data;


  CollectionReference convertedLeads =
  FirebaseFirestore.instance.collection('convertedLeads');
  final ScrollController _scrollController = ScrollController();

  List<QueryDocumentSnapshot> documents = [];
  bool usersVisibility = true;
  String searchText = '';

  var userType;
  List<Map<String, dynamic>> ListOfLeads = [];
  List<DocumentSnapshot> ListOfLeadsId = [];
  List<DocumentSnapshot> ListOfLeads1 = [];
  TextEditingController searchKEY = TextEditingController();
  String? ManagerName;
  String? BranchCode;
  String? EmployeeName;
  String? Designation;
  String VerificationStatus = "Pending";
  Map<dynamic, String> employeeFCMTokens = {};
  var fcmToken;
  bool _isLoading = true;
  String? technicalChecklistStatus;
  String? technicalStatus;

  var docData;

  Future<void> fetchdata() async {
    CollectionReference users = FirebaseFirestore.instance.collection('convertedLeads');
    SharedPreferences pref = await SharedPreferences.getInstance();
    var branchCode = pref.getString("BranchCode");
    print(branchCode);
    print(branchCode);
    setState(() {
      userType = pref.getString("logintype");
    });

    if (userType == "CreditManager") {
      users.where("EmployeeBranchCode", isEqualTo: branchCode).get().then((value) {
        print(branchCode);
        print("jkdhfkdhvkudv");
        List<Map<String, dynamic>> filteredList = value.docs.where((doc) {
        docData = doc.data();
          return docData.containsKey("LeadID") &&
              docData["LeadID"].toString().length > 1 &&
              ((docData["VerificationStatus"] == "Sent for Verification" &&  docData["VerifiedBy"] == "Pending with CM" ) );
        }).map((doc) => doc.data() as Map<String, dynamic>).toList();

        // Print out DocumentSnapshot for debugging
        for (var doc in value.docs) {
         // print(doc.data());
        }

        List<DocumentSnapshot> filteredList1 = value.docs.where((doc) {
          docData = doc.data();
          return (docData["LeadID"] as String).length > 1 && (docData["VerificationStatus"] == "Sent for Verification" );
        }).toList();
        List<DocumentSnapshot> filteredList2 = value.docs.where((doc) {
          docData = doc.data();
          return (docData["LeadID"] as String).length > 1 && (docData["VerificationStatus"] == "Sent for Verification" );
        }).toList();

        filteredList.forEach((data) {
          int technicalChecklistCount = data.containsKey("technicalChecklistCount") ? data["technicalChecklistCount"] : 0;
          int checklistCount = data.keys.where((key) => key.endsWith("checklist")).length;

          String technicalChecklistStatus;
          if (technicalChecklistCount == 0) {
            technicalChecklistStatus = "No Checklist";
          } else if (checklistCount == 0) {
            technicalChecklistStatus = "Technical Pending";
          } else if (checklistCount == technicalChecklistCount) {
            technicalChecklistStatus = "Fully Uploaded";
          } else {
            technicalChecklistStatus = "Partially Uploaded";
          }

          // Update the lead data with technicalChecklistStatus
          data["technicalChecklistStatus"] = technicalChecklistStatus;
        });
        setState(() {
          ListOfLeads = filteredList;
          ListOfLeads1 = filteredList2;
          ListOfLeadsId = filteredList1;
         // print(ListOfLeads);
          data = filteredList;
       ManagerName = pref.getString("ManagerName");
          BranchCode = filteredList.isNotEmpty ? filteredList[0]["homeFinBranchCode"] ?? "" : "";
          EmployeeName = filteredList.isNotEmpty ? filteredList[0]["EmployeeName"] ?? "" : "";
          Designation = filteredList.isNotEmpty ? filteredList[0]["Designation"] ?? "" : "";
        });

        for (var i = 0; i < filteredList.length; i++) {
        //  print(filteredList[i]);
        }
      });
    } else {
      users.get().then((value) {
        List<Map<String, dynamic>> filteredList = value.docs.where((doc) {
          docData = doc.data();
          return docData.containsKey("VerifiedBy") &&
              (docData["VerifiedBy"] == "Pending with CM" ) &&
              (docData["LeadID"] ?? "").toString().length > 1 &&
              (docData["VerificationStatus"] == "Sent for Verification" );
        }).map((doc) => doc.data() as Map<String, dynamic>).toList();

        List<DocumentSnapshot> filteredList1 = value.docs.where((doc) {
         docData = doc.data();
          return (docData["LeadID"] ?? "" as String).length > 1 && (docData["VerificationStatus"] == "Sent for Verification");
        }).toList();
        List<DocumentSnapshot> filteredList2 = value.docs.where((doc) {
          docData = doc.data();
          return (docData["LeadID"] ?? "" as String).length > 1 && (docData["VerificationStatus"] == "Sent for Verification" );
        }).toList();
        filteredList.forEach((data) {
          int technicalChecklistCount = data.containsKey("technicalChecklistCount") ? data["technicalChecklistCount"] : 0;
          int checklistCount = data.keys.where((key) => key.endsWith("checklist")).length;

          String technicalChecklistStatus;
          if (technicalChecklistCount == 0) {
            technicalChecklistStatus = "No Checklist";
          } else if (checklistCount == 0) {
            technicalChecklistStatus = "Technical Pending";
          } else if (checklistCount == technicalChecklistCount) {
            technicalChecklistStatus = "Fully Uploaded";
          } else {
            technicalChecklistStatus = "Partially Uploaded";
          }

          // Update the lead data with technicalChecklistStatus
          data["technicalChecklistStatus"] = technicalChecklistStatus;
        });

        setState(() {
          ListOfLeads = filteredList;
          ListOfLeadsId = filteredList1;
          ListOfLeads1 = filteredList2;
        });

        for (var i = 0; i < filteredList.length; i++) {
        //  print(filteredList[i]);
        }
      });
    }
  }



  Future<void> fetchdata1() async {
    CollectionReference users = FirebaseFirestore.instance.collection('convertedLeads');
    SharedPreferences pref = await SharedPreferences.getInstance();
    var branchCode = pref.getString("BranchCode");
    print(branchCode);
    print(branchCode);
    setState(() {
      userType = pref.getString("logintype");
    });

    if (userType == "CreditManager") {
      users.where("EmployeeBranchCode", isEqualTo: branchCode).get().then((value) {
        print(branchCode);
        print("jkdhfkdhvkudv");
        List<Map<String, dynamic>> filteredList = value.docs.where((doc) {
          docData = doc.data();
          return docData.containsKey("LeadID") &&
              docData["LeadID"].toString().length > 1 &&
              ( docData["VerificationStatus"] == "Verified" );
        }).map((doc) => doc.data() as Map<String, dynamic>).toList();

        // Print out DocumentSnapshot for debugging
        for (var doc in value.docs) {
          // print(doc.data());
        }

        List<DocumentSnapshot> filteredList1 = value.docs.where((doc) {
          docData = doc.data();
          return (docData["LeadID"] as String).length > 1 && ( docData["VerificationStatus"] == "Verified" );
        }).toList();
        List<DocumentSnapshot> filteredList2 = value.docs.where((doc) {
          docData = doc.data();
          return (docData["LeadID"] as String).length > 1 && ( docData["VerificationStatus"] == "Verified");
        }).toList();

        filteredList.forEach((data) {
          int technicalChecklistCount = data.containsKey("technicalChecklistCount") ? data["technicalChecklistCount"] : 0;
          int checklistCount = data.keys.where((key) => key.endsWith("checklist")).length;


          String technicalChecklistStatus;
          if (technicalChecklistCount == 0) {
            technicalChecklistStatus = "No Checklist";
          } else if (checklistCount == 0) {
            technicalChecklistStatus = "Technical Pending";
          } else if (checklistCount == technicalChecklistCount) {
            technicalChecklistStatus = "Fully Uploaded";
          } else {
            technicalChecklistStatus = "Partially Uploaded";
          }

          // Update the lead data with technicalChecklistStatus
          data["technicalChecklistStatus"] = technicalChecklistStatus;
        });

        setState(() {
          ListOfLeads = filteredList;
          ListOfLeads1 = filteredList2;
          ListOfLeadsId = filteredList1;
          // print(ListOfLeads);
          data = filteredList;
          ManagerName = pref.getString("ManagerName");
          BranchCode = filteredList.isNotEmpty ? filteredList[0]["homeFinBranchCode"] ?? "" : "";
          EmployeeName = filteredList.isNotEmpty ? filteredList[0]["EmployeeName"] ?? "" : "";
          Designation = filteredList.isNotEmpty ? filteredList[0]["Designation"] ?? "" : "";
        });

        for (var i = 0; i < filteredList.length; i++) {
          //  print(filteredList[i]);
        }
      });
    } else {
      users.get().then((value) {
        List<Map<String, dynamic>> filteredList = value.docs.where((doc) {
          docData = doc.data();
          return docData.containsKey("VerifiedBy") &&
              (docData["VerifiedBy"] == "Verified" ) &&
              (docData["LeadID"] ?? "").toString().length > 1 &&
              ( docData["VerificationStatus"] == "Verified" );
        }).map((doc) => doc.data() as Map<String, dynamic>).toList();

        List<DocumentSnapshot> filteredList1 = value.docs.where((doc) {
          docData = doc.data();
          return (docData["LeadID"] ?? "" as String).length > 1 && ( docData["VerificationStatus"] == "Verified" );
        }).toList();
        List<DocumentSnapshot> filteredList2 = value.docs.where((doc) {
          docData = doc.data();
          return (docData["LeadID"] ?? "" as String).length > 1 && (docData["VerificationStatus"] == "Verified" );
        }).toList();
        setState(() {
          ListOfLeads = filteredList;
          ListOfLeadsId = filteredList1;
          ListOfLeads1 = filteredList2;
        });

        for (var i = 0; i < filteredList.length; i++) {
          //  print(filteredList[i]);
        }
      });
    }
  }

  Future<void> fetchdata2() async {
    CollectionReference users = FirebaseFirestore.instance.collection('convertedLeads');
    SharedPreferences pref = await SharedPreferences.getInstance();
    var branchCode = pref.getString("BranchCode");
    print(branchCode);
    print(branchCode);
    setState(() {
      userType = pref.getString("logintype");
    });

    if (userType == "CreditManager") {
      users.where("EmployeeBranchCode", isEqualTo: branchCode).get().then((value) {
        print(branchCode);
        print("jkdhfkdhvkudv");
        List<Map<String, dynamic>> filteredList = value.docs.where((doc) {
          docData = doc.data();
          return docData.containsKey("LeadID") &&
              docData["LeadID"].toString().length > 1 &&
              ((docData["VerificationStatus"] == "Push Back" && docData["VerifiedBy"] == "Pending with CM"  ));
        }).map((doc) => doc.data() as Map<String, dynamic>).toList();

        filteredList.forEach((data) {
          int technicalChecklistCount = data.containsKey("technicalChecklistCount") ? data["technicalChecklistCount"] : 0;
          int checklistCount = data.keys.where((key) => key.endsWith("checklist")).length;


          String technicalChecklistStatus;
          if (technicalChecklistCount == 0) {
            technicalChecklistStatus = "No Checklist";
          } else if (checklistCount == 0) {
            technicalChecklistStatus = "Technical Pending";
          } else if (checklistCount == technicalChecklistCount) {
            technicalChecklistStatus = "Fully Uploaded";
          } else {
            technicalChecklistStatus = "Partially Uploaded";
          }

          // Update the lead data with technicalChecklistStatus
          data["technicalChecklistStatus"] = technicalChecklistStatus;
        });


        // Print out DocumentSnapshot for debugging
        for (var doc in value.docs) {
          // print(doc.data());
        }

        List<DocumentSnapshot> filteredList1 = value.docs.where((doc) {
          docData = doc.data();
          return (docData["LeadID"] as String).length > 1 && (  docData["VerificationStatus"] == "Push Back");
        }).toList();
        List<DocumentSnapshot> filteredList2 = value.docs.where((doc) {
          docData = doc.data();
          return (docData["LeadID"] as String).length > 1 && ( docData["VerificationStatus"] == "Push Back");
        }).toList();

        setState(() {
          ListOfLeads = filteredList;
          ListOfLeads1 = filteredList2;
          ListOfLeadsId = filteredList1;
          // print(ListOfLeads);
          data = filteredList;
          ManagerName = pref.getString("ManagerName");
          BranchCode = filteredList.isNotEmpty ? filteredList[0]["homeFinBranchCode"] ?? "" : "";
          EmployeeName = filteredList.isNotEmpty ? filteredList[0]["EmployeeName"] ?? "" : "";
          Designation = filteredList.isNotEmpty ? filteredList[0]["Designation"] ?? "" : "";
        });

        for (var i = 0; i < filteredList.length; i++) {
          //  print(filteredList[i]);
        }
      });
    } else {
      users.get().then((value) {
        List<Map<String, dynamic>> filteredList = value.docs.where((doc) {
          docData = doc.data();
          return docData.containsKey("VerifiedBy") &&
              (docData["LeadID"] ?? "").toString().length > 1 &&
              ( docData["VerificationStatus"] == "Push Back");
        }).map((doc) => doc.data() as Map<String, dynamic>).toList();

        List<DocumentSnapshot> filteredList1 = value.docs.where((doc) {
          docData = doc.data();
          return (docData["LeadID"] ?? "" as String).length > 1 && (  docData["VerificationStatus"] == "Push Back");
        }).toList();
        List<DocumentSnapshot> filteredList2 = value.docs.where((doc) {
          docData = doc.data();
          return (docData["LeadID"] ?? "" as String).length > 1 && ( docData["VerificationStatus"] == "Push Back");
        }).toList();
        setState(() {
          ListOfLeads = filteredList;
          ListOfLeadsId = filteredList1;
          ListOfLeads1 = filteredList2;
        });

        filteredList.forEach((data) {
          int technicalChecklistCount = data.containsKey("technicalChecklistCount") ? data["technicalChecklistCount"] : 0;
          int checklistCount = data.keys.where((key) => key.endsWith("checklist")).length;


          String technicalChecklistStatus;
          if (technicalChecklistCount == 0) {
            technicalChecklistStatus = "No Checklist";
          } else if (checklistCount == 0) {
            technicalChecklistStatus = "Technical Pending";
          } else if (checklistCount == technicalChecklistCount) {
            technicalChecklistStatus = "Fully Uploaded";
          } else {
            technicalChecklistStatus = "Partially Uploaded";
          }

          // Update the lead data with technicalChecklistStatus
          data["technicalChecklistStatus"] = technicalChecklistStatus;
        });

        for (var i = 0; i < filteredList.length; i++) {
          //  print(filteredList[i]);
        }
      });
    }
  }




  Future<void> fetchFCMdata() async {
    CollectionReference users = FirebaseFirestore.instance.collection('convertedLeads');
    SharedPreferences pref = await SharedPreferences.getInstance();
    var branchCode = pref.getString("BranchCode");

    setState(() {
      userType = pref.getString("logintype");
    });

    if (userType == "CreditManager") {
      users.where("EmployeeBranchCode", isEqualTo: branchCode).get().then((value) {
        for (var doc in value.docs) {
          var employeeCode = doc["EmployeeCode"] as String;
          employeeFCMTokens.putIfAbsent(employeeCode, () => "");
        }
        fetchFCMTokens(employeeFCMTokens);
      });
    } else {
      // Fetch all leads
      users.get().then((value) {
        for (var doc in value.docs) {
          var employeeCode = doc["EmployeeCode"] as String;

          // Store EmployeeCode from leads
          employeeFCMTokens.putIfAbsent(employeeCode, () => "");
        }

        // Fetch FCMToken for each EmployeeCode
        fetchFCMTokens(employeeFCMTokens);
      });
    }
  }

  Future<void> fetchFCMTokens(Map<dynamic, String> employeeFCMTokens) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Iterate through EmployeeCodes
    for (var employeeCode in employeeFCMTokens.keys) {
      // Query users collection for FCMToken based on EmployeeCode
      var querySnapshot = await users.where("EmployeeCode", isEqualTo: employeeCode).get();

      // If user found, update FCMToken in map
      if (querySnapshot.docs.isNotEmpty) {
        fcmToken = querySnapshot.docs.first.get("FCMToken") as String;
        employeeFCMTokens[employeeCode] = fcmToken;
      }
    }

    print(employeeFCMTokens);
  }





  List<Map<String, dynamic>> searchListOfLeads = [];
  List<DocumentSnapshot> searchListOfLeads1 = [];
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
        .contains(enteredKeyword.toUpperCase()) || row["customerNumber"]
        .toString()
        .toUpperCase()
        .contains(enteredKeyword.toUpperCase())||  row["EmployeeName"]
        .toString()
        .toUpperCase()
        .contains(enteredKeyword.toUpperCase()))).toList() ;
    var data1 = ListOfLeadsId.where((row) => (row["firstName"]
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
        .contains(enteredKeyword.toUpperCase()) || row["customerNumber"]
        .toString()
        .toUpperCase()
        .contains(enteredKeyword.toUpperCase())||  row["EmployeeName"]
        .toString()
        .toUpperCase()
        .contains(enteredKeyword.toUpperCase()))).toList() ;
    setState(() {
      searchListOfLeads = List<Map<String, dynamic>>.from(data);
      searchListOfLeads1 = data1;
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

  String getVerifiedBy(Map<String, dynamic> lead) {
    if (lead["VerificationStatus"] == "Push Back") {
      return "Pending with RO";
    } else if (lead["VerificationStatus"] == "Sent for Verification" && lead["VerifiedBy"] == "Pending with CM") {
      return "Pending with CM";
    } else if (lead["VerificationStatus"] == "Sent for Verification") {
      return "Pending with SM";
    } else if (lead["VerificationStatus"] == "Verified") {
      return "Verified";
    } else {
      return "Pending with SM";
    }
  }

  Color getVerifiedByColor(Map<String, dynamic> lead) {
    if (lead["VerificationStatus"] == "Push Back") {
      return Colors.red;
    } else if (lead["VerificationStatus"] == "Verified") {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    fetchdata();
    super.initState();
    fetchFCMdata();
    _startDateController.text = formatDate(DateTime.now().toLocal().toString());
    _endDateController.text = formatDate(DateTime.now().toLocal().toString());
    Future.delayed(Duration(seconds: 1), () {
      loadData();
    });
  }
  void loadData() {
    setState(() {
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        // Navigate to CreditManagerPageView when back button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreditManagerPageView(),
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(),
                  ),
                      (route) => false,
                );
              },
              child:  Icon(Icons.logout, size: 30,color: Colors.white,),),
          ),
          title: Text("Lead Details",style: TextStyle(color: Colors.white,fontSize: 18, fontWeight: FontWeight.bold,),),
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
                     String countText =  ManagerName.toString();
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
                  SizedBox(
                    width: width * 0.05,
                  ),
                  buildButton('Pending', fetchdata),
                  SizedBox(width: width * 0.01),
                  buildButton('Queried', fetchdata2),
                  SizedBox(width: width * 0.01),
                  buildButton('Verified', fetchdata1),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(10),
                              //   color: Colors.black,
                              // ),
                              child: Center(
                                child: Text(
                                  countText,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: StyleData.appBarColor2,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
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
              SizedBox(
                height: height * 0.01,
              ),
              _isLoading ?
              Column(
                children: List.generate(5, (index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.black12,
                    highlightColor: Colors.white70,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 20,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  height: 20,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: 10),
                                Container(
                                  width: 100,
                                  height: 20,
                                  color: Colors.grey[300],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              )
                  :
              SizedBox(
                height: height * 0.9,
                width: MediaQuery.of(context).size.width,
                child:ListOfLeads.isNotEmpty ?
                Scrollbar(
                  thickness: 8.5,
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  controller:_scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: searchKEY.text.isEmpty
                        ? ListOfLeads.length
                        : searchListOfLeads.length,

                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                      searchKEY.text.isEmpty ?  ListOfLeads[index] as Map<String, dynamic> : searchListOfLeads[index]
                      as Map<String, dynamic>;
                      ListOfLeads.sort((a, b) =>
                          (b['createdDateTime'] as Timestamp).compareTo(a['createdDateTime'] as Timestamp));
                      return
                        InkWell(
                          onTap: () {
                          },
                          child: Container(
                          //  margin: EdgeInsets.only(bottom: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius:1,
                                  blurRadius: 2,
                                  offset: Offset(0,1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: width * 0.01,
                                        ),
                                        Text(
                                          searchKEY.text.isEmpty
                                              ? ListOfLeads[index]["EmployeeName"]
                                              : searchListOfLeads[index]["EmployeeName"],
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
                                              width: width * 0.05,
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
                                                      : searchListOfLeads[index]["firstName"] + " " + searchListOfLeads[index]["lastName"],
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
                                            SizedBox(
                                              width: width * 0.05,
                                            ),
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Mobile Number",
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
                                                      ? ListOfLeads[index]["customerNumber"]
                                                      : searchListOfLeads[index]["customerNumber"],
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
                                              width: width * 0.03,
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                if (data.containsKey(
                                                    'Application_Form')) {
                                                  docId = data[
                                                  'Application_Form'].toString();
                                                }
                                                if (data.containsKey(
                                                    'Bank_Passbook')) {
                                                  docId =
                                                  "$docId,${data['Bank_Passbook'].toString()}";
                                                }
                                                if (data.containsKey(
                                                    'Date_Of_Birth')) {
                                                  docId =
                                                      "$docId,${data['Date_Of_Birth'].toString()}" ?? "";
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
                                                data.forEach((key, value) {
                                                  List<String> parts = key.split("-");
                                                  if (parts.isNotEmpty && parts.last == "checklist") {
                                                    if (docId != null && docId!.isNotEmpty) {
                                                      docId = "$docId,$value";
                                                    } else {
                                                      docId = value ?? ''; // Assign value if it's not null, otherwise empty string
                                                    }
                                                    // docId = "$docId,${value}";
                                                    // print(value.runtimeType);
                                                  }
                                                });
                                                // print(data);
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
                                                            ? "${data['firstName']+"" +data['lastName']}.zip"
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
                                                            ? "${data['firstName']+"" +data['lastName']}.${mime.toString().split("/").last}"
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
                                            print("hdshfkshg");
                                            if (ListOfLeads[index]['VerificationStatus'] != "Push Back" || searchListOfLeads[index]['VerificationStatus'] != "Push Back" )
                                              {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => CreditDocumentPageView(
                                                          leadID : searchKEY.text.isEmpty ? ListOfLeads[index]['LeadID'] : searchListOfLeads[index]['LeadID'] ,
                                                          technicalStatus : searchKEY.text.isEmpty
                                                              ? ListOfLeads[index]["technicalChecklistStatus"] ?? "Pending"
                                                              : searchListOfLeads[index]["technicalChecklistStatus"] ?? "Pending",
                                                          docId: searchKEY.text.isEmpty ? ListOfLeads1[index].id: searchListOfLeads1[index].id,
                                                          token:  searchKEY.text.isEmpty ? employeeFCMTokens[ListOfLeads[index]['EmployeeCode']].toString() ?? "" :employeeFCMTokens[searchListOfLeads[index]['EmployeeCode']].toString() ?? "",
                                                        )));
                                                print(employeeFCMTokens[ListOfLeads[index]['EmployeeCode']]);
                                              }
                                            else {
                                              CustomSnackBar.errorSnackBarQ("Navigation is disabled for leads with 'Push Back' status.", context);

                                            }

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
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Document Status",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            Card(
                                              child: Container(
                                                width: width * 0.065,
                                                height: height * 0.1,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Align(
                                                    alignment : Alignment.center,
                                                    child: Text(
                                                      technicalChecklistStatus = searchKEY.text.isEmpty
                                                          ? ListOfLeads[index]["technicalChecklistStatus"] ?? "Pending"
                                                          : searchListOfLeads[index]["technicalChecklistStatus"] ?? "Pending",
                                                      style: TextStyle(
                                                        color: Colors.orange,
                                                        fontSize: 14.0,
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                  ),

                                                ),
                                              ),
                                            )

                                          ],
                                        ),

                                        // Column(
                                        //   crossAxisAlignment: CrossAxisAlignment.center,
                                        //   children: [
                                        //     Text(
                                        //       "Status",
                                        //       style: TextStyle(
                                        //         color: Colors.grey,
                                        //         fontSize: 14.0,
                                        //         fontWeight: FontWeight.w800,
                                        //         fontFamily: 'Poppins',
                                        //       ),
                                        //     ),
                                        //     ListOfLeads[index]["VerificationStatus"] == 'Verified' && ListOfLeads[index]["VerifiedBy"] == 'Verified' ?
                                        //     Card(
                                        //       child: Container(
                                        //         width: width * 0.053,
                                        //         color: Colors.white,
                                        //         child: Padding(
                                        //           padding: const EdgeInsets.all(8.0),
                                        //           child: Text(
                                        //             searchKEY.text.isEmpty ? ListOfLeads[index]["VerificationStatus"] : searchListOfLeads[index]["VerificationStatus"],
                                        //             style: TextStyle(
                                        //               color: Colors.green,
                                        //               fontSize: 14.0,
                                        //               fontFamily: 'Poppins',
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ) : Card(
                                        //       child: Container(
                                        //         width: width * 0.08,
                                        //         color: Colors.white,
                                        //         child: Padding(
                                        //           padding: const EdgeInsets.all(8.0),
                                        //           child: Text(
                                        //             searchKEY.text.isEmpty ? ListOfLeads[index]["VerificationStatus"] : searchListOfLeads[index]["VerificationStatus"],
                                        //             style: TextStyle(
                                        //               color: Colors.red,
                                        //               fontSize: 14.0,
                                        //               fontFamily: 'Poppins',
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     )
                                        //   ],
                                        // ),
                                        // Column(
                                        //   crossAxisAlignment: CrossAxisAlignment.center,
                                        //   children: [
                                        //     Text(
                                        //       "CM Status",
                                        //       style: TextStyle(
                                        //         color: Colors.grey,
                                        //         fontSize: 14.0,
                                        //         fontWeight: FontWeight.w400,
                                        //         fontFamily: 'Poppins',
                                        //       ),
                                        //     ),
                                        //     ListOfLeads[index]["VerificationStatus"] == 'Verified' ?
                                        //     Card(
                                        //       child: Container(
                                        //         width: width * 0.06,
                                        //         color: Colors.white,
                                        //         child: Padding(
                                        //           padding: const EdgeInsets.all(8.0),
                                        //           child: Text(
                                        //             searchKEY.text.isEmpty ? ListOfLeads[index]["VerificationStatus"] ?? "Pending" : searchListOfLeads[index]["VerificationStatus"] ?? "Pending",
                                        //             style: TextStyle(
                                        //               color:ListOfLeads[index]["VerificationStatus"] == 'Verified' ? Colors.green : Colors.red,
                                        //               fontSize: 14.0,
                                        //               fontFamily: 'Poppins',
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ) : Card(
                                        //       child: Container(
                                        //         width: width * 0.06,
                                        //         color: Colors.white,
                                        //         child: Padding(
                                        //           padding: const EdgeInsets.all(8.0),
                                        //           child: Text(
                                        //             searchKEY.text.isEmpty ? ListOfLeads[index]["VerificationStatus"] ?? "": searchListOfLeads[index]["VerificationStatus"] ?? "",
                                        //             style: TextStyle(
                                        //               color: Colors.red,
                                        //               fontSize: 14.0,
                                        //               fontFamily: 'Poppins',
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     )
                                        //   ],
                                        // ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Action Status",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            // ListOfLeads[index]["VerificationStatus"] == 'Verified' ?
                                            // Card(
                                            //   child: Container(
                                            //     width: width * 0.06,
                                            //     color: Colors.white,
                                            //     child: Padding(
                                            //       padding: const EdgeInsets.all(8.0),
                                            //       child: Text(
                                            //         searchKEY.text.isEmpty ? ListOfLeads[index]["VerificationStatus"] : searchListOfLeads[index]["VerificationStatus"],
                                            //         style: TextStyle(
                                            //           color: Colors.green,
                                            //           fontSize: 14.0,
                                            //           fontFamily: 'Poppins',
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ) :
                                            Card(
                                              child: Container(
                                                width: width * 0.06,
                                                height: height * 0.1,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Align(
                                                    alignment: getVerifiedBy(ListOfLeads[index]) == "Verified" ? Alignment.center :  Alignment.topCenter,
                                                    child: Text(
                                                      searchKEY.text.isEmpty
                                                          ? getVerifiedBy(ListOfLeads[index])
                                                          : getVerifiedBy(searchListOfLeads[index]),
                                                      style: TextStyle(
                                                        color: searchKEY.text.isEmpty
                                                            ? getVerifiedByColor(ListOfLeads[index])
                                                            : getVerifiedByColor(searchListOfLeads[index]),
                                                        fontSize: 14.0,
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                  ),

                                                ),
                                              ),
                                            )

                                          ],
                                        ),
                                        //     Column(
                                        //       crossAxisAlignment: CrossAxisAlignment.center,
                                        //       children: [
                                        //         Text(
                                        //           "CM Status",
                                        //           style: TextStyle(
                                        //             color: Colors.grey,
                                        //             fontSize: 14.0,
                                        //             fontWeight: FontWeight.w400,
                                        //             fontFamily: 'Poppins',
                                        //           ),
                                        //         ),
                                        //         ListOfLeads[index]["VerificationStatus"] == 'Verified' ?
                                        //         Card(
                                        //           child: Container(
                                        //             width: width * 0.06,
                                        //             color: Colors.white,
                                        //             child: Padding(
                                        //               padding: const EdgeInsets.all(8.0),
                                        //               child: Text(
                                        //                 searchKEY.text.isEmpty ? ListOfLeads[index]["VerificationStatus"] ?? "Pending" : searchListOfLeads[index]["VerificationStatus"] ?? "Pending",
                                        //                 style: TextStyle(
                                        //                   color:ListOfLeads[index]["VerificationStatus"] == 'Verified' ? Colors.green : Colors.red,
                                        //                   fontSize: 14.0,
                                        //                   fontFamily: 'Poppins',
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //           ),
                                        //         ) : Card(
                                        //           child: Container(
                                        //             width: width * 0.06,
                                        //             color: Colors.white,
                                        //             child: Padding(
                                        //               padding: const EdgeInsets.all(8.0),
                                        //               child: Text(
                                        //                 searchKEY.text.isEmpty ? ListOfLeads[index]["VerificationStatus"] ?? "": searchListOfLeads[index]["VerificationStatus"] ?? "",
                                        //                 style: TextStyle(
                                        //                   color: Colors.red,
                                        //                   fontSize: 14.0,
                                        //                   fontFamily: 'Poppins',
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //           ),
                                        //         )
                                        //       ],
                                        //     )
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
  String selectedButton = 'Pending';

  void handleButtonClick(String buttonName) {
    setState(() {
      selectedButton = buttonName;
    });
  }

  Widget buildButton(String buttonName, Function() fetchData) {
    bool isSelected = selectedButton == buttonName;
    double width = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: isSelected ? width * 0.1 : width * 0.1,
      height: isSelected ? 35 : 30,
      child: ElevatedButton(
        onPressed: () {
          handleButtonClick(buttonName);
          fetchData();
        },
        style: ElevatedButton.styleFrom(
          primary: isSelected ? Colors.green.shade500 : StyleData.buttonColor, // Ensure `StyleData` is properly defined
        ),
        child: Text(
          buttonName,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSelected ? 16 : 14,
            fontFamily: StyleData.boldFont, // Ensure `StyleData` is properly defined
          ),
        ),
      ),
    );
  }
}
