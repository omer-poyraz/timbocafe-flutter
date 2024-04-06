import 'dart:convert';
import 'dart:io' as io;
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

  Directory findRoot(FileSystemEntity entity) {
    final Directory parent = entity.parent;
    if (parent.path == entity.path) return parent;
    return findRoot(parent);
  }

  Future downloadFile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Dio dio = Dio();
    var storage = await PathProviderEx2.getStorageInfo();
    var rootDir = storage[1].rootDir;
    var drc = Directory("$rootDir/Documents");
    // /storage/5FDB-C5C1/Documents
    files = io.Directory(drc.path).listSync();

    await dio.download('https://www.timboocafe.com/VideoGetir.aspx',
        '$rootDir/Documents/data.json');
    final File myFile = File('$rootDir/Documents/data.json');
    jsonData = json.decode(myFile.readAsStringSync());

    if (jsonData.length != 0) {
      for (var i = 0; i < jsonData.length; i++) {
        var videoValues = jsonData[i]['Dosya'].toString().split(',');
        var videoValuesEn = jsonData[i]['DosyaEn'].toString().split(',');
        for (var j = 0; j < videoValues.length; j++) {
          if (videoValues[j].isNotEmpty) {
            jsonDataList.add(videoValues[j].split('/').last);
          }
        }
        for (var j = 0; j < videoValuesEn.length; j++) {
          if (videoValuesEn[j].isNotEmpty) {
            jsonDataListEn.add(videoValuesEn[j].split('/').last);
          }
        }
      }
      for (var j = 0; j < files.length; j++) {
        fileList.add(files[j].path.split('/').last);
      }

      // fazla olan dosyaları silme
      for (var j = 0; j < fileList.length; j++) {
        var isFile = jsonDataList.indexOf(fileList[j]);
        var isFileEn = jsonDataListEn.indexOf(fileList[j]);
        if (isFile < 0 && isFileEn < 0) {
          if (files[j].path.toString().split(".").last != "json" &&
              files[j].path.toString().split(".").last != "png" &&
              files[j].path.toString().split(".").last != "jpg" &&
              files[j].path.toString().split(".").last != "jpeg") {
            debugPrint("Dosya silindi!  (${fileList[j]})");
            files[j].delete();
            prefs.setBool(fileList[j], false);
          }
        }
      }

      // olmayan dosyaları indirme
      for (var i = 0; i < jsonData.length; i++) {
        // Türkçe Videoları İndirme
        if (jsonData[i]['Dosya'] != null && jsonData[i]['DosyaResim'] != null) {
          var value = jsonData[i]['DosyaResim'].toString();
          var subValue = value.substring(54);
          var videoValue = jsonData[i]['Dosya'].toString().split(',');

          // Dosya Resimleri İndirme
          if (!File('$rootDir/Documents/$subValue').existsSync()) {
            await dio.download('https://www.timboocafe.com/$value',
                '$rootDir/Documents/$subValue',
                onReceiveProgress: ((count, total) {
              setState(() {
                percentage = ((count / total) * 100).floor();
              });
            }));
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = true;
            });
          }
          // Dosya Resimleri İndirme Bitiş

          for (int j = 0; j < videoValue.length; j++) {
            debugPrint("-------------------------------");
            debugPrint('Film adı: ${videoValue[j].substring(35)}');
            debugPrint(
                'Film durumu: ${File('$rootDir/Documents/${videoValue[j].substring(35)}').existsSync().toString()}');

            if (!File('$rootDir/Documents/${videoValue[j].substring(35)}')
                .existsSync()) {
              prefs.setBool(videoValue[j].split('/').last, false);
              setState(() {
                isLoading = false;
              });
              await dio.download(
                'https://www.timboocafe.com/${videoValue[j]}',
                '$rootDir/Documents/${videoValue[j].substring(35)}',
                onReceiveProgress: ((count, total) {
                  setState(() {
                    filesName = videoValue[j].substring(35);
                    percentage = ((count / total) * 100).floor();
                    if (percentage == 100) {
                      prefs.setBool(videoValue[j].split('/').last, true);
                      setState(() {
                        isLoading = true;
                      });
                    }
                  });
                }),
              );
            } else {
              setState(() {
                isLoading = true;
              });
            }
          }
        }
        // Türkçe Videoları İndirme Bitiş

        // İngilizce Videoları İndirme
        if (jsonData[i]['DosyaEn'] != null &&
            jsonData[i]['DosyaResim'] != null) {
          var value = jsonData[i]['DosyaResim'].toString();
          var subValue = value.substring(54);
          var videoValue = jsonData[i]['DosyaEn'].toString().split(',');

          // Dosya Resimleri İndirme
          if (!File('$rootDir/Documents/$subValue').existsSync()) {
            await dio.download('https://www.timboocafe.com/$value',
                '$rootDir/Documents/$subValue',
                onReceiveProgress: ((count, total) {
              setState(() {
                percentage = ((count / total) * 100).floor();
              });
            }));
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = true;
            });
          }
          // Dosya Resimleri İndirme Bitiş

          for (int j = 0; j < videoValue.length; j++) {
            debugPrint("-------------------------------");
            debugPrint('Film adı: ${videoValue[j].substring(35)}');
            debugPrint(
                'Film durumu: ${File('$rootDir/Documents/${videoValue[j].substring(35)}').existsSync().toString()}');

            if (!File('$rootDir/Documents/${videoValue[j].substring(35)}')
                .existsSync()) {
              prefs.setBool(videoValue[j].split('/').last, false);
              setState(() {
                isLoading = false;
              });
              await dio.download(
                'https://www.timboocafe.com/${videoValue[j]}',
                '$rootDir/Documents/${videoValue[j].substring(35)}',
                onReceiveProgress: ((count, total) {
                  setState(() {
                    filesName = videoValue[j].substring(35);
                    percentage = ((count / total) * 100).floor();
                    if (percentage == 100) {
                      prefs.setBool(videoValue[j].split('/').last, true);
                      setState(() {
                        isLoading = true;
                      });
                    }
                  });
                }),
              );
            } else {
              setState(() {
                isLoading = true;
              });
            }
          }
        }
        // İngilizce Videoları İndirme Bitiş
      }
      setState(() {
        isLoading = true;
      });
    }
    setState(() {
      isLoading2 = true;
    });
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
          !isLoading
              ? Positioned(
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
                )
              : const Text(""),
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
