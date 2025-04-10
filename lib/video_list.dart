// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timboo/homepage.dart';
import 'package:timboo/media_player.dart';
import 'package:timboo/widgets.dart';

class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  final String jsonUrl = "https://timboocafe.com/VideoGetir.aspx";
  var basePath = "";
  var lang = "TR";

  List<dynamic> imageList = [];
  List<dynamic> jsonData = [];

  @override
  void initState() {
    super.initState();
    _fetchVideoData();
    _fetchFilesFromFtp();
  }

  Future<void> _fetchVideoData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ip = prefs.getString("IP");
      String? sid = prefs.getString("sid");
      setState(() {
        basePath =
            "http://$ip:8080/cgi-bin/filemanager/utilRequest.cgi/xxxxxxxxx?sid=$sid&func=get_viewer&source_path=%2FMultimedia%2FSamples&source_file=xxxxxxxxx";
        lang = prefs.getString("lang")!;
        imageList.clear();
      });

      final response = await http.get(Uri.parse(jsonUrl));
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          jsonData = jsonResponse;
          await _fetchFilesFromFtp();
        } else {
          debugPrint('Hatalı JSON formatı');
        }
      } else {
        debugPrint('Veri getirilemedi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  Future<void> _fetchFilesFromFtp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nasIp = prefs.getString("IP");

    if (nasIp == null || nasIp.isEmpty) {
      debugPrint("NAS IP adresi bulunamadı!");
      return;
    }

    final FTPConnect ftpConnect = FTPConnect(
      nasIp,
      user: "admin",
      pass: "admin",
      timeout: 30000,
    );

    try {
      await ftpConnect.connect();
      bool changedDirCafe = await ftpConnect.changeDirectory('Multimedia');
      if (changedDirCafe) {
        bool changedDirVideos = await ftpConnect.changeDirectory('Samples');
        if (changedDirVideos) {
          debugPrint('Videolar klasörüne geçildi.');
          List<FTPEntry> entries = await ftpConnect.listDirectoryContent();

          for (var jsonItem in jsonData) {
            String imageName = jsonItem["DosyaResim"].split('/').last;
            bool imageExists = entries.any((entry) => entry.name == imageName);

            String imagePath;
            if (imageExists) {
              imagePath = basePath;
              imagePath = imagePath.replaceAll("xxxxxxxxx", imageName);
              imagePath = imagePath.replaceAll("xxxxxxxxx", imageName);
            } else {
              imagePath =
                  'https://www.timboocafe.com/Site/Library/images/logo-b.png';
            }

            debugPrint("Image Path: $imagePath");

            setState(() {
              imageList.add({
                "img": imagePath,
                "name": jsonItem["Icerik_Baslik"],
                "nameEn": jsonItem["Icerik_KisaAciklama"],
                "color": jsonItem["DosyaRenk"],
                "videos": jsonItem["Dosya"],
                "videosEn": jsonItem["DosyaEn"]
              });
            });
          }
        } else {
          debugPrint('Videolar klasörüne geçilemedi.');
        }
      } else {
        debugPrint('Timboo Cafe klasörüne geçilemedi.');
      }

      await ftpConnect.disconnect();
    } catch (e) {
      debugPrint('FTP Bağlantı Hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.amber[100],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
                image: AssetImage(
                    lang == 'TR' ? 'assets/header.png' : 'assets/headeren.png'),
                height: 80),
            betweenSpaceeee,
            betweenSpaceeee,
            betweenSpaceeee,
            betweenSpaceeee,
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lang == 'TR' ? 'Ana Sayfa' : 'Home Page',
                    style: const TextStyle(
                      fontFamily: 'VAGRoundedStd',
                      fontSize: 30,
                      color: Color.fromARGB(255, 218, 144, 47),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 30, color: Color.fromARGB(255, 218, 144, 47)),
                ],
              ),
            )
          ],
        ),
        centerTitle: true,
        toolbarHeight: 120,
        elevation: 20,
        shadowColor: const Color.fromARGB(255, 246, 241, 226),
      ),
      backgroundColor: Colors.amber[100],
      body: imageList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: jsonData.length,
              itemBuilder: (context, index) {
                final video = imageList[index];
                final videoTitle = video['name'] ?? '';
                final videoTitleEn = video['nameEn'] ?? '';
                final videoImagePath = video["img"];
                final videos = video["videos"].toString().split(",");
                final videosEn = video["videosEn"].toString().split(",");

                return GestureDetector(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MediaPlayer(
                          basePath: basePath,
                          title: lang == "TR" ? videoTitle : videoTitleEn,
                          videoName: lang == "TR" ? videos : videosEn,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          child: Image.network(
                            videoImagePath,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return Image.asset('assets/placeholder.png');
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          lang == "TR" ? videoTitle : videoTitleEn,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
