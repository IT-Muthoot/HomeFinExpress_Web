import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:homefin_express_web/Utils/StyleData.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'dart:typed_data';

import 'LoginPageView.dart';

class AdminPageView extends StatefulWidget {
  @override
  _AdminPageViewState createState() => _AdminPageViewState();
}

class _AdminPageViewState extends State<AdminPageView> {
  List<Map<String, dynamic>> excelData = [];
  bool fileUploaded = false;
  String errorMessage = '';

  Future<void> _pickAndReadExcelFile() async {
    // Open file picker
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      try {
        // Read the file as bytes
        Uint8List? fileBytes = result.files.single.bytes;

        if (fileBytes != null) {
          // Decode the Excel file
          var decoder = SpreadsheetDecoder.decodeBytes(fileBytes);

          // Get data from the first sheet
          var table = decoder.tables.keys.first;
          var rows = decoder.tables[table]!.rows;

          // Assume the first row contains the headers
          List<String> headers = rows.first.map((header) => header.toString()).toList();

          // Map each subsequent row to the headers
          setState(() {
            excelData = rows.sublist(1).map((row) {
              return Map.fromIterables(headers, row);
            }).toList();

            fileUploaded = true;
            errorMessage = '';
          });

          // Show a SnackBar on successful upload
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('File uploaded successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Handle and display error
        setState(() {
          fileUploaded = false;
          errorMessage = 'Failed to read the Excel file: $e';
        });

        // Optionally log the error for debugging
        print('Error reading Excel file: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: StyleData.appBarColor2,
        leading: Padding(
          padding: const EdgeInsets.all(19.0),
          child: InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
                    (route) => false,
              );
            },
            child: Icon(
              Icons.logout,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          "Admin",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _pickAndReadExcelFile,
              icon: Icon(Icons.upload_file),
              label: Text('Upload Excel File'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            if (fileUploaded)
              Text(
                'File uploaded successfully!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            SizedBox(height: 20),
            if (excelData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: excelData.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> row = excelData[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('EMP_CODE: ${row['EMP_CODE'] ?? 'N/A'}'),
                            Text('NAME: ${row['NAME'] ?? 'N/A'}'),
                            Text('DSGN_NAME: ${row['DSGN_NAME'] ?? 'N/A'}'),
                            Text('BRANCH: ${row['BRANCH'] ?? 'N/A'}'),
                            Text('BRANCH CODE: ${row['BRANCH CODE'] ?? 'N/A'}'),
                            Text('REGION CODE: ${row['REGION CODE'] ?? 'N/A'}'),
                            Text('REGION: ${row['REGION'] ?? 'N/A'}'),
                            Text('ZONE CODE: ${row['ZONE CODE'] ?? 'N/A'}'),
                            Text('ZONE: ${row['ZONE'] ?? 'N/A'}'),
                            Text('Reporting Manager Code: ${row['Reporting Manager Code'] ?? 'N/A'}'),
                            Text('Reporting Manager Name: ${row['Reporting Manager Name'] ?? 'N/A'}'),
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
    );
  }
}


