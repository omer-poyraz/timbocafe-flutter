// ignore_for_file: must_be_immutable

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timboo/video_list.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoItems extends StatefulWidget {
  List<String> videos;
  String basePath;
  final String title;

  VideoItems({
    super.key,
    required this.videos,
    required this.basePath,
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

  void newMethod() async {
    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      lang = prefs.getString("lang") ?? "TR";
    });

    List<ChewieController> newChewieControllers = [];
    List<VideoPlayerController> newVideoControllers = [];
    List<String> availableVideos = [];

    for (var video in widget.videos) {
      if (!mounted) return;
      VideoPlayerController videoController = VideoPlayerController.networkUrl(
          Uri.parse("${widget.basePath}$video"));
      try {
        await videoController.initialize();
        if (!mounted) {
          videoController.dispose();
          return;
        }
        availableVideos.add(video);
        newVideoControllers.add(videoController);
        ChewieController chewieController = ChewieController(
          videoPlayerController: videoController,
          aspectRatio: 3 / 2,
          autoInitialize: false,
          autoPlay: false,
          looping: false,
          allowedScreenSleep: false,
          zoomAndPan: true,
          showOptions: true,
          showControls: true,
          allowPlaybackSpeedChanging: false,
          allowMuting: false,
          draggableProgressBar: true,
          useRootNavigator: true,
          errorBuilder: (context, errorMessage) {
            debugPrint(errorMessage.toString());
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
      } catch (e) {
        debugPrint("VideoInit:${e.toString()}");
      }
    }

    if (!mounted) {
      for (var controller in newVideoControllers) {
        controller.dispose();
      }
      for (var controller in newChewieControllers) {
        controller.dispose();
      }
      return;
    }

    if (availableVideos.isNotEmpty) {
      setState(() {
        _chewieControllers = newChewieControllers;
        _videoControllers = newVideoControllers;
        widget.videos = availableVideos;
      });
    } else {
      setState(() {
        widget.videos = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    newMethod();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
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
    List<Widget> childWidgets = [];

    for (var z = 0; z < widget.videos.length; z++) {
      childWidgets.add(
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
              title: Text(widget.videos[z]),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ),
      );
    }
    return childWidgets;
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
                            indexNumber--;
                            _chewieControllers[indexNumber].play();
                          });
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.chevron_left,
                                color: Colors.orange),
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
                    : const SizedBox.shrink(),
                const SizedBox(width: 8),
                indexNumber > 0
                    ? const Text("|",
                        style: TextStyle(color: Colors.deepOrange))
                    : const SizedBox.shrink(),
                const SizedBox(width: 8),
                indexNumber < _chewieControllers.length - 1
                    ? InkWell(
                        onTap: () {
                          setState(() {
                            _chewieControllers[indexNumber].pause();
                            indexNumber++;
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
                            const Icon(Icons.chevron_right,
                                color: Colors.orange),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
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
        width: widget.videos.isEmpty
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width - 200,
        child: widget.videos.isEmpty
            ? Center(
                child: Text(
                lang == 'TR'
                    ? 'Bu kategoriye ait film bulunmamaktadır!'
                    : 'There is no movie in this category!',
                style: const TextStyle(
                  fontSize: 30,
                ),
              ))
            : Row(
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
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
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
