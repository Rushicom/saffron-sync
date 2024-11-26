import 'package:flutter/material.dart';

class ImageViewerScreen extends StatelessWidget {
  final String fileUrl;

  const ImageViewerScreen({super.key ,required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Viewer')),
      body: Image.network(fileUrl), // Display image
    );
  }
}