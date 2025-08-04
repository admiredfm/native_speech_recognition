
import 'dart:async';
import 'dart:typed_data';

import 'package:native_speech_recognition/simhash.dart';

import 'native_speech_recognition_platform_interface.dart';

class NativeSpeechRecognition {

  NativeSpeechRecognitionPlatform get _methodChannel => NativeSpeechRecognitionPlatform.methodChannel;
  NativeSpeechRecognitionPlatform get _eventChannel => NativeSpeechRecognitionPlatform.eventChannel;

  Future<String?> getPlatformVersion() {
    return _methodChannel.getPlatformVersion();
  }

  Future<void> start() async {
    await _methodChannel.start();
  }

  Future<void> stop() async{
    _methodChannel.stop();
  }

  Future<void> sendAudioData(Uint8List data) async{
    await _methodChannel.sendAudioData(data);
  }

  Future<void> setLocale(String locale) async{
    _methodChannel.setLocale(locale);
  }

  Future<Map<String, String>> getSupportedLocales() async{
    return await _methodChannel.getSupportedLocales();
  }

  Future<Map<String, String>> getCurrentLocale() async {
    return await _methodChannel.getCurrentLocale();
  }

  StreamSubscription<dynamic> onResult(Function(dynamic) callback, {double threshold = 0.7}) {
    return _eventChannel.onResult(callback, threshold: threshold);
  }

  StreamSubscription<dynamic> onAudioData(Function(dynamic) callback) {
    return _eventChannel.onAudioData(callback);
  }

  double testTextSimilarity(String t1, String t2){
    final int hash1 = SimHash.getSimHash(t1);
    final int hash2 = SimHash.getSimHash(t2);

    return SimHash.similarity(hash1, hash2);
  }

}
