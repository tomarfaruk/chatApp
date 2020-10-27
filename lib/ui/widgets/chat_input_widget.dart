import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatInputWidget extends StatefulWidget {
  final Function(String, String) onSubmitted;

  const ChatInputWidget({Key key, @required this.onSubmitted})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  TextEditingController editingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String _uploadedFileURL;
  var image;

  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  String _mPath, _audioURL;
  String timeonly = '0:0';
  bool _startRecord = false, uploadingFile = false;

  File outputFile;

  @override
  void initState() {
    super.initState();
    editingController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _mRecorder.openAudioSession().then((value) {
      _mRecorderIsInited = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Color(0xff3b5998).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(32.0),
                ),
                margin: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    top: _startRecord || uploadingFile ? 25 : 0),
                child: Row(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            color: Color(0xff3b5998),
                          ),
                          onPressed: () async {
                            await pickImage();
                            if (_uploadedFileURL != null)
                              widget.onSubmitted(_uploadedFileURL, 'image');
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Message...",
                        ),
                        focusNode: focusNode,
                        textInputAction: TextInputAction.done,
                        controller: editingController,
                        onSubmitted: (value) {
                          if (value.isEmpty ||
                              value == ' ' ||
                              value.length == 0) return;
                          sendMessage(value, 'text');
                        },
                      ),
                    ),
                    isTexting
                        ? IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              sendMessage(editingController.text, 'text');
                            },
                            color: Color(0xff3b5998),
                          )
                        : new Listener(
                            onPointerDown: (e) async {
                              print('onPointerDown');
                              await record();
                            },
                            onPointerUp: (d) => stopRecorder(),
                            child: new InkWell(
                              child: Icon(Icons.keyboard_voice,
                                  size: !_startRecord ? 30 : 40,
                                  color: !_startRecord
                                      ? Colors.black87
                                      : Colors.redAccent),
                              onTap: () async {
                                try {
                                  print('onTap');
                                  await stopRecorder();

                                  print(await outputFile.length());

                                  uploadingFile = true;
                                  if (mounted) {
                                    setState(() {});
                                  }
                                  await uploadAudio();
                                  await widget.onSubmitted(_audioURL, 'audio');
                                  uploadingFile = false;
                                  if (mounted) {
                                    setState(() {});
                                  }
                                } catch (e) {}
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_startRecord) ...[
          Positioned(
            bottom: 65,
            left: 0,
            right: 0,
            child: Center(
                child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                    child: Text(timeonly))),
          ),
        ],
        if (!_startRecord && uploadingFile == true) ...[
          Positioned(
            bottom: 65,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                child:
                    Text("Sending...", style: TextStyle(color: Colors.black)),
              ),
            ),
          ),
        ]
      ],
    );
  }

  Future<bool> checkAudioPermission() async {
    try {
      PermissionStatus status = await Permission.microphone.status;
      if (status == PermissionStatus.granted) return true;
      await Permission.microphone.request();
      return false;
    } catch (e) {
      return false;
    }
  }

  Future createFile() async {
    Directory tempDir = await getTemporaryDirectory();
    DateTime time = DateTime.now();
    _mPath = '${tempDir.path}/$time.aac';
    outputFile = File(_mPath);
    if (outputFile.existsSync()) await outputFile.delete();
    outputFile.openWrite();
  }

  Future<void> record() async {
    if (!await checkAudioPermission()) return;
    await createFile();
    if (_startRecord) return;
    await _mRecorder.startRecorder(
      codec: Codec.aacMP4,
      toFile: outputFile.path,
      sampleRate: 16000,
    );

    _mRecorder.onProgress.listen((RecordingDisposition e) async {
      if (e != null && e.duration != null) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.duration.inMilliseconds,
            isUtc: true);

        timeonly = DateFormat.ms().format(date);
        _startRecord = true;

        if (timeonly.contains('30')) {
          await stopRecorder();
          _startRecord = false;
        }
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Future<void> stopRecorder() async {
    if (_startRecord) await _mRecorder.stopRecorder();

    _startRecord = false;
    _mplaybackReady = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    stopRecorder();
    _mRecorder.closeAudioSession();
    _mRecorder = null;
    super.dispose();
  }

  bool get isTexting => editingController.text.length != 0;

  void sendMessage(String message, type) {
    if (!isTexting) return;

    widget.onSubmitted(message, type);
    editingController.text = '';
  }

  Future pickImage() async {
    try {
      image = null;
      image = await ImagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 50);

      if (image == null) return null;
      await uploadFile();
    } on PlatformException catch (e) {
      return;
    }
  }

  Future uploadFile() async {
    _uploadedFileURL = null;
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('chats/${Path.basename(image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    print('File Uploaded');
    _uploadedFileURL = await taskSnapshot.ref.getDownloadURL();
  }

  Future uploadAudio() async {
    final StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('voice/${Path.basename(outputFile.path)}}');

    StorageUploadTask uploadTask = storageReference.putFile(
        outputFile, StorageMetadata(contentType: 'audio/aac'));
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    print('File Uploaded............');
    _audioURL = await taskSnapshot.ref.getDownloadURL();
    print("omar faruk...........");
  }
}
