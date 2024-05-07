import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Utils/StyleData.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key, required this.title});

  final String title;

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: StyleData.appBarColor,
        title: Center(
            child: Text(
              widget.title,
              style: TextStyle(
                color: StyleData.appBarColor3,
              ),
            )
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 12.0,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Text(
                    'The Mobile App for Sales (Homefin Express) is developed by (Muthoot IT – CO South) for the exclusive use of the Sales staff who is working at various branches of Muthoot Homefin India Ltd by using the Employee Code and password given to them by the company. Nobody other than Branch Staff of Muthoot Homefin India Ltd can login to this application unless the Employee Code and password are provided to them by the company.'),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Text(
                    'This privacy policy is to provide information to you, our client, on how your personal data is gathered and used within our practice, and the circumstances in which we may share it with third parties.'),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Text(
                    'We use your Personal Information only for furnishing and improving the App. By using the app Homefin express, you accord to the collection and use of data in accordance with this policy.'),
              ),
            ),

            SizedBox(
              height: 12.0,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Text(
                    'WHAT INFORMATION DO WE COLLECT?',
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
                    'We collect information from you when you register on our app, site, place an order, subscribe to our newsletter, respond to a survey, fill out a form. When ordering or registering on our app or site, as appropriate, you may be asked to enter you’re: name, e-mail address, mailing address, phone number, and personal details.'),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Text(
                    'Personal data collected directly from you:'),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Text(
                    'This type of data is the personal data you provide us. You consent to provide us access to such personal data through your continued use of the Services or through interaction over the Platform. This includes:'),
              ),
            ),

            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: Text(
                    'Contact data: This includes your email addresses, phone numbers, and postal address.'),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: Text(
                    'Identity and Profile-related Data: This includes personal information concerning the personal or material circumstances of an identified or identifiable User, e.g. name, gender, date of birth, password, password validation, employment verification information and other similar details shared via the Platform.'),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: Text(
                    'KYC data: In connection with the Services and your use of the Platform, we may also require you to share, or we may collect identification documents issued by government or other authorities to you, including details of or pertaining to Aadhaar, PAN card, voter ID, and ration card.'),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: Text(
                    'Financial data: This will include your past credit history, income details, details of loans issued, or otherwise applied for through the Platform, payments and repayments thereof, your bank account details and bank account statements.'),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: Text(
                    'Personal data collected through your use of the Platform and from your device'),
              ),
            ),

            SizedBox(
              height: 12.0,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Text(
                    'WHAT DO WE USE YOUR INFORMATION FOR?',
                    style : TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    )
                ),
              ),
            ),
            SizedBox(
              height: 2.0,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'To personalize your experience (your information helps us to better respond to your individual needs)'
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'To improve our App (we continually strive to improve our App offerings based on the information and feedback we receive from you)'
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'To improve customer service (your information helps us to more effectively respond to your customer service requests and support needs)'
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'To process transactions your information, whether public or private, will not be sold, exchanged, transferred, or given to any other company for any reason whatsoever, without your consent, other than for the express purpose of delivering the purchased product or service requested.'
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'To administer a contest, promotion, survey or other site feature'
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'To send periodic emails'
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'The email address you provide may be used to send you information, respond to inquiries, and/or other requests or questions.'
                ),
              ),
            ),

            SizedBox(
              height: 12.0,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Text(
                    'DO WE DISCLOSE ANY INFORMATION TO OUTSIDE PARTIES?',
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
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                    'We do not sell, trade, or otherwise transfer to outside parties your personally identifiable information. This does not include trusted third parties who assist us in operating our App, conducting our business, or servicing you, so long as those parties agree to keep this information confidential. We may also release your information when we believe release is appropriate to comply with the law, enforce our app policies, or protect ours or others rights, property, or safety. However, non-personally identifiable visitor information may be provided to other parties for marketing, advertising, or other uses.'),
              ),
            ),

            SizedBox(
              height: 12.0,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Text(
                    'DO WE USE COOKIES?',
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
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                    'No we are not using cookies.'),
              ),
            ),
            SizedBox(
              height: 12.0,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Text(
                    'HOW DO WE PROTECT YOUR INFORMATION?',
                    style : TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    )
                ),
              ),
            ),
            SizedBox(height: 8.0,),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'We implement a variety of security measures to maintain the safety of your personal information when you enter, submit, or access your personal information.'),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'If we make any material changes to this Privacy Policy, we will notify you either through the email address you have provided us, or by placing a prominent notice on our App.'),
              ),
            ),


            SizedBox(height: 30.0,),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'Contact Us'),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'If you have any questions about this Privacy Policy, please contact us.'),
              ),
            ),
            SizedBox(height: 30.0,),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'Phone: 022-41010916'),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set container width to 60% of screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'Email: applicationsupport@muthoothomefin.com”'),
              ),
            ),

            SizedBox(
              height: 100.0,
            ),

          ],
        ),
      ),
    );
  }
}