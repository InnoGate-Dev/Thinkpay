import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // For asset video (put video in assets folder)
    _controller = VideoPlayerController.asset('lib/assets/startup_video.mp4');

    // OR for network video
    // _controller = VideoPlayerController.networkUrl(
    //   Uri.parse('https://example.com/startup_video.mp4')
    // );=

    await _controller.initialize();
    _controller.setLooping(true);
    _controller.play();

    setState(() {
      _isVideoInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVideoInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller.value.size.width,
            height: _controller.value.size.height,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }
}