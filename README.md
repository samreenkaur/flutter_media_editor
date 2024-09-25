# flutter_media_editor

A new Flutter project.

## Screenshot
1. Crop Image

![Simulator Screen Shot - iPhone 12 Pro Max - 2021-11-12 at 15 51 38](https://user-images.githubusercontent.com/82141553/141455112-ac81e705-2f5b-43c1-a2f2-7a0b5dddb8dc.png) ![Simulator Screen Shot - iPhone 12 Pro Max - 2021-11-12 at 15 51 52](https://user-images.githubusercontent.com/82141553/141455125-4a5cbe88-d41e-4e78-a277-ff42220c69d9.png)

2. Crop/Trim Video

![Simulator Screen Shot - iPhone 12 Pro Max - 2021-11-12 at 15 52 15](https://user-images.githubusercontent.com/82141553/141455152-ec5c3fe3-f1fb-4728-ae05-463fbb764ee7.png) ![Simulator Screen Shot - iPhone 12 Pro Max - 2021-11-12 at 15 52 31](https://user-images.githubusercontent.com/82141553/141457050-463f8ea2-607c-479f-8b8d-f08b4c2d3b1d.png) ![Simulator Screen Shot - iPhone 12 Pro Max - 2021-11-12 at 16 23 16](https://user-images.githubusercontent.com/82141553/141457086-17b0c408-7904-4eb6-9af5-165010eb6631.png) ![Simulator Screen Shot - iPhone 12 Pro Max - 2021-11-12 at 16 30 15](https://user-images.githubusercontent.com/82141553/141457128-9723cc85-6d65-4df9-a25f-172aecda5e8e.png)


## Getting Started

With this package you can crop/trim your photos and videos.

## iOS Target

This package will work for iOS 13 or later versions.

## iOS plist config

Because the album is a privacy privilege, you need user permission to access it. You must to modify the Info.plist file in Runner project.

``` 
    <key>NSCameraUsageDescription</key>
    <string>Use</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>Use</string>
    <key>NSAppleMusicUsageDescription</key>
    <string>Use</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Use</string>
    
``` 

## 1.  Add in pubspec.yaml file under

dependencies:
``` 
 flutter_media_editor:  
   git:  
     url: https://github.com/samreenkaur/flutter_media_editor.git
``` 

## 2. Add package

``` 
import 'package:test_flutter_media_editor/MediaPicker.dart';


``` 


## 3.  Use in the code like this:

1. MediaPicker (image and video)
``` 
    Navigator.of(context).push(
          MaterialPageRoute(
          builder: (context) =>
              MediaPicker()
          )
      );
``` 

2. For image

``` 
        MediaEditor(file: <galleryImagePicked> as File,
                shouldPreview: true,
                fileType: FileType.image,
                onImageUpdated: (file) {
                  if (mounted) {
                    setState(() {

                    });
                  }
                },
              ),

``` 
3. For video

``` 
        MediaEditor(file: <galleryVideoPicked> as File,
                  shouldPreview: true,
                  fileType: FileType.video,
                  onVideoUpdated: (file) {
                    _controller = VideoPlayerController.file(file)
                      ..initialize().then((_) {
                        _controller.pause();
                        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                        setState(() {});
                      });
                  },
                ),

``` 

##4. Description of arguments and Other benefits

``` 
1. File file :
    You need to pass the file image/video which you want to edit.
2. FileType fileType :
    In this, you need to pass the type of file i.e. image or video.
3. VideoUpdated? onVideoUpdated :
    In this function, you will get callback on done button click and get the final video edited.
4. ImageUpdated? onImageUpdated :
    In this function, you will get callback on done button click and get the final image edited.
5. CancelPressed? onCancelPressed  :
    In this function, you will get calback on cancel button click. 
6. bool shouldPreview :
    If want to preview your file, then pass true. default is false.
7. bool saveToGallery :
    If want to save the returned file to gallery, then pass true. default is false.
8. Color? backgroundColor :
    If want to change the background color, default is black.
9. Color? primaryColor :
    If want to change the primary color, default is black.
10. Color? secondaryColor :
    If want to change the secondary color, default is white.
``` 
