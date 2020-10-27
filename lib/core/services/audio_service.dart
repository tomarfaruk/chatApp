import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  FlutterSoundPlayer mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder mRecorder = FlutterSoundRecorder();

  File outputFile;
  String _mPath, _uploadedFileURL, timeonly = '00.00';

  StreamSubscription _mRecordingDataSubscription;

  Future initPlayer() async {
    await mPlayer.openAudioSession();
  }

  Future initRecoder() async {
    await mRecorder.openAudioSession();
  }

  Future<void> record() async {
    if (!await checkAudioPermission()) return;

    await createFile();

    await initRecoder();

    if (!mPlayer.isStopped) return;
    await mRecorder.startRecorder(
      codec: Codec.aacMP4,
      toFile: outputFile.path,
      sampleRate: 16000,
    );

    mRecorder.onProgress.listen((RecordingDisposition e) async {
      if (e != null && e.duration != null) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.duration.inMilliseconds,
            isUtc: true);

        timeonly = DateFormat.ms().format(date);

        if (timeonly.contains('3')) {
          await stopRecorder();
        }
      }
    });
  }

  Future<void> stopRecorder() async {
    await mRecorder.stopRecorder();
    if (_mRecordingDataSubscription != null) {
      await _mRecordingDataSubscription.cancel();
      _mRecordingDataSubscription = null;
    }
  }

  Future<void> stopPlayer() async {
    await mPlayer.stopPlayer();
  }

  Future<bool> checkAudioPermission() async {
    try {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future createFile() async {
    Directory tempDir = await getTemporaryDirectory();
    _mPath = '${tempDir.path}/flutter.aac';
    outputFile = File(_mPath);
    if (outputFile.existsSync()) await outputFile.delete();
    outputFile.openWrite();
  }

  void disposePlayer() {
    stopPlayer();
    mPlayer.closeAudioSession();
    mPlayer = null;
  }

  void disposeRecoder() {
    stopRecorder();
    mRecorder.closeAudioSession();
    mRecorder = null;
  }
}
