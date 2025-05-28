import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:native_speech_recognition/native_speech_recognition.dart';
import 'package:native_speech_recognition/native_speech_recognition_platform_interface.dart';
import 'package:native_speech_recognition/native_speech_recognition_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeSpeechRecognitionPlatform
    with MockPlatformInterfaceMixin
    implements NativeSpeechRecognitionPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  StreamSubscription onAudioData(Function(dynamic p1) callback) {
    // TODO: implement onAudioData
    throw UnimplementedError();
  }

  @override
  StreamSubscription onResult(Function(dynamic p1) callback) {
    // TODO: implement onResult
    throw UnimplementedError();
  }

  @override
  Future<void> setLocale(String locale) {
    // TODO: implement setLocale
    throw UnimplementedError();
  }

  @override
  Future<void> start() {
    // TODO: implement start
    throw UnimplementedError();
  }

  @override
  Future<void> stop() {
    // TODO: implement stop
    throw UnimplementedError();
  }

  @override
  Future<Map<String, String>> getSupportedLocales() {
    // TODO: implement getSupportedLocales
    throw UnimplementedError();
  }

  @override
  Future<Map<String, String>> getCurrentLocale() {
    // TODO: implement getCurrentLocale
    throw UnimplementedError();
  }
}

void main() {
  final NativeSpeechRecognitionPlatform initialPlatform = NativeSpeechRecognitionPlatform.methodChannel;

  test('$MethodChannelNativeSpeechRecognition is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeSpeechRecognition>());
  });

  test('getPlatformVersion', () async {
    NativeSpeechRecognition nativeSpeechRecognitionPlugin = NativeSpeechRecognition();
    MockNativeSpeechRecognitionPlatform fakePlatform = MockNativeSpeechRecognitionPlatform();
    NativeSpeechRecognitionPlatform.instance = fakePlatform;

    expect(await nativeSpeechRecognitionPlugin.getPlatformVersion(), '42');
  });
}
