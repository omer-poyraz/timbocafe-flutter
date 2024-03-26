import 'package:path_provider_ex2/path_provider_ex2.dart';
import 'package:timboo/video_items.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class MediaPlayer extends StatefulWidget {
  final List<String> videoName;
  final String title;
  const MediaPlayer({super.key, required this.videoName, required this.title});
  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  dynamic controller;
  late List<VideoPlayerController> newList = [];

  void changeVideo(File file) {
    try {
      controller = VideoPlayerController.file(file)
        // ..setLooping(true)
        ..initialize().then((_) {
          setState(() {});
          // controller.play();
        });
      newList.add(controller);
    } catch (e) {
      debugPrint('Change Video Catch: !!!!!!!! $e');
    }
  }

  newmethod() async {
    var storage = await PathProviderEx2.getStorageInfo();
    var rootDir = storage[1].rootDir;

    for (int i = 0; i < widget.videoName.length; i++) {
      changeVideo(
          File('$rootDir/Documents/${widget.videoName[i].substring(35)}'));
    }
  }

  @override
  void initState() {
    super.initState();
    newmethod();
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
      body: VideoItems(
        title: widget.title,
        videoPlayerController: newList,
        looping: false,
        autoplay: false,
      ),
    );
  }
}
