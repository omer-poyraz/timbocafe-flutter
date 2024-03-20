import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:timboo/video_list.dart';
import 'package:timboo/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';

class VideoItems extends StatefulWidget {
  final List<VideoPlayerController> videoPlayerController;
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
  late List<ChewieController> newChewieController;
  final File myFile = File('/sdcard/Documents/data.json');
  List<dynamic> listData = [];
  var indexNumber = 0;

  Future<List<dynamic>> fileRead() async {
    var jsonData = json.decode(myFile.readAsStringSync());
    listData = jsonData;
    debugPrint(listData.toString());
    return listData;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    fileRead();
    newChewieController = [];
    for (int i = 0; i < widget.videoPlayerController.length; i++) {
      _chewieController = ChewieController(
        videoPlayerController: widget.videoPlayerController[i],
        aspectRatio: 3 / 2,
        autoInitialize: false,
        autoPlay: false,
        looping: false,
        allowedScreenSleep: false,
        zoomAndPan: true,
        useRootNavigator: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.red,
                fontFamily: 'VAGRoundedStd',
              ),
            ),
          );
        },
      );
      newChewieController.add(_chewieController);
    }
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    for (var i = 0; i < widget.videoPlayerController.length; i++) {
      widget.videoPlayerController[i].dispose();
    }
    newChewieController[indexNumber].dispose();
    newChewieController[indexNumber].pause();
  }

  List<Widget> getList() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    List<Widget> childs = [];
    // for (var i = 0; i < newChewieController.length; i++) {
    for (var j = 0; j < listData.length; j++) {
      if (listData[j]['Icerik_Baslik'] == widget.title) {
        var newList = listData[j]['Dosya'].toString().split(',');
        for (var z = 0; z < newList.length; z++) {
          childs.add(InkWell(
            onTap: () {
              setState(() {
                for (var y = 0; y < newList.length; y++) {
                  if (newList[y] != newList[z]) {
                    newChewieController[z].pause();
                  }
                }
                debugPrint(z.toString());
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
                indexNumber < widget.videoPlayerController.length - 1
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
                for (var i = 0; i < widget.videoPlayerController.length; i++) {
                  widget.videoPlayerController[i].dispose();
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
              child: ListView(
                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                children: getList(),
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
            )
          ],
        ),
      ),
    );
  }
}
