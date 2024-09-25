import 'dart:io';

import 'package:flutter_media_editor/VideoEditor.dart';
import 'package:flutter_media_editor/flutter_media_editor.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:helpers/helpers.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:video_player/video_player.dart';


typedef VideoUpdated = void Function(File file);
typedef ImageUpdated = void Function(File file);
typedef CancelPressed = void Function();

enum FileType {
  video,
  image
}

Color backgroundColor = Colors.black;
Color primaryColor = Colors.black;
Color secondaryColor = Colors.white;

class MediaEditor extends StatefulWidget {
  final VideoUpdated? onVideoUpdated;
  final ImageUpdated? onImageUpdated;
  final CancelPressed? onCancelPressed;
  final FileType fileType;
  final bool shouldPreview;
  final File file;
  final bool saveToGallery;
  final Color? backgroundColor;
  final Color? primaryColor;
  final Color? secondaryColor;

  const MediaEditor({Key? key,
    this.onVideoUpdated,
    this.onImageUpdated,
    this.onCancelPressed,
    required this.fileType,
    required this.file,
    this.shouldPreview = false,
    this.saveToGallery = false,
    this.backgroundColor,
    this.primaryColor,
    this.secondaryColor,
  }) : super(key: key);

  @override
  _MediaEditorState createState() => _MediaEditorState();
}

class _MediaEditorState extends State<MediaEditor> {

  File? imageSelected;
  File? videoSelected;
  VideoPlayerController _controller = VideoPlayerController.network('');
  final _isSaving = ValueNotifier<bool>(false);

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      // Add Your Code here.
      updateScreen();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // updateScreen();
  }

  Future updateScreen() async{

    if (widget.fileType == FileType.image) {
      imageSelected = widget.file;
      _cropImage(widget.file);
    }
    else {
      videoSelected = widget.file;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              VideoEditor(file: File(widget.file.path),
                onCancelPressed: () {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                onUpdatedVideo: (file) {
                  if (mounted) {
                    videoSelected = file;
                    imageSelected = null;

                    if (widget.shouldPreview) {
                      _updateVideoFile(file);
                      setState(() {

                      });
                    }
                    else {
                      _doneEdit();
                    }
                  }
                },
              ),
        ),
      ).then((value) {
        setState(() {

        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.red,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          )
        ],
    );

    if (croppedFile != null) {
      final File imageFile = File(croppedFile!.path);

      videoSelected = null;
      imageSelected = imageFile;

      if (widget.shouldPreview) {
        setState(() {

        });
      }
      else {
        _doneEdit();
      }
    }
  }

  _doneEdit() {
    if (widget.fileType == FileType.image) {

      if (widget.onImageUpdated != null && imageSelected != null) {

        if (widget.saveToGallery) {
          _isSaving.value = true;
          GallerySaver.saveImage(imageSelected!.path).then((status) {

            var success = status ?? false;
            _isSaving.value = false;
            if (success) {
              print('Success: Saving image to gallery');
              widget.onImageUpdated!(imageSelected as File);
            }
            else {
              print('Failed: Saving image to gallery');
            }
          });
        }
        else {
          widget.onImageUpdated!(imageSelected as File);
        }
      }
    }
    else
    {
      if (widget.onVideoUpdated != null && videoSelected != null) {

        if (widget.saveToGallery) {
          _isSaving.value = true;

          GallerySaver.saveVideo(videoSelected!.path).then((status) {

            var success = status ?? false;
            _isSaving.value = false;

            if (success) {
              print('Success: Saving video to gallery');
              widget.onImageUpdated!(videoSelected as File);
            }
            else {
              print('Failed: Saving vidoe to gallery');
            }
          });
        }
        else {
          widget.onVideoUpdated!(videoSelected as File);
        }
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    backgroundColor = widget.backgroundColor ?? Colors.black;
    primaryColor = widget.primaryColor ?? Theme.of(context).primaryColorDark;
    secondaryColor = widget.secondaryColor ?? Theme.of(context).primaryColorLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leadingWidth: 100,
        leading: FilledButton(
          child: Text(
            'Cancel',
            style: TextStyle(
              color: secondaryColor,
              fontSize: 18,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            if (widget.onCancelPressed != null ) {
              widget.onCancelPressed;
            }
          },
        ),
        title: widget.shouldPreview ? Text('Preview', style: TextStyle(
            color: secondaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold
        ),) : Text(''),
        actions: [
          FilledButton(
            child: Text(
              'Done',
              style: TextStyle(
                  color: secondaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),
            ),
            onPressed: () {
              _doneEdit();
            },
          ),
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Container(
            height: double.infinity,
            width: double.infinity,
            child: imageSelected == null && videoSelected == null ?
            Center(child:
            Text(
              'Found nothing to Preview',
            )):
            imageSelected != null ?
            Image.file(imageSelected as File, fit: BoxFit.contain,) :

            videoSelected != null ? Stack(
                children: <Widget>[
                  Center(
                    child: _controller.value.isInitialized
                        ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                        : Container(),
                  ),
                  Center(
                    child: _controller.value.isInitialized
                        ? FloatingActionButton(
                      backgroundColor: secondaryColor,
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                      child: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: primaryColor,
                      ),
                    ) : Container(),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _isSaving,
                    builder: (_, bool export, __) => OpacityTransition(
                      visible: export,
                      child: AlertDialog(
                        backgroundColor: secondaryColor,
                        title: Text(
                          'Saving',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  )
                ]
            ) : SizedBox(height: 0,)
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _updateVideoFile(File file) {
    _controller = VideoPlayerController.file(
        file)
      ..initialize().then((_) {
        // _controller.pause();
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }
}