import 'dart:io';
import 'package:employee_info/model/credentials.dart';
import 'package:employee_info/view/upload_excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_excel/excel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constant/app_keys.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _empCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' سلسلة سوبر ماركت اميرة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _empCodeController,
                decoration: InputDecoration(
                  labelText: 'كود الموظف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'من فضلك ادخل كود الموظف';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'الرقم السري',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'من فضلك ادخل الرقم السري';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _login();
                  }
                },
                child: Text('تسجيل الدخول'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size(double.infinity, 55.0),
                  ),
                ),
              ),
            ],
          ),
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

  void _login() async {
    // Check if either field is empty
    if (_empCodeController.text.isEmpty || _passwordController.text.isEmpty) {
      showCustomDialog(context, 'خطأ في تسجيل الدخول', 'يرجى ملء جميع الحقول');
      return;
    }

    showLoadingDialog(context);

    // Checking if the credentials are for admin
    if (_empCodeController.text == "admin" && _passwordController.text == "134679") {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => UploadExcel()),
            (_) => false,
      );
      return; // Exit the function if admin credentials are matched
    }

    // Normal login flow for employees
    var cred = await _readExcelFile(await _downloadExcelFile());

    for (var element in cred) {
      if (element.empCode == _empCodeController.text && element.password == _passwordController.text) {
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString(AppKeys.currentUserKey, element.empCode);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(empCode: element.empCode),
          ),
              (_) => false,
        );
        return; // Exit the function if employee credentials are matched
      }
    }

    // If no valid credentials were found, show error dialog
    Navigator.of(context).pop(); // Close loading dialog
    showCustomDialog(
      context,
      'خطأ في تسجيل الدخول',
      'خطأ في كود الموظف أو كلمة المرور',
    );
  }

  Future<String> _downloadExcelFile() async {
    String myFile = "username.xlsx";

    // Reference to the file in Firebase Storage
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(myFile);

    // Get the directory to save the file
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/$myFile';

    // Download the file
    File downloadToFile = File(filePath);
    await ref.writeToFile(downloadToFile);

    return filePath;
  }

  Future<List<EmpCredentials>> _readExcelFile(String filePath) async {
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    List<EmpCredentials> empCredentials = [];

    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows) {
        if (row.length >= 2 && row[0] != null && row[1] != null) {
          empCredentials.add(EmpCredentials(
            empCode: row[0]!.value.toString(),
            password: row[1]!.value.toString(),
          ));
        }
      }
    }

    return empCredentials;
  }

  void showCustomDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('حسناً'),
            ),
          ],
        );
      },
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('جاري تسجيل الدخول'),
          content: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  void dispose() {
    _empCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
