import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_speech_recognition_platform_interface.dart';

/// An implementation of [NativeSpeechRecognitionPlatform] that uses method channels.
class MethodChannelNativeSpeechRecognition extends NativeSpeechRecognitionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = MethodChannel(NativeSpeechRecognitionPlatform.methodChannelName);

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> start() async {
    await methodChannel.invokeMethod("start");
  }

  @override
  Future<void> sendAudioData(Uint8List data) async {
    await methodChannel.invokeMethod("sendAudioData",{
      'data': data,
      'sampleRate': 16000.0
    });
  }

  @override
  Future<void> stop() async {
    await methodChannel.invokeMethod("stop");
  }

  @override
  Future<void> setLocale(String locale) async {
    await methodChannel.invokeMethod("setLocale", locale);
  }

  @override
  Future<Map<String, String>> getSupportedLocales() async {
    final locales = await methodChannel.invokeMethod("getSupportedLocales");
    return Map<String, String>.from(locales);
  }

  @override
  Future<Map<String, String>> getCurrentLocale() async {
    final locale = await methodChannel.invokeMethod("getCurrentLocale");
    return Map<String, String>.from(locale);
  }



}
