import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class TfliteModel extends StatefulWidget {
  const TfliteModel({Key? key}) : super(key: key);

  @override
  _TfliteModelState createState() => _TfliteModelState();
}

class _TfliteModelState extends State<TfliteModel> {
  
  late File _image;
  late List _results;
  bool imageSelect=false;
  @override
  void initState()
  {
    super.initState();
    loadModel();
  }
  Future loadModel()
  async {    Tflite.close();
    String res;
    res=(await Tflite.loadModel(model: "assets/disease_classification.tflite",labels: "assets/labels.txt"))!;
    print("Models loading status: $res");
  }

  Future imageClassification(File image)
  async {
    final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 224,
      imageStd: 224,
    );
    setState(() {
      _results=recognitions!;
      _image=image;
      imageSelect=true;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Disease Detector", style: TextStyle(fontFamily: 'Schyler', fontWeight: FontWeight.w600, fontSize: 40),),
        backgroundColor: Color.fromRGBO(0, 155, 0, 1),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            (imageSelect)?Container(
          margin: const EdgeInsets.all(10),
          child: Image.file(_image),
        ):Container(
              height: 650,
          margin: const EdgeInsets.all(10),
              child: Opacity(
                opacity: 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Please select an image in order to proceed ahead.", style: TextStyle(fontFamily: 'Schyler', fontSize: 30),textAlign: TextAlign.center,),
                  ],
                ),
              ),
        ),
            SingleChildScrollView(
              child: Column(
                children: (imageSelect)?_results.map((result) {
                  return Card(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Text(
                        "${result['label']} - ${result['confidence'].toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.red,
                        fontSize: 20),
                      ),
                    ),
                  );
                }).toList():[],

              ),

            ),

            // ElevatedButton(onPressed: pickImage, child:  const Icon(Icons.image),)
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 340,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
              onPressed: pickImage,
              tooltip: "Pick Image",
              child: const Icon(Icons.image),
              backgroundColor: Colors.indigoAccent,
            ),
            FloatingActionButton(
              onPressed: clickImage,
              tooltip: "Capture Image",
              child: const Icon(Icons.camera_alt),
              backgroundColor: Colors.indigoAccent,
            ),
          ],
        ),
      ),

    );
  }
  Future pickImage()
  async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    File image=File(pickedFile!.path);
    imageClassification(image);
  }

  Future clickImage()
  async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    File image=File(pickedFile!.path);
    imageClassification(image);
  }
}
