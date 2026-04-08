import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

import '../cl_theme.dart';

class ClVideoPicker extends StatefulWidget {
  final ValueChanged<PlatformFile?>? onPickedFile;

  const ClVideoPicker({super.key, this.onPickedFile});

  @override
  State<ClVideoPicker> createState() => _ClVideoPickerState();
}

class _ClVideoPickerState extends State<ClVideoPicker> {
  String? _videoName;
  VideoPlayerController? _videoPlayerController;
  Uint8List? _videoBytes;
  String? _videoUrl;

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    /*if (result != null) {
      setState(() {
        _videoBytes = result.files.single.bytes;
        _videoName = result.files.single.name;

        final blob = html.Blob([_videoBytes!]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        _videoUrl = url;

        _videoPlayerController = VideoPlayerController.network(_videoUrl!)
          ..initialize().then((_) {
            setState(() {});
          });
      });

      // Pass the video file back to the parent widget (viewmodel)
      if (widget.onPickedFile != null) {
        widget.onPickedFile!(PlatformFile(
          name: _videoName!,
          bytes: _videoBytes!,
          path: '',
          size: _videoBytes!.lengthInBytes,
        ));
      }
    }*/
  }

  void _removeVideo() {
    setState(() {
      _videoBytes = null;
      _videoName = null;
      if (_videoPlayerController != null) {
        _videoPlayerController!.dispose();
        _videoPlayerController = null;
      }
      if (_videoUrl != null) {
       // html.Url.revokeObjectUrl(_videoUrl!);
      }
      _videoUrl = null;
    });

    if (widget.onPickedFile != null) {
      widget.onPickedFile!(null);
    }
  }

  void _showVideoDialog(BuildContext context) {
    if (_videoPlayerController != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Visualizza Video'),
            content: _videoPlayerController!.value.isInitialized
                ? AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController!),
            )
                : Center(child: CircularProgressIndicator()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _videoPlayerController?.play();
                  });
                },
                child: Text('Play'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _videoPlayerController?.pause();
                  });
                },
                child: Text('Pause'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickVideo,
          child: SizedBox(
            height: 135,
            width: double.infinity,
            child: _videoName == null
                ? Container(
              height: 135,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 50, color: Colors.blue),
                  Text(
                    "Seleziona video (.mp4)",
                    style: CLTheme.of(context).bodyLabel,
                  ),
                ],
              ),
            )
                : Center(child: Text(_videoName!)),
          ),
        ),
        if (_videoName != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _showVideoDialog(context),
                child: Text('Visualizza'),
              ),
              ElevatedButton(
                onPressed: _removeVideo,
                child: Text('Rimuovi'),
              ),
            ],
          ),
      ],
    );
  }
}

