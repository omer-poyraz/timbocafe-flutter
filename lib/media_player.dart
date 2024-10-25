import 'package:flutter/services.dart';
import 'package:timboo/video_items.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class MediaPlayer extends StatefulWidget {
  final List<String> videoName;
  final String basePath;
  final String title;

  const MediaPlayer(
      {super.key,
      required this.videoName,
      required this.title,
      required this.basePath});

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  final List<VideoPlayerController> _controllers = [];

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
      for (var video in widget.videoName) {
        var controller =
            VideoPlayerController.networkUrl(Uri.parse("${widget.basePath}$video"));
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
        videos: widget.videoName,
        basePath: widget.basePath,
        title: widget.title,
      ),
    );
  }
}
