
import 'package:camera/camera.dart';
import 'package:face_detection/utilScanner.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  CameraController cameraController;
  bool isWorking = false;
  FaceDetector faceDetector;
  Size size;
  List<Face> facesList;
  CameraDescription description;
  CameraLensDirection cameraDirection = CameraLensDirection.front;


  initCamera()async{
    description = await UtilsScanner.getCamera(cameraDirection);
    cameraController = CameraController(description, ResolutionPreset.medium);
    faceDetector = FirebaseVision.instance.faceDetector(FaceDetectorOptions(
      enableClassification: true,
      minFaceSize: 0.1,
      mode: FaceDetectorMode.fast,

    ));
    await cameraController.initialize().then((value) {
      if(!mounted){
        return;
      }
      cameraController.startImageStream((imageFromStream) => {
        if(!isWorking){
          isWorking = true,
          performDetectionOnStreamFrame(imageFromStream)
        }
      });
    });
  }


  dynamic scanResults;
  performDetectionOnStreamFrame(CameraImage cameraImage)async{
    UtilsScanner.detect(
      image: cameraImage,
      detectInImage: faceDetector.processImage,
      imageRotation: description.sensorOrientation,

    ).then((dynamic results) {
    setState(() {
      scanResults = results;
    });

    }).whenComplete(() {
      isWorking = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initCamera();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController.dispose();
    faceDetector.close();
  }


  Widget buildResult(){
    if(scanResults == null || cameraController == null || !cameraController.value.isInitialized){
        return Text(" ");
    }

    final Size imageSize = Size(cameraController.value.previewSize.height, cameraController.value.previewSize.width);


    CustomPainter customPainter = FaceDetectorPainter(imageSize, scanResults, cameraDirection);

    return CustomPaint(painter:  customPainter,);
  }

  toggleCameraFrontOrBack()async{
    if(cameraDirection == CameraLensDirection.back){
      cameraDirection = CameraLensDirection.front;
    }
    if(cameraDirection == CameraLensDirection.front){
      cameraDirection = CameraLensDirection.back;
    }

    await cameraController.stopImageStream();
    await cameraController.dispose();

    setState(() {
      cameraController = null;
    });
    initCamera();
  }


  @override
  Widget build(BuildContext context) {
    List<Widget> steckWidgetChldrn = [];
    size = MediaQuery.of(context).size;
    if(cameraController != null){
      steckWidgetChldrn.add(
       Positioned(
         top: 0,
         left: 0,
         width: size.width,
         height: size.height-250,
         child: Container(
           child: (cameraController.value.isInitialized) ?
           AspectRatio(
             aspectRatio: cameraController.value.aspectRatio,
             child: CameraPreview(cameraController),
           )
               :Container(),
         ),
       )
      );
    }

    steckWidgetChldrn.add(
     Positioned(
      top: 0,
      left: 0,
      width: size.width,
       height: size.height -250,
       child: buildResult(),
     )
    );
    
    
    steckWidgetChldrn.add(
      Positioned(
        top: size.height-250,
        left: 0,
        width: size.width,
        height: 250,
        child: Container(
          margin: EdgeInsets.only(bottom: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.cached,color: Colors.white,),
                iconSize: 50,
                color: Colors.black,
                onPressed: (){
                  toggleCameraFrontOrBack();
                },
              ),
            ],
          ),
        ),
      )
    );

    return Scaffold(
      body:  Container(
        margin: EdgeInsets.only(top: 0),
        color: Colors.black,
        child: Stack(
        children: steckWidgetChldrn,
        ),
      ),
    );
  }
}


class FaceDetectorPainter extends CustomPainter{

  FaceDetectorPainter(this.adsoluteImageSize,this.faces,this.cameraLensDirection);

  final Size adsoluteImageSize;
  final List<Face> faces;
  CameraLensDirection cameraLensDirection;



  @override
  void paint(Canvas canvas, Size size) {

    final double scaleX = size.width / adsoluteImageSize.width;
    final double scaleY = size.height / adsoluteImageSize.height;

    final Paint paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..color = Colors.red;


    for(Face face in faces){
      canvas.drawRect(
          Rect.fromLTRB(
            cameraLensDirection  == CameraLensDirection.front?(adsoluteImageSize.width-face.boundingBox.right) * scaleX:face.boundingBox.left * scaleX,
            face.boundingBox.top * scaleY,
            cameraLensDirection  == CameraLensDirection.front?(adsoluteImageSize.width-face.boundingBox.left) * scaleX:face.boundingBox.right * scaleX,
            face.boundingBox.bottom * scaleY,
          ),
          paint
      );
    }

  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return  oldDelegate.adsoluteImageSize != adsoluteImageSize || oldDelegate.faces != faces;
  }
}