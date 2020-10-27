import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayWidget extends StatefulWidget {
  String url;
  AudioPlayWidget({this.url});
  @override
  _AudioPlayWidgetState createState() => _AudioPlayWidgetState();
}

enum PlayerState { stopped, playing, paused }

class _AudioPlayWidgetState extends State<AudioPlayWidget> {
  AudioCache audioCache = AudioCache();
  AudioPlayer audioPlayer = AudioPlayer();

  String localFilePath;

  @override
  void initState() {
    super.initState();
    playInit(widget.url).then((value) {});
  }

  Future<void> playInit(String url) async {
    audioPlayer.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      // if (!mounted) return;
      setState(() => maxDuration = d.inSeconds.toDouble());
    });
    audioPlayer.onAudioPositionChanged.listen((d) {
      print('Max duration: $d');
      setState(() => sliderCurrentPosition = d.inSeconds.toDouble());
    });

    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s) {
      print('Current player state: $s');
      if (mounted && AudioPlayerState.STOPPED == s) {
        setState(() {
          sliderCurrentPosition = 0;
          isPlay = false;
        });
      } else if (AudioPlayerState.PLAYING == s) {
        setState(() {
          isPlay = true;
        });
      }
    });
    audioPlayer.onPlayerCompletion.listen((event) {
      isPlay = false;
      sliderCurrentPosition = 0;
      setState(() {});
    });
  }

  double maxDuration = 0.0;
  double sliderCurrentPosition = 0.0;

  Duration duration;

  bool isPlay = false;

  String getDuration() {
    String s = sliderCurrentPosition.toString();
    if (maxDuration >= 1.0) s += '/' + maxDuration.toString();
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final playerSlider = Container(
        child: Flexible(
      child: Slider(
          value: min(sliderCurrentPosition, maxDuration),
          min: 0.0,
          max: maxDuration,
          onChanged: (double value) async {},
          divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt()),
    ));

    return InkWell(
      key: UniqueKey(),
      onTap: () => isPlay ? stopPlayer() : play(widget.url),
      child: Row(
        children: [
          playerSlider,
          Text(getDuration(), style: TextStyle(color: Colors.black)),
          Icon(isPlay ? Icons.stop : Icons.play_arrow),
        ],
      ),
    );
  }

  Future<void> play(String url) async {
    int result = await audioPlayer.play(url);
    if (result == 1) {
      isPlay = true;
    }
  }

  Future<void> stopPlayer() async {
    int result = await audioPlayer.stop();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await audioPlayer.stop();
  }
}
