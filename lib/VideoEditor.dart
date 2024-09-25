import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_editor/MediaEditor.dart';
import 'package:helpers/helpers.dart';
import 'package:video_editor/video_editor.dart' as ve;
import 'package:video_player/video_player.dart';


//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//

class VideoEditor extends StatefulWidget {
  VideoEditor({Key? key, required this.file, this.onUpdatedVideo, this.onCancelPressed}) : super(key: key);

  final File file;
  final VideoUpdated? onUpdatedVideo;
  final CancelPressed? onCancelPressed;

  @override
  _VideoEditorState createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  bool _exported = false;
  String _exportText = "";
  late ve.VideoEditorController _controller;

  @override
  void initState() {
    _controller = ve.VideoEditorController.file(widget.file,
        maxDuration: Duration(seconds: 30))
      ..initialize().then((_) => setState(() {}));

    super.initState();
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    // ExportService.dispose();
    super.dispose();
  }

  void _openCropScreen() => context.to(CropScreen(controller: _controller));

  // void _exportVideo() async {
  //   _isExporting.value = true;
  //   bool _firstStat = true;
  //   //NOTE: To use [-crf 17] and [VideoExportPreset] you need ["min-gpl-lts"] package
  //   await _controller.exportVideo(
  //     name: DateTime.now().millisecondsSinceEpoch.toString(),
  //     // preset: VideoExportPreset.medium,
  //     // customInstruction: "-crf 17",
  //     onProgress: (statics) {
  //       // First statistics is always wrong so if first one skip it
  //       if (_firstStat) {
  //         _firstStat = false;
  //       } else {
  //         _exportingProgress.value = statics.getTime() /
  //             _controller.video.value.duration.inMilliseconds;
  //       }
  //     },
  //     onCompleted: (file) {
  //       _isExporting.value = false;
  //       if (!mounted) return;
  //       if (file != null) {
  //         _exportText = "Video success export!";
  //         if (widget.onUpdatedVideo != null) {
  //           widget.onUpdatedVideo!(file);
  //           Navigator.pop(context);
  //         }
  //
  //       } else {
  //         _exportText = "Error on export video :(";
  //       }
  //     },
  //   );
  // }
  Future<void> _exportVideo() async {
    _isExporting.value = true;
    bool _firstStat = true;

    try {
      // Generate the FFmpeg command and output path
      final config = ve.VideoFFmpegVideoEditorConfig(_controller);
      final ve.FFmpegVideoEditorExecute execute = await config.getExecuteConfig();

      // Check if the configuration was successful
      if (execute.command == null || execute.outputPath == null) {
        throw Exception("Failed to generate FFmpeg command or output path");
      }

      final command = execute.command!;
      final outputPath = execute.outputPath!;
      final outputFile = File(outputPath);

      // Execute the FFmpeg command
      final session = await FFmpegKit.execute(command);

      final returnCode = await session.getReturnCode();
      if (returnCode?.isValueSuccess() != null) {
        _isExporting.value = false;
        _exportText = "Video successfully exported!";
        if (widget.onUpdatedVideo != null) {
          widget.onUpdatedVideo!(outputFile);
          Navigator.pop(context);
        }
      } else {
        _isExporting.value = false;
        _exportText = "Error exporting video :(";
        throw Exception('FFmpeg process failed with return code: $returnCode');
      }
    } catch (e) {
      _isExporting.value = false;
      print('Error exporting video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting video: ${e.toString()}')),
        );
      }
    }
  }


  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  @override
  Widget build(BuildContext context) {
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
        title: _topNavBar(),
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
              _exportVideo();
            },
          ),
        ],
      ),
      body: _controller.initialized
          ? SafeArea(
          child: Stack(children: [
            Column(children: [

              Expanded(
                  child: DefaultTabController(
                      length: 2,
                      child: Column(children: [
                        Expanded(
                            child: TabBarView(
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                Stack(alignment: Alignment.center, children: [
                                  ve.CropGridViewer.edit(
                                    controller: _controller,
                                    // showGrid: false,
                                  ),
                                  AnimatedBuilder(
                                    animation: _controller.video,
                                    builder: (_, __) => OpacityTransition(
                                      visible: !_controller.isPlaying,
                                      child: GestureDetector(
                                        onTap: _controller.video.play,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: secondaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.play_arrow,
                                              color: primaryColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                                ve.CoverViewer(controller: _controller)
                              ],
                            )),
                        Container(
                            height: 200,
                            margin: Margin.top(10),
                            child: Column(children: [
                              TabBar(
                                indicatorColor: secondaryColor,
                                tabs: [
                                  Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: Margin.all(5),
                                            child: Icon(Icons.content_cut, color: secondaryColor)),
                                        Text('Trim', style: TextStyle(color: secondaryColor),)
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: Margin.all(5),
                                            child: Icon(Icons.video_label, color: secondaryColor)),
                                        Text('Cover', style: TextStyle(color: secondaryColor))
                                      ]),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    Container(
                                        child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: _trimSlider())),
                                    Container(
                                      child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [_coverSelection()]),
                                    ),
                                  ],
                                ),
                              )
                            ])),
                        _customSnackBar(),
                        ValueListenableBuilder(
                          valueListenable: _isExporting,
                          builder: (_, bool export, __) => OpacityTransition(
                            visible: export,
                            child: AlertDialog(
                              backgroundColor: secondaryColor,
                              title: ValueListenableBuilder(
                                valueListenable: _exportingProgress,
                                builder: (_, double value, __) =>
                                    Text(
                                      "Exporting video ${(value * 100).ceil()}%",
                                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                                    ),
                              ),
                            ),
                          ),
                        )
                      ])))
            ])
          ]))
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _topNavBar() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _controller.rotate90Degrees(ve.RotateDirection.left),
            child: Icon(Icons.rotate_left, color: secondaryColor,),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _controller.rotate90Degrees(ve.RotateDirection.right),
            child: Icon(Icons.rotate_right, color: secondaryColor,),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _openCropScreen,
            child: Icon(Icons.crop, color: secondaryColor,),
          ),
        ),

      ],
    );
  }

  String formatter(Duration duration) => [
    duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
    duration.inSeconds.remainder(60).toString().padLeft(2, '0')
  ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;

          return Padding(
            padding: Margin.horizontal(height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt())), style: TextStyle(color: secondaryColor) ),
              Expanded(child: SizedBox()),
              OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(Duration(seconds: start.toInt())), style: TextStyle(color: secondaryColor)),
                  SizedBox(width: 10),
                  Text(formatter(Duration(seconds: end.toInt())), style: TextStyle(color: secondaryColor)),
                ]),
              )
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: Margin.vertical(height / 4),
        child: ve.TrimSlider(
            child: ve.TrimTimeline(
                controller: _controller, padding: EdgeInsets.only(top: 10)),
            controller: _controller,
            height: height,
            horizontalMargin: height / 4),
      )
    ];
  }

  Widget _coverSelection() {
    return Container(
        margin: Margin.horizontal(height / 4),
        child: ve.CoverSelection(
          controller: _controller,
          size: height,
          quantity: 8,
        ));
  }

  Widget _customSnackBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeTransition(
        visible: _exported,
        // direction: SwipeDirection.fromBottom,
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Text(
              _exportText,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

//-----------------//
//CROP VIDEO SCREEN//
//-----------------//
class CropScreen extends StatelessWidget {
  CropScreen({Key? key, required this.controller}) : super(key: key);

  final ve.VideoEditorController controller;

  @override
  Widget build(BuildContext context) {
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
            context.goBack();
            //Navigator.pop(context);
          },
        ),
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
              //2 WAYS TO UPDATE CROP
              //WAY 1:
              controller.updateCrop(controller.minCrop, controller.maxCrop);
              /*WAY 2:
                    controller.minCrop = controller.cacheMinCrop;
                    controller.maxCrop = controller.cacheMaxCrop;
                    */
              context.goBack();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: AnimatedInteractiveViewer(
              maxScale: 2.4,
              child: ve.CropGridViewer.edit(
                  controller: controller, margin: const EdgeInsets.symmetric(horizontal: 60)),
            ),
          ),
          SizedBox(height: 15),
          Container(
            height: 44,
            color: primaryColor,
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.rotate90Degrees(ve.RotateDirection.left),
                  child: Icon(Icons.rotate_left, color: secondaryColor,
                  ),
                ),
              ),
              buildSplashTap(context, "16:9", 16 / 9, padding: Margin.horizontal(10)),
              buildSplashTap(context,  "1:1", 1 / 1),
              buildSplashTap(context,  "4:5", 4 / 5, padding: Margin.horizontal(10)),
              buildSplashTap(context,  "NO", null, padding: Margin.right(10)),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      controller.rotate90Degrees(ve.RotateDirection.right),
                  child: Icon(Icons.rotate_right, color: secondaryColor,
                  ),
                ),
              )
            ]),
          ),
        ]),
      ),
    );
  }

  Widget buildSplashTap(
      BuildContext context,
      String title,
      double? aspectRatio, {
        EdgeInsetsGeometry? padding,
      }) {
    return SplashTap(
      onTap: () => controller.preferredCropAspectRatio = aspectRatio,
      child: Padding(
        padding: padding ?? Margin.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.aspect_ratio, color: secondaryColor,),
            Text(
              title,
              style: TextStyle(
                color: secondaryColor,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}