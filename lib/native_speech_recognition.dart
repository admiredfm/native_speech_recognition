
import 'dart:async';

import 'native_speech_recognition_platform_interface.dart';

class NativeSpeechRecognition {

  NativeSpeechRecognitionPlatform get _methodChannel => NativeSpeechRecognitionPlatform.methodChannel;
  NativeSpeechRecognitionPlatform get _eventChannel => NativeSpeechRecognitionPlatform.eventChannel;

  Future<String?> getPlatformVersion() {
    return _methodChannel.getPlatformVersion();
  }

  Future<void> start() async {
    _methodChannel.start();
  }

  Future<void> stop() async{
    _methodChannel.stop();
  }

  Future<void> setLocale(String locale) async{
    _methodChannel.setLocale(locale);
  }

  Future<Map<String, String>> getSupportedLocales() async{
    return await _methodChannel.getSupportedLocales();
  }

  StreamSubscription<dynamic> onResult(Function(dynamic) callback) {
    return _eventChannel.onResult(callback);
  }

  StreamSubscription<dynamic> onAudioData(Function(dynamic) callback) {
    return _eventChannel.onAudioData(callback);
  }






}
