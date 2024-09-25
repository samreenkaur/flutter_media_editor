import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_media_editor/flutter_media_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


class MediaPicker extends StatefulWidget {
  final VideoUpdated? onVideoUpdated;
  final ImageUpdated? onImageUpdated;
  final CancelPressed? onCancelPressed;
  final bool shouldPreview;
  final bool saveToGallery;
  final Color? backgroundColor;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Widget? buttonTemplate;


  const MediaPicker({Key? key,
    this.onVideoUpdated,
    this.onImageUpdated,
    this.onCancelPressed,
    this.shouldPreview = false,
    this.saveToGallery = false,
    this.backgroundColor,
    this.primaryColor,
    this.secondaryColor,
    this.buttonTemplate,
  }) : super(key: key);

  @override
  _MediaPickerState createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  final ImagePicker _picker = ImagePicker();
  File? imageSelected;
  File? videoSelected;
  bool movedToNext = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    backgroundColor = widget.backgroundColor ?? Colors.black;
    primaryColor = widget.primaryColor ?? Theme.of(context).primaryColorDark;
    secondaryColor = widget.secondaryColor ?? Theme.of(context).primaryColorLight;

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Your condition check when the view appears
    checkCondition();
  }

  void checkCondition() {
    // Your logic here
    print("View appeared, checking condition...");
    if (movedToNext)
      {
        Navigator.pop(context);
      }
  }

  // Check permission status and request if not granted
  Future<bool> _checkPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isDenied || status.isRestricted) {
      // Request the permission
      final result = await permission.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  // Request camera and storage permissions
  Future<bool> _requestPermissions() async {
    final cameraPermission = await _checkPermission(Permission.camera);
    final storagePermission = await _checkPermission(Permission.photos);
    return cameraPermission && storagePermission;
  }

  // Pick an image or video from the camera or gallery
  Future<void> _pickMedia(ImageSource source, {bool isVideo = false}) async {
    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission Denied')),
      );
      return;
    }

    if (!isVideo)
      {
        final XFile? file = await _picker.pickImage(
          source: source,
          preferredCameraDevice: CameraDevice.rear,
        );

        movedToNext = true;
        videoSelected = file as File;

        Navigator.of(context).push(
            MaterialPageRoute(
            builder: (context) =>
                MediaEditor(file: videoSelected as File,
                  fileType: FileType.image,

                  shouldPreview: widget.shouldPreview,
                  saveToGallery: widget.saveToGallery,
                  backgroundColor: widget.backgroundColor,
                  primaryColor: widget.primaryColor,
                  secondaryColor: widget.secondaryColor,

                  onCancelPressed: widget.onCancelPressed,
                  onVideoUpdated: widget.onVideoUpdated,
                  onImageUpdated: widget.onImageUpdated,

                )
            )
        );
      }else
        {
          final XFile? file = await _picker.pickVideo(
            source: source,
            preferredCameraDevice: CameraDevice.rear,
          );
          movedToNext = true;
          imageSelected = file as File;

          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) =>
                      MediaEditor(file: videoSelected as File,
                        fileType: FileType.video,

                        shouldPreview: widget.shouldPreview,
                        saveToGallery: widget.saveToGallery,
                        backgroundColor: widget.backgroundColor,
                        primaryColor: widget.primaryColor,
                        secondaryColor: widget.secondaryColor,

                        onCancelPressed: widget.onCancelPressed,
                        onVideoUpdated: widget.onVideoUpdated,
                        onImageUpdated: widget.onImageUpdated,

                      )
              )
          );
        }

  }

  _doneEdit() {
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
        title: widget.shouldPreview ? Text('Media Picker', style: TextStyle(
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
        child: Column(
          children: [
            SizedBox(height: 20),
            _buildMediaButton(
              onPressed: () => _pickMedia(ImageSource.camera),
              label: 'Pick Image from Camera',
            ),
            _buildMediaButton(
              onPressed: () => _pickMedia(ImageSource.gallery),
              label: 'Pick Image from Gallery',
            ),
            _buildMediaButton(
              onPressed: () => _pickMedia(ImageSource.camera, isVideo: true),
              label: 'Pick Video from Camera',
            ),
            _buildMediaButton(
              onPressed: () => _pickMedia(ImageSource.gallery, isVideo: true),
              label: 'Pick Video from Gallery',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton({required VoidCallback onPressed, required String label}) {
    // If buttonTemplate is provided, use it. Otherwise, use the default button.
    if (widget.buttonTemplate != null) {
      return GestureDetector(
        onTap: onPressed,
        child: widget.buttonTemplate,  // Use the provided button template
      );
    }

    // Use primaryColor for background and secondaryColor for text if provided
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: primaryColor ?? Theme.of(context).primaryColor,  // Default to theme primary color if not provided
      ),
      child: Text(
        secondaryColor != null ? secondaryColor!.value.toRadixString(16) : label,
        style: TextStyle(
          color: secondaryColor ?? Colors.white,  // Default to white text if secondaryColor is not provided
        ),
      ),
    );
  }

}
