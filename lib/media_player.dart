// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timboo/video_items.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class MediaPlayer extends StatefulWidget {
  final List<String> videoName;
  final String title;
  const MediaPlayer({Key? key, required this.videoName, required this.title})
      : super(key: key);
  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  var controller;
  late PermissionStatus permissionStatus;
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

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    () async {
      permissionStatus = await Permission.storage.status;

      if (permissionStatus != PermissionStatus.granted) {
        PermissionStatus permissionStatus = await Permission.storage.request();
        setState(() {
          permissionStatus = permissionStatus;
        });
      }
    }();

    for (int i = 0; i < widget.videoName.length; i++) {
      changeVideo(
          File('/sdcard/teknobay/${widget.videoName[i].substring(35)}'));
    }
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
