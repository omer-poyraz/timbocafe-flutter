import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider_ex2/path_provider_ex2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timboo/homepage.dart';
import 'package:timboo/widgets.dart';
import 'media_player.dart';
import 'dart:convert';
import 'dart:io';

class VideoList extends StatefulWidget {
  const VideoList({super.key});
  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  List<dynamic> listData = [];
  var videoLength = 0;
  var newPath = "";
  var lang = "TR";
  dynamic controller;

  fileRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lang = prefs.getString("lang")!;
    });
    final newList = [];
    var storage = await PathProviderEx2.getStorageInfo();
    var rootDir = storage[1].rootDir;
    newPath = "$rootDir/Documents";
    final File myFile = File('$rootDir/Documents/data.json');
    var jsonData = json.decode(myFile.readAsStringSync());

    for (var i = 0; i < jsonData.length; i++) {
      if (lang == "TR") {
        if (jsonData[i]["Dosya"] != null) {
          newList.add(jsonData[i]);
        }
      } else {
        if (jsonData[i]["DosyaEn"] != null) {
          newList.add(jsonData[i]);
        }
      }
    }

    listData = newList;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    createFolder();
    fileRead();
  }

  @override
  void dispose() {
    fileRead();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
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
      body: Container(
        color: Colors.amber[100],
        child: FutureBuilder(
          future: fileRead(),
          builder: (context, snapshot) {
            debugPrint(snapshot.data.toString());
            return GridView.builder(
              // physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: listData.length,
              itemBuilder: (context, index) {
                var dosyaRenk = listData[index]['DosyaRenk'].toString();
                dynamic dosyaRenk2;
                dynamic dosyaRenk3;
                dynamic dosyaRenkLength;

                if (listData[index]['DosyaRenk'] != null) {
                  dosyaRenkLength = dosyaRenk.length;
                  dosyaRenk2 = dosyaRenk.substring(5, dosyaRenkLength - 1);
                  dosyaRenk3 = dosyaRenk2.split(',');
                }

                return listData[index]['DosyaResim'] != null
                    ? videoCard(
                        context,
                        listData[index]['DosyaResim'],
                        listData[index]['Dosya'].toString().split(','),
                        listData[index][lang == "TR"
                            ? 'Icerik_Baslik'
                            : 'Icerik_KisaAciklama'],
                        listData[index]['DosyaRenk'] == null
                            ? const Color.fromARGB(255, 44, 93, 53)
                            : Color.fromARGB(
                                int.parse(dosyaRenk3[0]),
                                int.parse(dosyaRenk3[1]),
                                int.parse(dosyaRenk3[2]),
                                int.parse(dosyaRenk3[3]),
                              ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Image(
                            image: AssetImage('assets/initial.jpg'),
                            width: 150,
                          ),
                          bottomSpaceeee,
                          bottomSpaceeee,
                          Text(
                            listData[index][lang == "TR"
                                ? 'Icerik_Baslik'
                                : 'Icerik_KisaAciklama'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontFamily: 'VAGRoundedStd',
                              fontSize: 23,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      );
              },
            );
          },
        ),
      ),
    );
  }

  InkWell videoCard(BuildContext context, String path, List<String> videoName,
      String title, Color color) {
    return InkWell(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaPlayer(
              title: title,
              videoName: videoName,
            ),
          ),
        );
      },
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Image(
                image: FileImage(File('$newPath/${path.substring(54)}')),
                width: MediaQuery.of(context).size.width / 6,
                height: MediaQuery.of(context).size.height / 3.2,
              ),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'VAGRoundedStd',
                  fontSize: 23,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
