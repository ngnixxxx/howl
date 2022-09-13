import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/pages/answer_layout.dart';
import 'package:howl/perefs/stories_pref.dart';
import 'package:howl/widgets/custom_dialog.dart';
import 'package:path_provider/path_provider.dart';

import 'package:video_player/video_player.dart';

class CameraPage extends StatefulWidget {
  final Function jumpToChat;

  CameraPage({
    this.jumpToChat,
  });
  @override
  _CameraPageState createState() => _CameraPageState();
}

Future<Null> _restartCamera(CameraDescription description) async {
  camController = new CameraController(description, ResolutionPreset.max);
  await camController.initialize();
}

Future<Null> flipCamera() async {
  if (camController != null) {
    var newDescription = _cameras.firstWhere((desc) {
      return desc.lensDirection != camController.description.lensDirection;
    });

    await _restartCamera(newDescription);
  }
}

void playPause() {
  if (camController != null) {
    if (camController.value.isInitialized) {
      camController.stopImageStream();
    } else {
      camController.startImageStream((CameraImage cameraImage) {});
    }
  }
}

CameraController camController;
List<CameraDescription> _cameras = [];

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  Future<void> _initializeControllerFuture;
//  FlashMode flashMode = FlashMode.off;
  String imagePath, videoPath;
  VideoPlayerController vidController;
  VoidCallback videoPlayerController;
  bool enableAudio = true,
      saved = false,
      imageTaken = false,
      mediaIsOpen = false;
  int pictureCount = 0;
  double aspectRatio;
  double camControllerAspect;
  TabController tabController;

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

//  Widget _flashButton() {
//    IconData iconData = Icons.flash_off;
//    Color color = Colors.black;
//    if (flashMode == FlashMode.alwaysFlash) {
//      iconData = Icons.flash_on;
//      color = Colors.blue;
//    } else if (flashMode == FlashMode.autoFlash) {
//      iconData = Icons.flash_auto;
//      color = Colors.red;
//    }
//    return IconButton(
//      icon: Icon(iconData, color: Colors.white),
//      color: color,
//      onPressed: camController != null && camController.value.isInitialized
//          ? _onFlashButtonPressed
//          : null,
//    );
//  }
//
//  /// Toggle Flash
//  Future<void> _onFlashButtonPressed() async {
//    bool hasFlash = false;
//    if (flashMode == FlashMode.off || flashMode == FlashMode.torch) {
//      // Turn on the flash for capture
//      flashMode = FlashMode.alwaysFlash;
//    } else if (flashMode == FlashMode.alwaysFlash) {
//      // Turn on the flash for capture if needed
//      flashMode = FlashMode.autoFlash;
//    } else {
//      // Turn off the flash
//      flashMode = FlashMode.off;
//    }
//    // Apply the new mode
//    await camController.setFlashMode(flashMode);
//
//    // Change UI State
//    setState(() {});
//  }

//  void toogleAutoFocus() {
//    camController.setAutoFocus(!camController.value.autoFocusEnabled);
//    showInSnackBar('Toogle auto focus');
//  }

  void snapPhoto() async {
    await _initializeControllerFuture;
    try {
      final Directory extDir = await getTemporaryDirectory();
      final String dirPath = '${extDir.path}/Pictures/howl';
      await Directory(dirPath).create(recursive: true);
      final String path = '$dirPath/howl_${timestamp()}.jpg';
      await camController.takePicture();

      setState(() {
        imagePath = path;
        imageTaken = true;
        print(imagePath);
      });
    } catch (e) {}
  }

  @override
  void initState() {
    aspectRatio = MediaQuery.of(context).size.aspectRatio;
    camControllerAspect = camController.value.aspectRatio;
    imageTaken = false;
    saved = false;

    super.initState();

    WidgetsBinding.instance.addObserver(this);
    availableCameras().then((cams) {
      _cameras = cams;
      camController = new CameraController(
        _cameras[1],
        ResolutionPreset.ultraHigh,
      );
      _initializeControllerFuture = camController.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    camController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      var description = _cameras.firstWhere((desc) {
        return desc.lensDirection == camController.description.lensDirection;
      });

      _restartCamera(description).then((_) {
        setState(() {});
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return AnswerLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot != null) {
                return !imageTaken ? cameraView() : takenImageView();
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }

  Widget cameraView() {
    return Stack(
      children: [
        Container(
          child: Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onDoubleTap: () async {
                flipCamera();
                setState(() {});
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: camController.value.aspectRatio,
                  child: CameraPreview(camController),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: Icon(Feather.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => StoryPerfs()));
                  }),
              IconButton(
                  icon: Icon(Feather.message_circle, color: Colors.white),
                  onPressed: () => widget.jumpToChat()),
              IconButton(
                  icon: Icon(Feather.message_circle, color: Colors.white),
                  onPressed: () => widget.jumpToChat()),
            ],
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  child: captureControlRowWidget(),
                ),
                Flexible(
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: 10, top: 5, right: 10, bottom: 5),
                      child: Row(
                        children: [
                          GestureDetector(
                            child: Container(
                                height: 35,
                                width: 35,
                                constraints:
                                    BoxConstraints(maxHeight: 35, maxWidth: 35),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                )),
                            onTap: () {},
                          ),
                          SizedBox(width: 10),
                          IconButton(
                              icon: Icon(Feather.repeat, color: Colors.white),
                              onPressed: () async {
                                flipCamera();
                                setState(() {});
                              }),
                        ],
                      )),
                ),
              ],
            )),
      ],
    );
  }

  Widget takenImageView() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: ClipRect(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                child: Transform.scale(
                  scale: camControllerAspect / aspectRatio,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: camController.value.aspectRatio,
                      child: Image.file(File(imagePath)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                    icon: Icon(Feather.x, color: Colors.white),
                    onPressed: () {
                      return showDialog(
                          context: context,
                          builder: (_) {
                            return CustomDialog(
                              title: 'Discard Image',
                              content: Text(
                                  'Are you sure you want to discard this image',
                                  style: Theme.of(context).textTheme.bodyText1),
                              function: () => discardImage(),
                              mainActionText: 'Discard',
                              function1: () {
                                Navigator.pop(context);
                              },
                              secondaryActionText: 'Keep',
                            );
                          });
                    }),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          icon: Icon(Feather.edit_3, color: Colors.white),
                          onPressed: () {}),
                      IconButton(
                          icon: Icon(Feather.type, color: Colors.white),
                          onPressed: () {}),
                      IconButton(
                          icon: Icon(Feather.smile, color: Colors.white),
                          onPressed: () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: sendControlRowWidget(),
                ),
              ],
            )),
      ],
    );
  }

  Widget captureControlRowWidget() {
    return GestureDetector(
      child: Container(
        height: 70,
        width: 70,
        constraints: BoxConstraints(maxHeight: 70, maxWidth: 70),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(4),
        child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            )),
      ),
      onTap: camController != null &&
              camController.value.isInitialized &&
              !camController.value.isRecordingVideo
          ? snapPhoto
          : null,
      onLongPress: camController != null &&
              camController.value.isInitialized &&
              !camController.value.isTakingPicture
          ? onTakeVideo
          : null,
    );
  }

  Widget sendControlRowWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Column(
                  children: [
                    IconButton(
                        icon: Icon(Feather.film, color: Colors.white),
                        onPressed: () {}),
                    Text(
                      'Story',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        icon: Icon(
                            saved
                                ? Feather.check_circle
                                : Feather.arrow_down_circle,
                            color: Colors.white),
                        onPressed: saved
                            ? () {}
                            : () {
                                savePicture(imagePath);
                              }),
                    Text(
                      saved ? 'Saved' : 'Save',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: Theme.of(context).primaryColor,
            label: Row(
              children: [
                Text(
                  'Send',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(width: 10),
                Icon(Feather.send,
                    size: 20, color: Theme.of(context).primaryIconTheme.color),
              ],
            ),
            elevation: 0,
          ),
        )
      ],
    );
  }

  void discardImage() async {
    await _initializeControllerFuture;
    setState(() {
      imageTaken = false;
    });
    Navigator.pop(context);
  }

  void savePicture(String imagePath) async {
    print(imagePath);
    if (imagePath.isNotEmpty) {
      GallerySaver.saveImage(imagePath).then((value) {
        setState(() {
          saved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved!')),
        );
      }).catchError((onError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('There was an error saving media!')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There was an error image do not exist')),
      );
    }
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (camController != null) {
      await camController.dispose();
    }
    camController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    camController.addListener(() {
      if (mounted) setState(() {});
      if (camController.value.hasError) {
        showInSnackBar('Camera error ${camController.value.errorDescription}');
      }
    });

    try {
      await camController.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakeVideo() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      if (filePath != null) {
        showInSnackBar('Saving video to $filePath');
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recorded to: $videoPath');
    });
  }

  Future<String> takePicture() async {
    if (!camController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/howl';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (camController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await camController.takePicture();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
        VideoPlayerController.file(File(videoPath));
    videoPlayerController = () {
      if (vidController != null && vidController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        vidController.removeListener(videoPlayerController);
      }
    };
    vcontroller.addListener(videoPlayerController);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await vidController?.dispose();
    if (mounted) {
      setState(() {
        imagePath = null;
        vidController = vcontroller;
      });
    }
    await vcontroller.play();
  }

  Future<String> startVideoRecording() async {
    if (!camController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (camController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await camController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!camController.value.isRecordingVideo) {
      return null;
    }

    try {
      await camController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    await _startVideoPlayer();
  }

  void _showCameraException(CameraException e) {
    print('${e.code}, ${e.description}');
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
