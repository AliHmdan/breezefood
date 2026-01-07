import 'dart:async'; // تم استخدامها لإضافة Timer
import 'package:breezefood/features/auth/presentation/login_page.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashVideoScreen extends StatefulWidget {
  const SplashVideoScreen({Key? key}) : super(key: key);

  @override
  State<SplashVideoScreen> createState() => _SplashVideoScreenState();
}

class _SplashVideoScreenState extends State<SplashVideoScreen> {
  late VideoPlayerController _controller;

  // ✅ متغير لتخزين مؤقت التنقل
  Timer? _navigationTimer;

  // الصوت
  bool _isMuted = true;
  double _volumeBeforeMute = 1.0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _controller = VideoPlayerController.asset('assets/video/splachscreen.mp4');

    _controller.setLooping(false);
    _controller.setVolume(_isMuted ? 0.0 : 1.0);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _controller.play();

      // 🚀 إضافة الـ Timer للتنقل بعد 8 ثوانٍ
      _navigationTimer = Timer(const Duration(seconds: 8), _goToLogin);
    });
  }

  void _goToLogin() {
    if (!mounted) return;

    _navigationTimer?.cancel();

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
  }

  Future<void> _applyVolume() async {
    final vol = _isMuted ? 0.0 : (_volumeBeforeMute.clamp(0.0, 1.0));
    await _controller.setVolume(vol);
  }

  Future<void> _toggleMute() async {
    if (_isMuted) {
      setState(() => _isMuted = false);
      await _applyVolume();
    } else {
      _volumeBeforeMute = _volumeBeforeMute == 0.0 ? 1.0 : _volumeBeforeMute;
      setState(() => _isMuted = false);
      await _applyVolume();
    }
  }

  @override
  void dispose() {
    // 🛑 إلغاء الـ Timer عند تدمير الـ Widget
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialized = _controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // الفيديو
          Center(
            child: initialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),

          // زر كتم/تشغيل الصوت
          if (initialized)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    color: Colors.black.withOpacity(0.35),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      tooltip: _isMuted ? 'تشغيل الصوت' : 'كتم الصوت',
                      icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
                      color: Colors.white,
                      onPressed: _toggleMute,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
