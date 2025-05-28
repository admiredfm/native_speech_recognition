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
    methodChannel.invokeMethod("start");
  }

  @override
  Future<void> stop() async {
    methodChannel.invokeMethod("stop");
  }

  @override
  Future<void> setLocale(String locale) async {
    methodChannel.invokeMethod("setLocale", locale);
  }

  @override
  Future<Map<String, String>> getSupportedLocales() async {
    final locales = await methodChannel.invokeMethod("getSupportedLocales");
    return Map<String, String>.from(locales);
  }

  @override
  Future<Map<String, String>> getCurrentLocale() async {
    return await methodChannel.invokeMethod("getCurrentLocale");
  }



}
