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
import 'package:shimmer/shimmer.dart';

import '../Utils/StyleData.dart';
import 'LoginPageView.dart';
import 'Utils/CustomeSnackBar.dart';
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
  List<Map<String, dynamic>> ListOfLeads = [];
  List<DocumentSnapshot> ListOfLeadsId = [];
  List<DocumentSnapshot> ListOfLeads1 = [];
  TextEditingController searchKEY = TextEditingController();
  String? ManagerName;
  String? BranchCode;
  String? EmployeeName;
  String? Designation;
  String VerificationStatus = "Pending";
  String? technicalChecklistStatus;
  Map<dynamic, String> employeeFCMTokens = {};
  var fcmToken;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  String? LeadStatus;
  String? LeadCreatedDateTime;
  Map<String, String> leadStatuses = {};


  Future<void> getToken()
  async {
    var headers = {
      'X-PrettyPrint': '1',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': 'BrowserId=qnhrXMyBEe6lOh9ncfvoTw; CookieConsentPolicy=0:1; LSKey-c\$CookieConsentPolicy=0:1'
    };
    var data = {
      // 'grant_type': 'password',
      // 'client_id': '3MVG9WZIyUMp1ZfoWDelgr4puVA8Cbw2py9NcKnfiPbsdxV6CU1HXQssNTT2XpRFqPmQ8OX.F4ZbP_ziL2rmf',
      // 'client_secret': '4382921A497F5B4DED8F7E451E89D1228EE310F729F64641429A949D53FA1B84',
      // 'username': 'salesappuser@muthoothomefin.com',
      // 'password': 'Pass@123456F7aghs4Z5RxQ5hC2pktsSLJfq'
      'grant_type': 'password',
      'client_id': '3MVG9ct5lb5FGJTNKeeA63nutsPt.67SWB9mzXh9na.RBlkmz2FxM4KH31kKmHWMWQHD1y2apE9qmtoRtiQ9R',
      'client_secret': 'E9DDAF90143A7B4C6CA622463EFDA17843174AB347FD74A6905F853CD2406BDE',
      'username': 'itkrishnaprasad@muthootgroup.com.dev2',
      'password': 'Karthikrishna@1YSRHLEtF4pMRkpOd6aSCeVHDB'
    };
    var dio = Dio();
    var response = await dio.request(
      //   'https://muthootltd.my.salesforce.com/services/oauth2/token',
      'https://muthootltd--muthootdo.sandbox.my.salesforce.com/services/oauth2/token',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
      data: data,
    );

    String? accessToken;
    if (response.statusCode == 200) {

      String jsonResponse = json.encode(response.data);
      Map<String, dynamic> jsonMap = json.decode(jsonResponse);
      accessToken = jsonMap['access_token'];

      // Store the access token locally
      saveAccessToken(accessToken!);
      print("AccessToken");
      print(accessToken);
    }
  }
  Future<void> saveAccessToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('access_token', token);
    print("Stored Access token");
    print(token);
  }
  Future<void> getLeadStatus(String leadID)
  async {
    print(leadID);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var headers = {
      'Authorization':  'Bearer ${prefs.getString('access_token') ?? ''}',
      'Cookie': 'BrowserId=qnhrXMyBEe6lOh9ncfvoTw; CookieConsentPolicy=0:1; LSKey-c\$CookieConsentPolicy=0:1'
    };
    var data = '''''';
    var dio = Dio();
    var response = await dio.request(
      'https://muthootltd--muthootdo.sandbox.my.salesforce.com/services/apexrest/getLeadStatus/$leadID',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
      data: data,
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(response.data);
      var status = responseData['Status'];
      var createdTime = responseData['Date'];
      setState(() {
        // Update the status in the ListOfLeads
        ListOfLeads = ListOfLeads.map((lead) {
          if (lead["LeadID"] == leadID) {
            lead["leadStatus"] = status;
          }
          return lead;
        }).toList();
        LeadStatus = status;
        LeadCreatedDateTime = createdTime;
      });
      print(LeadStatus);
      print(LeadCreatedDateTime);
      print(json.encode(response.data));
    }
    else {
      print(response.statusMessage);
    }
  }


  void fetchAndPrintCampaignData() async {
    CollectionReference campaignCollection = FirebaseFirestore.instance.collection('employeeMapping');
    QuerySnapshot campaignSnapshot = await campaignCollection.get();

    List<Map<String, dynamic>> campaignList = campaignSnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();

    // Print each campaign document to the console
    campaignList.forEach((campaign) {
      print("Compaign");
      print(campaign);
    });
  }

  Future<void> fetchdata() async {
    CollectionReference users = FirebaseFirestore.instance.collection('convertedLeads');
    SharedPreferences pref = await SharedPreferences.getInstance();
    var managerEmployeeCode = pref.getString("employeeCode");
    setState(() {
      userType = pref.getString("logintype");
    });

    if (userType == "SalesManager") {
      users.where("ManagerCode", isEqualTo: managerEmployeeCode).get().then((value) {
        List<Map<String, dynamic>> filteredList = value.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data.containsKey("LeadID") &&
              (data["LeadID"] as String).length > 1 &&
              data.containsKey("VerificationStatus") &&
              data["VerificationStatus"] == "Sent for Verification"
              &&
              data.containsKey("VerifiedBy") &&
              data["VerifiedBy"] == "Pending with SM";
        }).map((doc) => doc.data() as Map<String, dynamic>).toList();

        List<DocumentSnapshot> filteredList1 = value.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return (data.containsKey("LeadID") && (data["LeadID"] as String).length > 1) &&
              (data.containsKey("VerificationStatus") && data["VerificationStatus"] == "Sent for Verification");
        }).toList();

        List<DocumentSnapshot> filteredList2 = filteredList1;
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
        // Call getLeadStatus for each lead
        for (var lead in filteredList) {
          getLeadStatus(lead["LeadID"]);
        }

        setState(() {
          ListOfLeads = filteredList;
          ListOfLeads1 = filteredList2;
          ListOfLeadsId = filteredList1;
          data = filteredList;
          ManagerName = pref.getString("ManagerName");
          BranchCode = filteredList.isNotEmpty ? filteredList[0]["homeFinBranchCode"] ?? "" : "";
          EmployeeName = filteredList.isNotEmpty ? filteredList[0]["EmployeeName"] ?? "" : "";
          Designation = filteredList.isNotEmpty ? filteredList[0]["Designation"] ?? "" : "";
        });
      });
    } else {
      users.get().then((value) {
        List<Map<String, dynamic>> filteredList = value.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data.containsKey("LeadID") &&
              (data["LeadID"] as String).length > 1 &&
              data.containsKey("VerificationStatus") &&
              data["VerificationStatus"] == "Sent for Verification";
        }).map((doc) => doc.data() as Map<String, dynamic>).toList();

        List<DocumentSnapshot> filteredList1 = value.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data.containsKey("LeadID") &&
              (data["LeadID"] as String).length > 1 &&
              data.containsKey("VerificationStatus") &&
              data["VerificationStatus"] == "Sent for Verification";
        }).toList();

        List<DocumentSnapshot> filteredList2 = filteredList1;
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
        // Call getLeadStatus for each lead
        for (var lead in filteredList) {
          getLeadStatus(lead["LeadID"]);
        }

        setState(() {
          ListOfLeads = filteredList;
          ListOfLeadsId = filteredList1;
          ListOfLeads1 = filteredList2;
        });
      });
    }
  }

  Future<void> fetchdata1() async {
    print("hgjhgjh");
    CollectionReference users = FirebaseFirestore.instance.collection('convertedLeads');
    SharedPreferences pref = await SharedPreferences.getInstance();
    var managerEmployeeCode = pref.getString("employeeCode");
    setState(() {
      userType = pref.getString("logintype");
    });

    if (userType == "SalesManager") {
      users.where("ManagerCode", isEqualTo: managerEmployeeCode).get().then((value) {
        List<Map<String, dynamic>> filteredList = value.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data.containsKey("LeadID") &&
              (data["LeadID"] as String).length > 1 &&
              ((data.containsKey("VerificationStatus") && data["VerificationStatus"] == "Verified")
                  ||
                  (data.containsKey("VerifiedBy") && data["VerifiedBy"] == "Pending with CM")
                  // ||
                  // (data.containsKey("SM Status") && data["SM Status"] == "Verified")
              );
        }).map((doc) => doc.data() as Map<String, dynamic>).toList();
        List<DocumentSnapshot> filteredList1 = value.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data.containsKey("LeadID") &&
              (data["LeadID"] as String).length > 1 &&
              data.containsKey("VerificationStatus") &&
              data["VerificationStatus"] == "Verified";
        }).toList();
        List<DocumentSnapshot> filteredList2 = filteredList1;
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
// Call getLeadStatus for each lead
        for (var lead in filteredList) {
          getLeadStatus(lead["LeadID"]);
        }
        setState(() {
          ListOfLeads = filteredList;
          ListOfLeads1 = filteredList2;
          ListOfLeadsId = filteredList1;
          ManagerName = pref.getString("ManagerName");
          BranchCode = filteredList.isNotEmpty ? filteredList[0]["homeFinBranchCode"] ?? "" : "";
          EmployeeName = filteredList.isNotEmpty ? filteredList[0]["EmployeeName"] ?? "" : "";
          Designation = filteredList.isNotEmpty ? filteredList[0]["Designation"] ?? "" : "";
        });
      });
    } else {
      users.get().then((value) {
        List<Map<String, dynamic>> filteredList = value.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data.containsKey("LeadID") &&
              (data["LeadID"] as String).length > 1 &&
              data.containsKey("VerificationStatus") &&
              data["VerificationStatus"] == "Verified";
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
// Call getLeadStatus for each lead
        for (var lead in filteredList) {
          getLeadStatus(lead["LeadID"]);
        }
        setState(() {
          ListOfLeads = filteredList;
        });
      });
    }
  }


  Future<void> fetchdata2() async {
    CollectionReference users = FirebaseFirestore.instance.collection('convertedLeads');
    SharedPreferences pref = await SharedPreferences.getInstance();
    var managerEmployeeCode = pref.getString("employeeCode");
    setState(() {
      userType = pref.getString("logintype");
    });

    if (userType == "SalesManager") {
      users.where("ManagerCode", isEqualTo: managerEmployeeCode).get().then((value) {
        List<Map<String, dynamic>> filteredList = value.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data.containsKey("LeadID") &&
              (data["LeadID"] as String).length > 1 &&
              data.containsKey("VerificationStatus") &&
              data["VerificationStatus"] == "Push Back" &&
              data.containsKey("QueryBy") &&
              data["QueryBy"] == "Query By SM";
        }).map((doc) => doc.data() as Map<String, dynamic>).toList();

        List<DocumentSnapshot> filteredList1 = value.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data.containsKey("LeadID") &&
              (data["LeadID"] as String).length > 1 &&
              data.containsKey("VerificationStatus") &&
              data["VerificationStatus"] == "Push Back";
        }).toList();

        List<DocumentSnapshot> filteredList2 = filteredList1;
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
        // Call getLeadStatus for each lead
        for (var lead in filteredList) {
          getLeadStatus(lead["LeadID"]);
        }
        setState(() {
          ListOfLeads = filteredList;
          ListOfLeads1 = filteredList2;
          ListOfLeadsId = filteredList1;
          data = filteredList;
          ManagerName = pref.getString("ManagerName");
          BranchCode = filteredList.isNotEmpty ? filteredList[0]["homeFinBranchCode"] ?? "" : "";
          EmployeeName = filteredList.isNotEmpty ? filteredList[0]["EmployeeName"] ?? "" : "";
          Designation = filteredList.isNotEmpty ? filteredList[0]["Designation"] ?? "" : "";
        });
      });
    } else {
      users.get().then((value) {
        List<Map<String, dynamic>> filteredList = value.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data.containsKey("LeadID") &&
              (data["LeadID"] as String).length > 1 &&
              data.containsKey("VerificationStatus") &&
              data["VerificationStatus"] == "Push Back" &&
              data.containsKey("QueryBy") &&
              data["QueryBy"] == "Query By SM";
        }).map((doc) => doc.data() as Map<String, dynamic>).toList();

        List<DocumentSnapshot> filteredList1 = value.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data.containsKey("LeadID") &&
              (data["LeadID"] as String).length > 1 &&
              data.containsKey("VerificationStatus") &&
              data["VerificationStatus"] == "Push Back";
        }).toList();

        List<DocumentSnapshot> filteredList2 = filteredList1;
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
        // Call getLeadStatus for each lead
        for (var lead in filteredList) {
          getLeadStatus(lead["LeadID"]);
        }
        setState(() {
          ListOfLeads = filteredList;
          ListOfLeadsId = filteredList1;
          ListOfLeads1 = filteredList2;
        });
      });
    }
  }


  Future<void> fetchFCMdata() async {
    CollectionReference users = FirebaseFirestore.instance.collection('convertedLeads');
    SharedPreferences pref = await SharedPreferences.getInstance();
    var managerEmployeeCode = pref.getString("employeeCode");

    setState(() {
      userType = pref.getString("logintype");
    });

    if (userType == "SalesManager") {
      users.where("ManagerCode", isEqualTo: managerEmployeeCode).get().then((value) {
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

  TextStyle getTextStyle(String status) {
    return TextStyle(
      color: status == "Verified" ? Colors.green : Colors.orange,
      fontSize: 14.0,
      fontFamily: 'Poppins',
    );
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
    getToken();
   // fetchAndPrintCampaignData();
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
          title: Text("Lead Details",style: TextStyle(color: Colors.white,fontSize: 18, fontWeight: FontWeight.bold, ),),
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
                      String countText = ManagerName?.toString() ?? '';
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
                        Builder(
                          builder: (context) {
                            String countText = searchKEY.text.isEmpty
                                ? ListOfLeads.length.toString()
                                : searchListOfLeads.length.toString();
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
                                    fontWeight: FontWeight.bold,
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
                  controller: _scrollController,
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
                            borderRadius: BorderRadius.circular(3.0),
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
                                          // Row(
                                          //   children: [
                                          //
                                          //     Text(
                                          //       "  Lead Status",
                                          //       style: TextStyle(
                                          //         color: Colors.black54,
                                          //         fontSize: 14.0,
                                          //         fontFamily: 'Poppins',
                                          //       ),
                                          //     ),
                                          //     Text(
                                          //       " - ",
                                          //       style: TextStyle(
                                          //         color: Colors.black26,
                                          //         fontSize: 16.0,
                                          //         fontWeight: FontWeight.bold,
                                          //       ),
                                          //     ),
                                          //     Text(
                                          //       ListOfLeads[index]["leadStatus"] ?? "",
                                          //       style: TextStyle(
                                          //         color: Colors.black54,
                                          //         fontSize: 14.0,
                                          //         fontFamily: 'Poppins',
                                          //       ),
                                          //     ),
                                          //   ],
                                          // )
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
                                          bool isSearchEmpty = searchKEY.text.isEmpty;
                                          bool isIndexValid = (isSearchEmpty && index < ListOfLeads.length && index < ListOfLeads1.length) ||
                                              (!isSearchEmpty && index < searchListOfLeads.length && index < searchListOfLeads1.length);
                                                  print(isIndexValid);
                                          if (isIndexValid) {
                                            var currentLead = isSearchEmpty ? ListOfLeads[index] : searchListOfLeads[index];
                                            var currentLead1 = isSearchEmpty ? ListOfLeads1[index] : searchListOfLeads1[index];
                                            var tokenKey = isSearchEmpty ? ListOfLeads[index]['EmployeeCode'] : searchListOfLeads[index]['EmployeeCode'];

                                            if (currentLead['VerificationStatus'] != "Push Back") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DocumentPageView(
                                                    leadID: currentLead['LeadID'],
                                                    docId: currentLead1.id,
                                                    token: employeeFCMTokens[tokenKey]?.toString() ?? "",
                                                    technicalStatus : searchKEY.text.isEmpty
                                                        ? ListOfLeads[index]["technicalChecklistStatus"] ?? "Pending"
                                                        : searchListOfLeads[index]["technicalChecklistStatus"] ?? "Pending",
                                                  ),
                                                ),
                                              );
                                              print(employeeFCMTokens[tokenKey]);
                                            } else {
                                              CustomSnackBar.errorSnackBarQ("Navigation is disabled for leads with 'Push Back' status.", context);
                                            }
                                          }
                                          else {
                                            print("Index out of range or lists are empty.");
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.visibility,
                                              color: Colors.red.shade300,
                                            ),
                                            Text(
                                              "View",
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
                                          )

                                        ],
                                      ),

                          // Column(
                          //           crossAxisAlignment: CrossAxisAlignment.center,
                          //           children: [
                          //             Text(
                          //               "Status",
                          //               style: TextStyle(
                          //                 color: Colors.grey,
                          //                 fontSize: 14.0,
                          //                 fontWeight: FontWeight.w800,
                          //                 fontFamily: 'Poppins',
                          //               ),
                          //             ),
                          //             ListOfLeads[index]["VerificationStatus"] == 'Verified' || ListOfLeads[index]["SM Status"] == 'Verified' || ListOfLeads[index]["VerifiedBy"] == 'Verified' ?
                          //             Card(
                          //               child: Container(
                          //                 width: width * 0.053,
                          //                 color: Colors.white,
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.all(8.0),
                          //                   child: Text(
                          //                     searchKEY.text.isEmpty ? ListOfLeads[index]["SM Status"] ?? "" : searchListOfLeads[index]["SM Status"] ?? "",
                          //                     style: TextStyle(
                          //                       color: Colors.green,
                          //                       fontSize: 14.0,
                          //                       fontFamily: 'Poppins',
                          //                     ),
                          //                   ),
                          //                 ),
                          //               ),
                          //             ) : Card(
                          //               child: Container(
                          //                 width: width * 0.08,
                          //                 color: Colors.white,
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.all(8.0),
                          //                   child: Text(
                          //                     searchKEY.text.isEmpty ? ListOfLeads[index]["VerificationStatus"] ?? "" : searchListOfLeads[index]["VerificationStatus"] ?? "",
                          //                     style: TextStyle(
                          //                       color: Colors.red,
                          //                       fontSize: 14.0,
                          //                       fontFamily: 'Poppins',
                          //                     ),
                          //                   ),
                          //                 ),
                          //               ),
                          //             )
                          //           ],
                          //         ),
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
                                            child:  Align(
                                              alignment:  getVerifiedBy(ListOfLeads[index]) == "Verified" ? Alignment.center :  Alignment.topCenter,
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
