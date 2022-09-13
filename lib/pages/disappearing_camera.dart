import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/pages/answer_layout.dart';
import 'package:howl/providers/disappearing_image_provider.dart';
import 'package:howl/resources/storage_methods.dart';
import 'package:howl/utils/constants.dart';
import 'package:howl/utils/utilities.dart';
import 'package:howl/widgets/custom_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:video_player/video_player.dart';

class DisappearingCameraPage extends StatefulWidget {
  final String userId;
  final String currentUserId;
  final String username;
  final String groupOrNormal;

  DisappearingCameraPage({
    this.userId,
    this.currentUserId,
    this.username,
    this.groupOrNormal,
  });
  @override
  _DisappearingCameraPageState createState() => _DisappearingCameraPageState();
}

enum FlashMode { off, on, auto }

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

class _DisappearingCameraPageState extends State<DisappearingCameraPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  Future<void> _initializeDisappearingControllerFuture;

  String imagePath, videoPath;
  VideoPlayerController vidController;
  VoidCallback videoPlayerController;
  bool enableAudio = true, saved = false, imageTaken = false;
  int pictureCount = 0;
  int tabIndex;
  int sendTabIndex;
  double aspectRatio;
  double camControllerAspect;
  TabController cameraModesTabController;
  TabController viewTimesTabController;
  StorageMethods _storageMethods = StorageMethods();
  DisappearingImageProvider _uploadProvider;

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  // int serializeCameraFlash(FlashMode flash) {
  //   switch (flash) {
  //     case FlashMode.off:
  //       return 0;
  //     case FLashMode.on:
  //       return 1;
  //     case FLashMode.auto:
  //       return 3;
  //   }
  //   throw ArgumentError('Unknown FlashMode value');
  // }

  @override
  void initState() {
    aspectRatio = MediaQuery.of(context).size.aspectRatio;
    camControllerAspect = camController.value.aspectRatio;
    tabIndex = 1;
    imageTaken = false;
    saved = false;

    super.initState();

    cameraModesTabController =
        TabController(length: 3, vsync: this, initialIndex: 1);
    viewTimesTabController =
        TabController(length: 3, vsync: this, initialIndex: 1);
    WidgetsBinding.instance.addObserver(this);
    availableCameras().then((cams) {
      _cameras = cams;
      camController = new CameraController(_cameras[1], ResolutionPreset.max);
      _initializeDisappearingControllerFuture =
          camController.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }

  // void initiliazeCamera() async {
  //   try {
  //     WidgetsFlutterBinding.ensureInitialized();
  //     _cameras = await availableCameras();
  //     // camController.initialize();
  //   } on CameraException catch (e) {
  //     print('${e.code}, ${e.description}');
  //   }
  // }

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
    _uploadProvider = Provider.of<DisappearingImageProvider>(context);

    return AnswerLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.black,
        body: FutureBuilder<void>(
            future: _initializeDisappearingControllerFuture,
            builder: (context, snapshot) {
              return imageTaken
                  ? Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: ClipRect(
                            child: GestureDetector(
                              onTap: () {},
                              child: AspectRatio(
                                aspectRatio: camController.value.aspectRatio,
                                child: Image.file(File(imagePath)),
                              ),
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 32, horizontal: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        IconButton(
                                            icon: Icon(Feather.x,
                                                color: Colors.white),
                                            onPressed: () {
                                              return showModalBottomSheet(
                                                  context: context,
                                                  builder: (_) {
                                                    return CustomDialog(
                                                      title: 'Discard Image',
                                                      content: Text(
                                                          'Are you sure you want to discard this image',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText1),
                                                      function: discardImage,
                                                      mainActionText: 'Discard',
                                                      secondaryActionText:
                                                          'Keep',
                                                      function1: () =>
                                                          Navigator.pop(
                                                              context),
                                                    );
                                                  });
                                            }),
                                        Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                  icon: Icon(Feather.edit_3,
                                                      color: Colors.white),
                                                  onPressed: () {}),
                                              IconButton(
                                                  icon: Icon(Feather.type,
                                                      color: Colors.white),
                                                  onPressed: () {}),
                                              IconButton(
                                                  icon: Icon(Feather.smile,
                                                      color: Colors.white),
                                                  onPressed: () {}),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                      physics: NeverScrollableScrollPhysics(),
                                      controller: viewTimesTabController,
                                      children: [
                                        onceSendControlRowWidget(),
                                        sendControlRowWidget(),
                                        keepSendControlRowWidget()
                                      ]),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 20,
                                        top: 10,
                                        right: 20,
                                        bottom: 10),
                                    child: viewTimesTab()),
                              ],
                            )),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRect(
                              child: GestureDetector(
                                onDoubleTap: () async {
                                  flipCamera();
                                  setState(() {});
                                },
                                child: AspectRatio(
                                  aspectRatio: aspectRatio,
                                  child: CameraPreview(camController),
                                ),
                                //       Container(
                                //   child: Transform.scale(
                                //     scale: camControllerAspect / aspectRatio,
                                //     child: Center(
                                //       child: AspectRatio(
                                //         aspectRatio:
                                //             camController.value.aspectRatio,
                                //         child: CameraPreview(camController),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              alignment: Alignment.topCenter,
                              padding: EdgeInsets.symmetric(
                                  vertical: 32, horizontal: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                      icon:
                                          Icon(Feather.x, color: Colors.white),
                                      onPressed: () => Navigator.pop(context)),
                                  Text('Send to ${widget.username}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .apply(color: Colors.white)),
                                  IconButton(
                                      icon: Icon(Feather.zap,
                                          color: Colors.white),
                                      onPressed: () {}),
                                ],
                              ),
                            )),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: captureControlRowWidget(),
                            )),
                      ],
                    );
            }),
      ),
    );
  }

  Widget captureControlRowWidget() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          GestureDetector(
            child: Container(
                height: 60,
                width: 60,
                constraints: BoxConstraints(maxHeight: 40, maxWidth: 40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                )),
            onTap: () {},
          ),
          GestureDetector(
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
          ),
          IconButton(
              icon: Icon(
                Feather.repeat,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () async {
                flipCamera();

                setState(() {});
              }),
        ],
      ),
    );
  }

  Widget viewTimesTab() {
    return TabBar(
      controller: viewTimesTabController,
      onTap: (tab) {
        setState(() {
          sendTabIndex = tab;
        });
        print(sendTabIndex);
      },
      isScrollable: true,
      tabs: [
        Tab(text: 'Only Once'),
        Tab(text: 'Disappearing'),
        Tab(text: 'Keep in Chat'),
      ],
      indicatorColor: Colors.white,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.label,
    );
  }

  pickImage(String viewTimes, String viewModes) async {
    File selectedImage = await Variables.pickImage(imagePath: imagePath);
    print(widget.username);
    print(widget.userId);
    print(widget.currentUserId);

    _storageMethods.uploadDisappearingImage(
        username: widget.username,
        image: selectedImage,
        // userId: widget.userId,
        currentUserId: widget.currentUserId,
        viewTimes: viewTimes,
        viewModes: viewModes,
        imageProvider: _uploadProvider,
        groupOrNormal: widget.groupOrNormal);

    Navigator.pop(context);
  }

  Widget onceSendControlRowWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  icon: Icon(
                      saved ? Feather.check_circle : Feather.arrow_down_circle,
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
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => pickImage('1', 'Once'),
          child: Container(
            margin: EdgeInsets.only(right: 20),
            height: 60,
            width: 60,
            constraints: BoxConstraints(maxHeight: 80, maxWidth: 80),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(4),
            child: Container(
                alignment: Alignment.center,
                child: Icon(Feather.send, color: Colors.redAccent.shade100),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.redAccent.shade100, width: 2),
                )),
          ),
        ),
      ],
    );
  }

  Widget sendControlRowWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  icon: Icon(
                      saved ? Feather.check_circle : Feather.arrow_down_circle,
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
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
            child: Container(
              margin: EdgeInsets.only(right: 20),
              height: 60,
              width: 60,
              constraints: BoxConstraints(maxHeight: 80, maxWidth: 80),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(4),
              child: Container(
                  alignment: Alignment.center,
                  child: Icon(
                    Feather.send,
                    color: antarctic_blue,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  )),
            ),
            onTap: () {
              pickImage('2', 'View');
            }),
      ],
    );
  }

  Widget keepSendControlRowWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  icon: Icon(
                      saved ? Feather.check_circle : Feather.arrow_down_circle,
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
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => pickImage('Always', 'Keep'),
          child: Container(
            margin: EdgeInsets.only(right: 20),
            height: 60,
            width: 60,
            constraints: BoxConstraints(maxHeight: 80, maxWidth: 80),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(4),
            child: Container(
                alignment: Alignment.center,
                child: Icon(Feather.send, color: Colors.green.shade300),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade300, width: 2),
                )),
          ),
        ),
      ],
    );
  }

  void discardImage() async {
    await _initializeDisappearingControllerFuture;
    setState(() {
      imageTaken = false;
    });
    Navigator.pop(context);
  }

  void snapPhoto() async {
    await _initializeDisappearingControllerFuture;
    try {
      final Directory extDir = await getTemporaryDirectory();
      final String dirPath = '${extDir.path}/Pictures/Mooncurse';
      await Directory(dirPath).create(recursive: true);
      final String path = '$dirPath/MoonCurse_${timestamp()}.jpg';
      await camController.takePicture();

      setState(() {
        imagePath = path;
        imageTaken = true;
        print(imagePath);
      });
    } catch (e) {}
  }

  void savePicture(String imagePath) async {
    print(imagePath);
    if (imagePath.isNotEmpty) {
      GallerySaver.saveImage(imagePath).then((value) {
        setState(() {
          saved = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'Saved!',
            style: Theme.of(context).textTheme.bodyText1,
          )),
        );
      }).catchError((onError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'There was an error saving media!',
            style: Theme.of(context).textTheme.bodyText1,
          )),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'There was an error image do not exist',
          style: Theme.of(context).textTheme.bodyText1,
        )),
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

  void onTakePicture() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          vidController?.dispose();
          vidController = null;
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
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
    final String dirPath = '${extDir.path}/Pictures/Mooncurse';
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

// class ControlsLayer extends StatelessWidget {
//   final double offset;
//   final Function onTap;
//   final _ShadowTween shadowTween;
//   final _TakePictureTween buttonTween;
//   final CameraIcon cameraIcon;
//   final Function onCameraTap;

//   ControlsLayer({this.offset, this.onTap, this.cameraIcon, this.onCameraTap})
//       : this.buttonTween = new _TakePictureTween(
//             new _TakePicture(
//               70.0,
//               100.0,
//               onTap: onTap,
//             ),
//             new _TakePicture(
//               50.0,
//               80.0,
//             )),
//         this.shadowTween =
//             new _ShadowTween(new _Shadow(-290.0), new _Shadow(-150.0));

//   @override
//   Widget build(BuildContext context) {
//     return new Stack(
//       children: <Widget>[
//         shadowTween.lerp(offset),
//         buttonTween.lerp(offset),
//         new _Controls(cameraIcon, onCameraTap)
//       ],
//     );
//   }
// }

// class _Controls extends StatelessWidget {
//   final CameraIcon cameraIcon;
//   final Function onCameraTap;

//   _Controls(this.cameraIcon, this.onCameraTap);

//   @override
//   Widget build(BuildContext context) {
//     return new Positioned(
//       top: 35.0,
//       left: 20.0,
//       child: new SizedBox(
//         width: 20.0,
//         height: 40.0,
//         child: new GestureDetector(
//           onTap: onCameraTap,
//           child: cameraIcon,
//         ),
//       ),
//     );
//   }
// }
