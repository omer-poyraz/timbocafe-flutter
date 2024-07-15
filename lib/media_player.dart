import 'package:flutter/services.dart';
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
  List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _initializeVideoControllers();
  }

  Future<void> _initializeVideoControllers() async {
    try {
      var storage = await PathProviderEx2.getStorageInfo();
      var rootDir = storage[0].rootDir;

      for (var video in widget.videoName) {
        var file = File('$rootDir/teknobay/${video.substring(35)}');
        var controller = VideoPlayerController.file(file);
        await controller.initialize();
        _controllers.add(controller);
      }
      setState(() {});
    } catch (e) {
      debugPrint('Error initializing video controllers: $e');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      body: VideoItems(
        title: widget.title,
        videoPlayerController: _controllers, // Corrected parameter name
        looping: false,
        autoplay: false,
      ),
    );
  }
}
