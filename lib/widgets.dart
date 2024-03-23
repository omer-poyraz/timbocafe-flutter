import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timboo/api.dart';
import 'package:timboo/homepage.dart';
import 'package:timboo/loginpage.dart';

Widget get bottomSpace => const SizedBox(height: 10);
Widget get bottomSpacee => const SizedBox(height: 20);
Widget get bottomSpaceee => const SizedBox(height: 30);
Widget get bottomSpaceeee => const SizedBox(height: 30);
Widget get betweenSpaceeee => const SizedBox(width: 30);
Widget get betweenSpaceee => const SizedBox(width: 30);
Widget get betweenSpacee => const SizedBox(width: 20);
Widget get betweenSpace => const SizedBox(width: 10);

loginControl(BuildContext context, String userName, String password) async {
  if (userName == Api.userName) {
    if (password == Api.password) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('kullaniciadi', userName);
      prefs.setString('sifre', password);

      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else {
      return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Hatalı Giriş',
              style: TextStyle(
                fontFamily: 'VAGRoundedStd',
              ),
            ),
            content: const SingleChildScrollView(
              child: Text(
                'Kullanıcı Adınız ve / veya Şifreniz hatalı. Lütfen tekrar deneyiniz!',
                style: TextStyle(
                  fontFamily: 'VAGRoundedStd',
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Tamam'),
              ),
            ],
          );
        },
      );
    }
  } else {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Hatalı Giriş',
            style: TextStyle(
              fontFamily: 'VAGRoundedStd',
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Kullanıcı Adınız ve / veya Şifreniz hatalı. Lütfen tekrar deneyiniz!',
              style: TextStyle(
                fontFamily: 'VAGRoundedStd',
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}

Future createFolder() async {
  var dir = await getExternalStorageDirectory();
  if (!Directory("${dir!.path}/teknobay").existsSync()) {
    Directory("${dir.path}/teknobay").createSync(recursive: true);
  }
}

authentication(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString('kullaniciadi') == Api.userName) {
    if (prefs.getString('sifre') == Api.password) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: ((context) => const HomePage()),
        ),
      );
    }
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}
