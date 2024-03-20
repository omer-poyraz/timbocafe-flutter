// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
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
  final File myFile = File('/sdcard/Documents/data.json');
  List<dynamic> listData = [];
  var videoLength = 0;
  var controller;
  late PermissionStatus permissionStatus;

  Future<List<dynamic>> fileRead() async {
    var jsonData = json.decode(myFile.readAsStringSync());
    listData = jsonData;
    return listData;
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

    () async {
      permissionStatus = await Permission.storage.status;

      if (permissionStatus != PermissionStatus.granted) {
        PermissionStatus permissionStatus = await Permission.storage.request();
        setState(() {
          permissionStatus = permissionStatus;
        });
      }
    }();
  }

  @override
  void dispose() {
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
            const Image(image: AssetImage('assets/header.png'), height: 80),
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ana Sayfa',
                    style: TextStyle(
                      fontFamily: 'VAGRoundedStd',
                      fontSize: 30,
                      color: Color.fromARGB(255, 218, 144, 47),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.chevron_right,
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
        child: GridView.builder(
          // physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            childAspectRatio: 6 / 2,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            mainAxisExtent: 330,
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
                    listData[index]['Icerik_Baslik'],
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
                        listData[index]['Icerik_Baslik'],
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
                image:
                    FileImage(File('/sdcard/Documents/${path.substring(54)}')),
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
