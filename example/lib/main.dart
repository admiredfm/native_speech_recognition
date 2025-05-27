import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:native_speech_recognition/native_speech_recognition.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _nativeSpeechRecognitionPlugin = NativeSpeechRecognition();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _nativeSpeechRecognitionPlugin.getPlatformVersion() ?? 'Unknown platform version';

      var locales = await _nativeSpeechRecognitionPlugin.getSupportedLocales();
      print(locales);

      _nativeSpeechRecognitionPlugin.onResult((result){
        print("result:$result");
      });

      _nativeSpeechRecognitionPlugin.onAudioData((data){
        print("data:$data");
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }


  bool isRunning = false;
  void tapIcon(){
    if(isRunning){
      _nativeSpeechRecognitionPlugin.stop();
    }else{
      _nativeSpeechRecognitionPlugin.start();
    }
    setState(() {
      isRunning = !isRunning;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(

          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('状态:$isRunning'),
              TextButton.icon(onPressed: tapIcon, label: Text("开始")),
              TextButton.icon(onPressed: (){
                _nativeSpeechRecognitionPlugin.setLocale("zh-CN");
              }, label: Text("设置成中文"))
            ],
          ),
        ),
      ),
    );
  }
}
