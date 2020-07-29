import 'package:flutter/material.dart';

import '../data.dart';

const supportedThumbnails = <String>{
  'aac',
  'ai',
  'avi',
  'doc',
  'flac',
  'gif',
  'html',
  'jpg',
  'js',
  'mov',
  'mp3',
  'mp4',
  'pdf',
  'png',
  'psd',
  'tiff',
  'txt',
  'xls',
};

class FileThumbnail extends StatelessWidget {
  const FileThumbnail(this.file) : assert(file != null);

  final File file;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: FittedBox(fit: BoxFit.contain, child: _buildThumbnail()),
    );
  }

  Widget _buildThumbnail() {
    if (file.isDirectory) {
      return Icon(Icons.folder);
    }

    final type = file.extension;
    final assetPath = supportedThumbnails.contains(type)
        ? 'assets/file_thumbnails/${type}s.png'
        : 'assets/file_thumbnails/default.png';
    return Image.asset(assetPath);
  }
}
