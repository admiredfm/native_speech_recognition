import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:native_speech_recognition/simhash.dart';

import 'native_speech_recognition_platform_interface.dart';

class EventChannelNativeSpeechRecognition extends NativeSpeechRecognitionPlatform{

  @visibleForTesting
  late final EventChannel resultEvent = EventChannel(NativeSpeechRecognitionPlatform.resultEventChannelName);
  late final EventChannel audioDataEvent = EventChannel(NativeSpeechRecognitionPlatform.audioDataEventChannelName);

  @override
  StreamSubscription<dynamic> onResult(Function(dynamic p1) callback, {double threshold = 0.7}) {
    String lastText = "";
    return resultEvent
        .receiveBroadcastStream()
        .transform(StreamTransformer.fromHandlers(
        handleData: (dynamic event,EventSink<Map<String, dynamic>> sink){
          if(event == null){
            return;
          }
          final currentText = event['text'] as String ?? "";
          if(lastText.isEmpty || currentText.startsWith(lastText)){
            sink.add({
              "text": currentText,
              "isFinal": false
            });
            lastText = currentText;
            return;
          }

          final similar = SimHash.isSimilar(lastText, currentText, threshold);
          if(similar){
            sink.add({
              "text": currentText,
              "isFinal": false
            });
            lastText = currentText;
            return;
          }
          sink.add({
            "text": lastText,
            "isFinal": true
          });
          sink.add({
            "text": currentText,
            "isFinal": false
          });
          lastText = "";
        }

    )).listen((event) => callback(event));
  }

  @override
  StreamSubscription<dynamic> onAudioData(Function(dynamic p1) callback) {
    return audioDataEvent.receiveBroadcastStream().listen((event) => callback(event));
  }

}