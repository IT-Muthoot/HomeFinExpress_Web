import 'package:flutter/material.dart';


import 'Utils/StyleData.dart';

class TermsAndConditionsView extends StatefulWidget {
  const TermsAndConditionsView({super.key});

  @override
  State<TermsAndConditionsView> createState() => _TermsAndConditionsViewState();
}

class _TermsAndConditionsViewState extends State<TermsAndConditionsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: StyleData.appBarColor,
        title: Center(
            child: Text(
              "Terms and Conditions",
              style: TextStyle(
                color: StyleData.appBarColor3,
              ),
            )
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.0,),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '1. Introduction',
                      style : TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      )
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      'These Terms and Conditions govern your use of the Homefin Express App ("the App"), developed by Muthoot Team. By accessing or using the App, you agree to be bound by these Terms and Conditions. If you do not agree with any part of these Terms and Conditions, you must not use the App.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '2. Use of the App',
                      style : TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      )
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- The App is intended for use by Muthoot Homefin staff only and is to be used solely for the purpose of collecting customer details for home loan applications.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- You must not use the App for any unlawful or prohibited purpose.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '3. Data Collection and Privacy',
                      style : TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      )
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- The App collects customer details, including Aadhaar and PAN information, for the purpose of processing home loan applications.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- All data collected through the App is subject to the Company\'s Privacy Policy, which can be found on the Company\'s website.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '4. Security',
                      style : TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      )
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- You are responsible for maintaining the confidentiality of your login information and for all activities that occur under your account.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- You must notify the Company immediately of any unauthorized use of your account or any other breach of security.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '5. Intellectual Property',
                      style : TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      )
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- The App and all intellectual property rights related to it are owned by the Company.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- You may not reproduce, modify, distribute, or otherwise use any part of the App without the Company\'s prior written consent.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '6. Disclaimer',
                      style : TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      )
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- The Company makes no warranties or representations about the accuracy or completeness of the information provided through the App.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- The Company shall not be liable for any loss or damage arising from your use of the App.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '7. Changes to Terms and Conditions',
                      style : TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      )
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- The Company reserves the right to change these Terms and Conditions at any time without notice.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- Your continued use of the App after any such changes shall constitute your acceptance of the revised Terms and Conditions.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '8. Governing Law',
                      style : TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      )
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- These Terms and Conditions are governed by the laws of India.'),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  child: Text(
                      '- Any disputes arising out of or in connection with these Terms and Conditions shall be subject to the exclusive jurisdiction of the courts in India.'),
                ),
              ),


              SizedBox(height: 40.0,),

              SizedBox(
                height: 60.0,
              ),

            ],
          ),
        ),
      ),
    );
  }
}