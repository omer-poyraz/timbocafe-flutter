import 'dart:convert';
import 'dart:io';
import 'package:path_provider_ex2/path_provider_ex2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timboo/video_list.dart';
import 'package:timboo/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoItems extends StatefulWidget {
  final List videoPlayerController;
  final bool looping;
  final bool autoplay;
  final String title;
  const VideoItems({
    super.key,
    required this.videoPlayerController,
    required this.looping,
    required this.autoplay,
    required this.title,
  });

  @override
  State<VideoItems> createState() => _VideoItemsState();
}

class _VideoItemsState extends State<VideoItems> {
  late ChewieController _chewieController;
  var newChewieController = [];
  late List widgetList = [];
  late List newList2 = [];
  var indexNumber = 0;
  var lang = "TR";
  dynamic controller;

  void newmethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lang = prefs.getString("lang")!;
    });
    var newList = [];
    var storage = await PathProviderEx2.getStorageInfo();
    var rootDir = storage[1].rootDir;
    final File myFile = File('$rootDir/Documents/data.json');
    var jsonData = json.decode(myFile.readAsStringSync());

    for (var j = 0; j < jsonData.length; j++) {
      if (jsonData[j][lang == "TR" ? 'Icerik_Baslik' : 'Icerik_KisaAciklama'] ==
          widget.title) {
        var videoList = [];
        var videos = jsonData[j][lang == 'TR' ? 'Dosya' : 'DosyaEn']
            .toString()
            .split(",");
        for (var k = 0; k < videos.length; k++) {
          videoList.add(
              videos[k].replaceAll("Webkontrol/IcerikYonetimi/Dosyalar/", ""));
        }
        var videoName = videoList;

        for (int i = 0; i < videoName.length; i++) {
          controller = VideoPlayerController.file(
              File('$rootDir/Documents/${videoName[i]}'))
            // ..setLooping(true)
            ..initialize().then((_) {
              setState(() {});
              // controller.play();
            });
          newList2.add(controller);

          _chewieController = ChewieController(
            videoPlayerController: controller,
            aspectRatio: 3 / 2,
            autoInitialize: false,
            autoPlay: false,
            looping: false,
            allowedScreenSleep: false,
            zoomAndPan: true,
            useRootNavigator: true,
            errorBuilder: (context, errorMessage) {
              return const Center(
                child: Text(
                  "Hatalı bir video! Lütfen yeniden yükleyiniz!",
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'VAGRoundedStd',
                  ),
                ),
              );
            },
          );
          newList.add(_chewieController);
        }
      }
    }

    setState(() {
      newChewieController = newList;
    });
  }

  @override
  void initState() {
    super.initState();
    newmethod();
  }

  @override
  void dispose() {
    super.dispose();
    for (var i = 0; i < newList2.length; i++) {
      newList2[i].dispose();
    }
    newChewieController[indexNumber].dispose();
    newChewieController[indexNumber].pause();
  }

  Future<List<Widget>> getList() async {
    List<Widget> childs = [];
    var storage = await PathProviderEx2.getStorageInfo();
    var rootDir = storage[1].rootDir;
    final File myFile = File('$rootDir/Documents/data.json');
    var jsonData = json.decode(myFile.readAsStringSync());

    // for (var i = 0; i < newChewieController.length; i++) {
    for (var j = 0; j < jsonData.length; j++) {
      if (jsonData[j][lang == "TR" ? 'Icerik_Baslik' : 'Icerik_KisaAciklama'] ==
          widget.title) {
        var newList = jsonData[j][lang == 'TR' ? 'Dosya' : 'DosyaEn']
            .toString()
            .split(',');
        for (var z = 0; z < newList.length; z++) {
          childs.add(InkWell(
            onTap: () {
              setState(() {
                for (var y = 0; y < newList.length; y++) {
                  if (newList[y] != newList[z]) {
                    newChewieController[z].pause();
                  }
                }
                debugPrint("zzzzzz: $z");
                indexNumber = z;
              });
            },
            child: Card(
              color: Colors.orange,
              child: ListTile(
                leading: const Icon(Icons.video_label_rounded),
                title: Text(newList[z].toString().split('/').last),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ));
        }
      }
    }
    // }
    return childs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      appBar: AppBar(
        foregroundColor: Colors.orange,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                indexNumber > 0
                    ? InkWell(
                        onTap: () {
                          setState(() {
                            indexNumber = indexNumber - 1;
                            debugPrint(indexNumber.toString());
                            newChewieController[indexNumber + 1].pause();
                            newChewieController[indexNumber].play();
                          });
                        },
                        child: const Row(
                          children: [
                            Icon(
                              Icons.chevron_left,
                              color: Colors.orange,
                            ),
                            Text(
                              "Önceki Video",
                              style: TextStyle(
                                fontFamily: 'VAGRoundedStd',
                                fontSize: 20,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Text(""),
                betweenSpaceee,
                indexNumber > 0
                    ? const Text(
                        "|",
                        style: TextStyle(color: Colors.deepOrange),
                      )
                    : const Text(""),
                betweenSpaceee,
                indexNumber < newList2.length - 1
                    ? InkWell(
                        onTap: () {
                          try {
                            setState(() {
                              indexNumber = indexNumber + 1;
                              debugPrint(indexNumber.toString());
                              newChewieController[indexNumber - 1].pause();
                            });
                          } catch (e) {
                            debugPrint(
                                "Birrrrrrrr hataaaaa varrrrrrrr : ${e.toString()}");
                          }
                        },
                        child: const Row(
                          children: [
                            Text(
                              "Sonraki Video",
                              style: TextStyle(
                                fontFamily: 'VAGRoundedStd',
                                fontSize: 20,
                                color: Colors.orange,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            ),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.purple,
                letterSpacing: 3,
                fontFamily: 'VAGRoundedStd',
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            InkWell(
              onTap: () {
                for (var i = 0; i < newList2.length; i++) {
                  newList2[i].dispose();
                }
                newChewieController[indexNumber].dispose();

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VideoList()),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.view_list_rounded, color: Colors.orange),
                  SizedBox(width: 10),
                  Text(
                    'Video Listesi',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.amber[100],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width - 200,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: FutureBuilder(
                future: getList(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else if (snapshot.hasData) {
                    return ListView(
                      padding:
                          const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                      children: snapshot.data!,
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            betweenSpaceee,
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 550,
                width: 800,
                child: Chewie(controller: newChewieController[indexNumber]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
