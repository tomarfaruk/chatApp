import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewScreen extends StatelessWidget {
  PhotoViewScreen({this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Icon(Icons.clear, color: Colors.red, size: 40),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Image preview',
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: PhotoView(
        imageProvider: NetworkImage(url),
        // Contained = the smallest possible size to fit one dimension of the screen
        minScale: PhotoViewComputedScale.contained * 0.8,
        // Covered = the smallest possible size to fit the whole screen
        maxScale: PhotoViewComputedScale.covered * 2,
        enableRotation: true,
        // Set the background color to the "classic white"
        backgroundDecoration: BoxDecoration(color: Colors.white),
        loadingBuilder: (context, event) {
          if (event == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final value = event.cumulativeBytesLoaded / event.expectedTotalBytes;

          final percentage = (100 * value).floor();
          return Center(
            child: Text("$percentage%"),
          );
        },
      ),
    );
  }
}
