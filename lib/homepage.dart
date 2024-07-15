import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider_ex2/path_provider_ex2.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  var isLoading = true;
  var isLoading2 = false;
  var isDeleting = false;
  late int percentage = 0;
  dynamic jsonData;
  dynamic files;
  var filesName = "";
  var jsonDataList = [];
  var jsonDataListEn = [];
  var fileList = [];
  String progressString = 'Dosya İndirilmedi!!!';
  bool didDownloadPDF = false;
  double progress = 0;

  Future<void> downloadFile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Dio dio = Dio();
    var storage = await PathProviderEx2.getStorageInfo();
    var rootDir = storage[0].rootDir;
    var drc = Directory("$rootDir/teknobay");
    files = Directory(drc.path).listSync();

    await dio.download(
      'https://www.timboocafe.com/VideoGetir.aspx',
      '$rootDir/teknobay/data.json',
    );
    final File myFile = File('$rootDir/teknobay/data.json');
    jsonData = json.decode(myFile.readAsStringSync());

    if (jsonData.isNotEmpty) {
      await _processJsonData(prefs, dio, rootDir);
    }

    setState(() {
      isLoading2 = true;
    });
  }

  Future<void> _processJsonData(
      SharedPreferences prefs, Dio dio, String rootDir) async {
    for (var item in jsonData) {
      _processVideoFiles(item, 'Dosya', jsonDataList);
      _processVideoFiles(item, 'DosyaEn', jsonDataListEn);
    }

    for (var file in files) {
      fileList.add(file.path.split('/').last);
    }

    await _deleteUnnecessaryFiles(prefs, rootDir);
    await _downloadMissingFiles(prefs, dio, rootDir);
  }

  void _processVideoFiles(dynamic item, String key, List<dynamic> list) {
    var videoValues = item[key]?.toString().split(',') ?? [];
    for (var value in videoValues) {
      if (value.isNotEmpty) {
        list.add(value.split('/').last);
      }
    }
  }

  Future<void> _deleteUnnecessaryFiles(
      SharedPreferences prefs, String rootDir) async {
    for (var file in fileList) {
      var isFile = jsonDataList.contains(file);
      var isFileEn = jsonDataListEn.contains(file);
      if (!isFile && !isFileEn) {
        var fileExtension = file.split(".").last;
        if (!['json', 'png', 'jpg', 'jpeg'].contains(fileExtension)) {
          debugPrint("Dosya silindi!  ($file)");
          File('$rootDir/teknobay/$file').deleteSync();
          prefs.setBool(file, false);
        }
      }
    }
  }

  Future<void> _downloadMissingFiles(
      SharedPreferences prefs, Dio dio, String rootDir) async {
    for (var item in jsonData) {
      await _downloadFiles(item, 'Dosya', 'DosyaResim', prefs, dio, rootDir);
      await _downloadFiles(item, 'DosyaEn', 'DosyaResim', prefs, dio, rootDir);
    }
  }

  Future<void> _downloadFiles(dynamic item, String videoKey, String imageKey,
      SharedPreferences prefs, Dio dio, String rootDir) async {
    var value = item[imageKey]?.toString() ?? '';
    var subValue = value.substring(54);
    var videoValues = item[videoKey]?.toString().split(',') ?? [];

    if (value.isNotEmpty && !File('$rootDir/teknobay/$subValue').existsSync()) {
      await dio.download(
        'https://www.timboocafe.com/$value',
        '$rootDir/teknobay/$subValue',
        onReceiveProgress: (count, total) {
          setState(() {
            percentage = ((count / total) * 100).floor();
          });
        },
      );
    }

    for (var video in videoValues) {
      var videoPath = '$rootDir/teknobay/${video.substring(35)}';
      if (!File(videoPath).existsSync()) {
        prefs.setBool(video.split('/').last, false);
        setState(() {
          isLoading = false;
        });
        await dio.download(
          'https://www.timboocafe.com/$video',
          videoPath,
          onReceiveProgress: (count, total) {
            setState(() {
              filesName = video.substring(35);
              percentage = ((count / total) * 100).floor();
              if (percentage == 100) {
                prefs.setBool(video.split('/').last, true);
                setState(() {
                  isLoading = true;
                });
              }
            });
          },
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    downloadFile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          if (!isLoading)
            Positioned(
              bottom: MediaQuery.of(context).size.height / 1.35,
              right: MediaQuery.of(context).size.width / 4,
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.orange,
                      ),
                      betweenSpacee,
                      const Text(
                        "Yükleniyor... Lütfen videolarınızın yüklenmesini bekleyiniz!",
                        style: TextStyle(
                          fontFamily: 'VAGRoundedStd',
                          fontSize: 22,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    filesName,
                    style: const TextStyle(
                      color: Colors.purple,
                      fontFamily: 'VAGRoundedStd',
                      fontSize: 22,
                    ),
                  ),
                  bottomSpace,
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.purple),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "% ${percentage.toString()} Yüklendi.",
                      style: const TextStyle(
                        fontFamily: 'VAGRoundedStd',
                        fontSize: 22,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 9.5,
            right: MediaQuery.of(context).size.width / 2.2,
            child: isLoading2
                ? Row(
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
                  )
                : const Center(child: CircularProgressIndicator()),
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
