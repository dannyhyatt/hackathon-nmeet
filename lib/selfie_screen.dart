import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:nomeet/main.dart';
import 'package:dio/dio.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SelfieScreen extends StatefulWidget {
  @override
  _SelfieScreenState createState() => _SelfieScreenState();
}

class _SelfieScreenState extends State<SelfieScreen> {

  CameraController controller;
  List<CameraDescription> cameras;
  LoadingState loadingState = LoadingState.LOADING;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void init() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.ultraHigh);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        loadingState = LoadingState.NOT_LOADING;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: loadingState == LoadingState.LOADING ? Center(child: CircularProgressIndicator()) :
        Column(
          children: <Widget>[
            RotationTransition(
              turns: AlwaysStoppedAnimation(3/4),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                ),
              ),
            ),
            OutlineButton(
              child: Text('take picture'),
              onPressed: () {
                takePicture().then((String filePath) async {
                  if (filePath != null) scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Picture saved to $filePath')));
                  setState(() {
                    loadingState = LoadingState.LOADING;
                  });
                  String fileName = filePath.split('/').last;
                  FormData formData = FormData.fromMap({
                    "file":await MultipartFile.fromFile(filePath, filename:fileName),
                    'username' : MyApp.username,
                    'password' : MyApp.password
                  });
                  Response res = await MyApp.dio.post("http://10.0.2.2:5000/uploadSelfie", data: formData);
                  debugPrint('data::: ${res.data}');
                  if(res.data ['success'] == true) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SelfieScreen()));
                  }
                });
              },
            )
          ],
        ),
    );
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(('Error: select a camera first.'))));
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
//      _showCameraException(e);
      return null;
    }
    return filePath;
  }
}
