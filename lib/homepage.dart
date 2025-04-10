// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider_ex2/path_provider_ex2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timboo/loginpage.dart';
import 'package:timboo/video_list.dart';
import 'package:timboo/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  );

  @override
  void initState() {
    super.initState();
    downloadJsonFile();
  }

  Future<void> downloadJsonFile() async {
    try {
      Dio dio = Dio();
      var storage = await PathProviderEx2.getStorageInfo();
      var rootDir = storage[0].rootDir;

      await dio.download(
        'https://www.timboocafe.com/VideoGetir.aspx',
        '$rootDir/teknobay/data.json',
      );
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(left: 20),
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('assets/home.jpg'),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 9.5,
            right: MediaQuery.of(context).size.width / 2.2,
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    saveLanguage("TR");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VideoList(),
                      ),
                    );
                  },
                  child: RotationTransition(
                    turns: _animation,
                    child: const Text(
                      'TR',
                      style: TextStyle(
                        fontFamily: 'VAGRoundedStd',
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
                betweenSpace,
                const Text(
                  '/',
                  style: TextStyle(
                    fontFamily: 'VAGRoundedStd',
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                  ),
                ),
                betweenSpace,
                InkWell(
                  onTap: () {
                    saveLanguage("EN");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VideoList(),
                      ),
                    );
                  },
                  child: RotationTransition(
                    turns: _animation,
                    child: const Text(
                      'EN',
                      style: TextStyle(
                        fontFamily: 'VAGRoundedStd',
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20, 
            right: 20,
            child: InkWell(
              onTap: () => logout(context),
              child: const Column(
                children: [
                  Icon(
                    Icons.logout,
                    size: 40,
                    color: Color.fromARGB(255, 169, 153, 105),
                  ),
                  Text(
                    'Çıkış Yap',
                    style: TextStyle(
                      fontFamily: 'VAGRoundedStd',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(255, 169, 153, 105),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void saveLanguage(String lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("lang", lang);
  }
}
