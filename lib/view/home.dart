import 'dart:io';

import 'package:employee_info/main.dart';
import 'package:employee_info/model/emp_info_item.dart';
import 'package:employee_info/view/login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'emp_info.dart';

class HomeScreen extends StatelessWidget {
  String empCode;
  HomeScreen({required this.empCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text(
          ' سلسلة سوبر ماركت اميرة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,

      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(
                    onPressed: () {
                      showData(context, "data.xlsx", "الرواتب");
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.redAccent),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    child: Text(
                      'الرواتب',
                      style: TextStyle(fontSize: 20),
                    ))),
            SizedBox(height: 20),
            SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(
                    onPressed: () {
                      showData(context, "giftcard.xlsx", "بطاقات الشراء");
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.redAccent),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    child:
                        Text('بطاقات الشراء', style: TextStyle(fontSize: 20)))),
            SizedBox(height: 20),

            SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(
                    onPressed: () {
                      showData(context, "attendance.xlsx", "الحضور");
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.redAccent),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    child: Text('الحضور', style: TextStyle(fontSize: 20)))),
            SizedBox(height: 75),
            SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent),
                    onPressed: () {
                      sharedPreferences?.clear().then((_) =>
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                              (_) => false));
                    },
                    child:

                        Text('تسجيل الخروج', style: TextStyle(fontSize: 20)

                        )
                )
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 45.0,
        color: Colors.redAccent,
        child: Container(
          child: Center(
            child: Text(
              'Mohammed Ali',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  showData(context, String fileName, screenTitle) async {
    _downloadExcelFile(fileName).then((value) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => EmpInfoScreen(
                items: getEmpInfoItem(_readExcelFile(value, empCode)),
                title: screenTitle,
              )));
    });
  }

  Future<String> _downloadExcelFile(String myFile) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(myFile);

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/$myFile';

    File downloadToFile = File(filePath);
    await ref.writeToFile(downloadToFile);

    return filePath;
  }

  List _readExcelFile(String filePath, String empCode) {
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    List loggedEmpInfo = [];

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        if (row[0] == null || row[1] == null) {
          continue;
        }

        try {
          if ((double.tryParse(row[0]!.value.toString())?.truncate())
                  .toString() ==
              empCode) {
            loggedEmpInfo.add(excel.tables[table]!.rows.first);
            loggedEmpInfo.add(row);
            return loggedEmpInfo;
          }
        } catch (e) {
          print(e);
        }
      }
    }

    return loggedEmpInfo;
  }

  List<EmpInfoItem> getEmpInfoItem(List loggedEmpInfo) {
    List<EmpInfoItem> empInfoItemList = [];

    if (loggedEmpInfo.isNotEmpty) {
      for (int index = 0; index < loggedEmpInfo[0].length; index++) {
        var empInfoItem = EmpInfoItem(
            title: loggedEmpInfo[0][index].value.toString(),
            value: loggedEmpInfo[1][index].value.toString());
        empInfoItemList.add(empInfoItem);
      }
    }

    return empInfoItemList;
  }
}
