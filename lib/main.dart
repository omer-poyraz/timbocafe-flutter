// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timboo/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
      overlays: []);

  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timboo Cafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'VAGRoundedStd'),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  permission() async {
    var permissionStatus = await Permission.storage.status;

    if (permissionStatus != PermissionStatus.granted) {
      PermissionStatus permissionStatus = await Permission.storage.request();
      setState(() {
        permissionStatus = permissionStatus;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    () async {
      var permissionStatus = await Permission.storage.status;
      var permissionStatus2 = await Permission.manageExternalStorage.request();

      if (permissionStatus != PermissionStatus.granted) {
        PermissionStatus permissionStatus = await Permission.storage.request();
        setState(() {
          permissionStatus = permissionStatus;
        });
      }
      if (permissionStatus2 != PermissionStatus.granted) {
        PermissionStatus permissionStatus2 =
            await Permission.manageExternalStorage.request();
        setState(() {
          permissionStatus2 = permissionStatus2;
        });
      }
    }();

    createFolder();

    Future.delayed(const Duration(milliseconds: 1), () {
      authentication(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
