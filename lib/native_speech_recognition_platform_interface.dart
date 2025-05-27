import 'dart:async';

import 'package:native_speech_recognition/native_speech_recognition_event_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_speech_recognition_method_channel.dart';

abstract class NativeSpeechRecognitionPlatform extends PlatformInterface {

  static final String  methodChannelName = "native_speech_recognition";
  static final String  resultEventChannelName = "$methodChannelName/result";
  static final String  audioDataEventChannelName = "$methodChannelName/audioData";

  /// Constructs a NativeSpeechRecognitionPlatform.
  NativeSpeechRecognitionPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeSpeechRecognitionPlatform _methodChannel = MethodChannelNativeSpeechRecognition();
  static NativeSpeechRecognitionPlatform _eventChannel = EventChannelNativeSpeechRecognition();

  /// The default instance of [NativeSpeechRecognitionPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeSpeechRecognition].
  static NativeSpeechRecognitionPlatform get methodChannel => _methodChannel;
  static NativeSpeechRecognitionPlatform get eventChannel => _eventChannel;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeSpeechRecognitionPlatform] when
  /// they register themselves.
  static set instance(NativeSpeechRecognitionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _methodChannel = instance;
    _eventChannel = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> start() async {
    throw UnimplementedError('start() has not been implemented.');
  }

  Future<void> stop() async{
    throw UnimplementedError('stop() has not been implemented.');
  }

  Future<void> setLocale(String locale) async {
    throw UnimplementedError('setLocale() has not been implemented.');
  }

  Future<Map<String, String>> getSupportedLocales() async {
    throw UnimplementedError('setLocale() has not been implemented.');
  }

  StreamSubscription<dynamic> onResult(Function(dynamic) callback){
    throw UnimplementedError('onResult() has not been implemented.');
  }

  StreamSubscription<dynamic> onAudioData(Function(dynamic) callback){
    throw UnimplementedError('onResult() has not been implemented.');
  }

}
