import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './preview_page.dart';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PreviewPage(
                    picture: picture,
                  )));
    } on CameraException catch (e) {
      debugPrint('Aconteceu um erro ao tirar a foto: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
            Stack(fit: StackFit.expand, alignment: Alignment.center, children: [
      (_cameraController.value.isInitialized)
          ? AspectRatio(
              aspectRatio: _cameraController.value.aspectRatio,
              child: Stack(fit: StackFit.expand, children: [
                CameraPreview(_cameraController),
                cameraOverlay(
                    padding: 50,
                    aspectratio: 1,
                    color: Color.fromARGB(170, 0, 0, 0))
              ]))
          : Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator())),
      Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.20,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                color: Colors.black),
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                  child: IconButton(
                onPressed: cancel,
                iconSize: 50,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, color: Colors.white),
              )),
              Expanded(
                  child: IconButton(
                onPressed: takePicture,
                iconSize: 50,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.circle, color: Colors.white),
              )),
              Expanded(
                  child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 30,
                icon: Icon(
                    _isRearCameraSelected
                        ? CupertinoIcons.switch_camera
                        : CupertinoIcons.switch_camera_solid,
                    color: Colors.white),
                onPressed: () {
                  setState(
                      () => _isRearCameraSelected = !_isRearCameraSelected);
                  initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
                },
              )),
              //const Spacer(),
            ]),
          )),
    ]));
  }

  Widget cameraOverlay(
      {required double padding,
      required double aspectratio,
      required Color color}) {
    return LayoutBuilder(builder: (context, constraints) {
      double parentaspectratio = constraints.maxWidth / constraints.maxHeight;
      double horizontalpadding;
      double verticalpadding;

      if (parentaspectratio < aspectratio) {
        horizontalpadding = padding;
        verticalpadding = (constraints.maxHeight -
                ((constraints.maxWidth - 2 * padding) / aspectratio)) /
            2;
      } else {
        verticalpadding = padding;
        horizontalpadding = (constraints.maxWidth -
                ((constraints.maxHeight - 2 * padding) * aspectratio)) /
            2;
      }
      return Stack(fit: StackFit.expand, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Container(width: horizontalpadding, color: color)),
        Align(
            alignment: Alignment.centerRight,
            child: Container(width: horizontalpadding, color: color)),
        Align(
            alignment: Alignment.topCenter,
            child: Container(
                margin: EdgeInsets.only(
                    left: horizontalpadding, right: horizontalpadding),
                height: verticalpadding,
                color: color)),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                margin: EdgeInsets.only(
                    left: horizontalpadding, right: horizontalpadding),
                height: verticalpadding,
                color: color)),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: horizontalpadding, vertical: verticalpadding),
          //decoration: BoxDecoration(border: Border.all(color: Colors.cyan)),
        )
      ]);
    });
  }
}
