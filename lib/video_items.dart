import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
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
    required this.looping,
    required this.videoPlayerController,
    required this.autoplay,
    required this.title,
  });

  @override
  State<VideoItems> createState() => _VideoItemsState();
}

class _VideoItemsState extends State<VideoItems> {
  late List<ChewieController> _chewieControllers = [];
  late List<VideoPlayerController> _videoControllers = [];
  var indexNumber = 0;
  String lang = "TR";

  void newmethod() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lang = prefs.getString("lang") ?? "TR";
    });

    var storage = await PathProviderEx2.getStorageInfo();
    var rootDir = storage[0].rootDir;
    final File myFile = File('$rootDir/teknobay/data.json');
    var jsonData = json.decode(myFile.readAsStringSync());

    List<ChewieController> newChewieControllers = [];
    List<VideoPlayerController> newVideoControllers = [];

    for (var j = 0; j < jsonData.length; j++) {
      if (jsonData[j][lang == "TR" ? 'Icerik_Baslik' : 'Icerik_KisaAciklama'] ==
          widget.title) {
        var videos = jsonData[j][lang == 'TR' ? 'Dosya' : 'DosyaEn']
            .toString()
            .split(",");

        for (var video in videos) {
          String videoPath =
              '$rootDir/teknobay/${video.replaceAll("Webkontrol/IcerikYonetimi/Dosyalar/", "")}';
          VideoPlayerController videoController =
              VideoPlayerController.file(File(videoPath));
          await videoController.initialize();
          newVideoControllers.add(videoController);

          ChewieController chewieController = ChewieController(
            videoPlayerController: videoController,
            aspectRatio: 3 / 2,
            autoInitialize: true, // Video otomatik olarak başlatılsın
            autoPlay: false, // Otomatik oynatma devre dışı bırakılsın
            looping: false,
            allowedScreenSleep: false,
            zoomAndPan: true,
            showOptions: true, // Video oynatma seçeneklerini göster
            showControls: true, // Video kontrollerini göster
            allowPlaybackSpeedChanging: false,
            allowMuting: false,
            draggableProgressBar:
                true, // İlerleme çubuğunu sürükleyerek ileri geri sar
            useRootNavigator: true,
            errorBuilder: (context, errorMessage) {
              return Center(
                child: Text(
                  lang == 'TR'
                      ? "Hatalı bir video! Lütfen yeniden yükleyiniz!"
                      : "Faulty video! Please re-upload!",
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'VAGRoundedStd',
                  ),
                ),
              );
            },
          );
          newChewieControllers.add(chewieController);
        }
      }
    }

    setState(() {
      _chewieControllers = newChewieControllers;
      _videoControllers = newVideoControllers;
    });
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    newmethod();
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.pause();
      controller.dispose();
    }
    for (var controller in _chewieControllers) {
      controller.pause();
      controller.dispose();
    }
    super.dispose();
  }

  Future<List<Widget>> getList() async {
    List<Widget> childs = [];
    var storage = await PathProviderEx2.getStorageInfo();
    var rootDir = storage[0].rootDir;
    final File myFile = File('$rootDir/teknobay/data.json');
    var jsonData = json.decode(myFile.readAsStringSync());

    for (var j = 0; j < jsonData.length; j++) {
      if (jsonData[j][lang == "TR" ? 'Icerik_Baslik' : 'Icerik_KisaAciklama'] ==
          widget.title) {
        var newList = jsonData[j][lang == 'TR' ? 'Dosya' : 'DosyaEn']
            .toString()
            .split(',');
        for (var z = 0; z < newList.length; z++) {
          childs.add(
            InkWell(
              onTap: () {
                setState(() {
                  indexNumber = z;
                  for (var i = 0; i < _chewieControllers.length; i++) {
                    if (i != indexNumber) {
                      _chewieControllers[i].pause();
                    }
                  }
                  _chewieControllers[indexNumber].play();
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
            ),
          );
        }
      }
    }
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
                            _chewieControllers[indexNumber].pause();
                            indexNumber = indexNumber - 1;
                            _chewieControllers[indexNumber].play();
                          });
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chevron_left,
                              color: Colors.orange,
                            ),
                            Text(
                              lang == 'TR' ? "Önceki Video" : "Previous Video",
                              style: const TextStyle(
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
                indexNumber < _chewieControllers.length - 1
                    ? InkWell(
                        onTap: () {
                          setState(() {
                            _chewieControllers[indexNumber].pause();
                            indexNumber = indexNumber + 1;
                            _chewieControllers[indexNumber].play();
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              lang == 'TR' ? "Sonraki Video" : "Next Video",
                              style: const TextStyle(
                                fontFamily: 'VAGRoundedStd',
                                fontSize: 20,
                                color: Colors.orange,
                              ),
                            ),
                            const Icon(
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
                for (var controller in _videoControllers) {
                  controller.dispose();
                }
                for (var controller in _chewieControllers) {
                  controller.dispose();
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VideoList()),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.view_list_rounded, color: Colors.orange),
                  const SizedBox(width: 10),
                  Text(
                    lang == 'TR' ? 'Video Listesi' : 'Video List',
                    style: const TextStyle(color: Colors.orange),
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
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return snapshot.data![index];
                      },
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
                child: _chewieControllers.isNotEmpty
                    ? Chewie(controller: _chewieControllers[indexNumber])
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
