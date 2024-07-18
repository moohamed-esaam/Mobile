import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../model/file_info.dart';
import 'login_screen.dart';

List<FileInfo> failedUpload = [];
int pickedFilesLength = 0;

class UploadExcel extends StatefulWidget {
  const UploadExcel({super.key});

  @override
  State<UploadExcel> createState() => _UploadExcelState();
}

class _UploadExcelState extends State<UploadExcel> {
  TextEditingController msgController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void showLoadingAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('جاري رفع البيانات'),
          content: SizedBox(
            width: 100.0, // Set the width of the dialog
            height: 100.0, // Set the height of the dialog
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

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
        centerTitle: true, // هنا يتم توسيط العنوان
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            Center(
              child: SizedBox(
                height: 40,
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    pickFilesAndUpload();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  child: Text(
                    'اختيار الملفات',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 80,
              width: 280,
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "عنوان الاشعار"),
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              height: 80,
              width: 350,
              child: TextField(
                controller: msgController,
                decoration: InputDecoration(
                  labelText: "تفاصيل الشعار",
                ),
              ),
            ),
            Center(
              child: SizedBox(
                height: 40,
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    sendNotification();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  child: Text(
                    'إرسال إشعار',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 50,
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xff44546a),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                        (_) => false,
                  );
                },
                child: Text('تسجيل الخروج', style: TextStyle(fontSize: 20)),
              ),
            ),
            SizedBox(height: 20),
            failedUpload.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'تم رفع الملفات ما عدا الآتي :',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                : SizedBox(),
            MyListView(),
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
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickFilesAndUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      List<PlatformFile> files = result.files;
      pickedFilesLength = files.length;

      showLoadingAlertDialog(context);

      for (int i = 0; i < files.length; i++) {
        print('File name: ${files[i].name}');
        print('File size: ${files[i].size}');
        print('File path: ${files[i].path}');

        await uploadFileToFirebase(files[i], i == files.length - 1);
      }

      Navigator.pop(context); // Close the loading dialog after upload completes
    } else {
      // User canceled the picker
    }
  }

  Future<void> uploadFileToFirebase(PlatformFile file, bool isLastFile) async {
    if (file.path == null) return;

    File fileToUpload = File(file.path!);
    final storageRef = FirebaseStorage.instance.ref().child('${file.name}');

    try {
      await storageRef.getDownloadURL();
      await storageRef.delete();
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
      } else {
        print(e);
        return;
      }
    }

    try {
      await storageRef.putFile(fileToUpload);
      String downloadURL = await storageRef.getDownloadURL();
      print('Download URL: $downloadURL');

      if (isLastFile) {
        showUploadAllCustomDialog(
          context,
          "رفع الملفات",
          failedUpload.isEmpty ? "تم رفع جميع الملفات بنجاح" : "فشل رفع جميع الملفات",
        );
      }
    } catch (e) {
      print(e);
      failedUpload.add(
        FileInfo(
          name: '${file.name}',
          uploaded: false,
          msg: "لم يتم رفع الملف بنجاح",
        ),
      );
      if (isLastFile) {
        showFailedFilesUploadCustomDialog(context);
      }
    }
  }

  void showFailedFilesUploadCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تم رفع الملفات ما عدا الآتي :'),
          content: SizedBox(
            width: 300.0, // Set the width of the dialog
            height: 400.0, // Set the height of the dialog
            child: MyListView(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showUploadAllCustomDialog(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 300.0, // Set the width of the dialog
            height: 400.0, // Set the height of the dialog
            child: Text(msg),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('حسنا'),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendNotification() async {
    final accJson = await rootBundle.loadString('assets/super-chicken-app-9f39ebbec74c.json');
    final servAcc = ServiceAccountCredentials.fromJson(json.decode(accJson));

    final client = await clientViaServiceAccount(servAcc, [
      'https://www.googleapis.com/auth/firebase.messaging',
    ]);

    String key = (await client.credentials.accessToken).data;
    String proj = 'super-chicken-app';
    final String endpoint = 'https://fcm.googleapis.com/v1/projects/$proj/messages:send';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $key',
      },
      body: jsonEncode({
        "message": {
          "topic": "allDevices",
          "notification": {
            "title": titleController.text,
            "body": msgController.text,
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      print("تم إرسال الإشعار بنجاح");
      titleController.text = "";
      msgController.text = "";
    } else {
      print("فشل في إرسال الإشعار: ${response.body}");
      titleController.text = "";
      msgController.text = "";
    }
  }
}

class MyListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: failedUpload.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            failedUpload[index].name,
            style: TextStyle(fontSize: 20),
          ),
        );

      },

    );
  }
}

class FileInfo {
  final String name;
  final bool uploaded;
  final String msg;

  FileInfo({required this.name, required this.uploaded, required this.msg});
}

