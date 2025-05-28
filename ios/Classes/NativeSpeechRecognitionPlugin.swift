import Flutter
import UIKit
import Speech

public class NativeSpeechRecognitionPlugin: NSObject, FlutterPlugin {
  private var resultHandler: ResultStreamHandler!
  private var audioDataHandler: ResultStreamHandler!

  private let audioEngine = AVAudioEngine()
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
  private var recognitionTask: SFSpeechRecognitionTask?
  private var authorized: Bool = false
  private var recognizedText: String = ""
  private var currentLocale: Locale = Locale.current


  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_speech_recognition", binaryMessenger: registrar.messenger())

    let resultEventChannel = FlutterEventChannel(name: "native_speech_recognition/result", binaryMessenger: registrar.messenger())
    let audioDataEventChannel = FlutterEventChannel(name: "native_speech_recognition/audioData", binaryMessenger: registrar.messenger())

    let resultHandler = ResultStreamHandler()
    let audioDataHandler = ResultStreamHandler()

    let instance = NativeSpeechRecognitionPlugin()
    instance.audioDataHandler = audioDataHandler
    instance.resultHandler = resultHandler


    registrar.addMethodCallDelegate(instance, channel: channel)
    resultEventChannel.setStreamHandler(resultHandler)
    audioDataEventChannel.setStreamHandler(audioDataHandler)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "start":
        self.getPermissions{
            do {
                guard self.authorized else {
                     result("")
                        return
                     }

                try self.start(flutterResult: result)
            } catch {
                result("")
            }
        }
        break
    case "stop":
        self.stop()
        break
    case "setLocale":
        if let localeString = call.arguments as? String{
            setLocale(localIdentifier: localeString)
        }
        break
    case "getSupportedLocales":
        result(getSupportedLocales());
    case "getCurrentLocale":
        result(getCurrentLocale());
    default:
      result(FlutterMethodNotImplemented)
    }
  }


    func extractData(from buffer: AVAudioPCMBuffer) -> Data? {
            let bufferList = buffer.audioBufferList
            let audioBuffer = bufferList.pointee.mBuffers

            guard let mData = audioBuffer.mData else {
                print("Audio data is empty")
                return nil
            }

            let length = Int(audioBuffer.mDataByteSize)
            return Data(bytes: mData, count: length)
    }

    public func start(flutterResult: @escaping FlutterResult) throws {
        recognitionTask?.cancel()
        self.recognitionTask = nil

        if speechRecognizer?.locale.identifier != currentLocale.identifier {
            speechRecognizer = SFSpeechRecognizer(locale: currentLocale)
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setPreferredSampleRate(16000)
        try audioSession.setPreferredIOBufferDuration(0.016)
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode

        var setting = audioEngine.inputNode.inputFormat(forBus: 0).settings
        setting[AVLinearPCMBitDepthKey] = 16
        setting[AVSampleRateKey] = 16000
        setting[AVLinearPCMIsFloatKey] = 0

        inputNode.removeTap(onBus: 0)

        let recordingFormat = AVAudioFormat.init(settings: setting)

        inputNode.installTap(onBus: 0, bufferSize: 1600, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)

            let format = buffer.format
            let pcmData = self.extractData(from: buffer)

            let resultDict: [String: Any] = [
                "sampleRate": format.sampleRate,
                "channelCount": format.channelCount,
                "data": pcmData
            ]

            self.audioDataHandler.sendResult(resultDict)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequest.shouldReportPartialResults = true

        if #available(iOS 13, *) {
            if speechRecognizer?.supportsOnDeviceRecognition ?? false{
                recognitionRequest.requiresOnDeviceRecognition = true
            }
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let bestTranscription = result.bestTranscription.formattedString
                self.resultHandler.sendResult([
                     "text": bestTranscription,
                     "isFinal": result.isFinal
                ])
            }
            if error != nil {
                self.stop()
                self.resultHandler.sendResult(nil)
                flutterResult(nil)
                print(error)
            }
        }
    }

    public func stop() {
        self.audioEngine.stop()
        self.audioEngine.inputNode.removeTap(onBus: 0)
        self.recognitionRequest = nil
        self.recognitionTask?.cancel()
        self.recognitionTask = nil
    }

    public func getPermissions(callback: @escaping () -> Void){
        SFSpeechRecognizer.requestAuthorization{authStatus in
            OperationQueue.main.addOperation {
               switch authStatus {
                    case .authorized:
                        self.authorized = true
                        callback()
                        break
                    default:
                        break
               }
            }
        }
    }

    public func getSupportedLocales() -> [String: String] {
        var locales = [String: String]()
        let supportedLocales = SFSpeechRecognizer.supportedLocales()
        for locale in supportedLocales {
            let localizedName = locale.localizedString(forLanguageCode: locale.languageCode!)
            locales[locale.identifier] = localizedName
        }
        return locales
    }

    public func setLocale(localIdentifier: String) -> Void {
        currentLocale = Locale(identifier: localIdentifier)
    }

    public func getCurrentLocale() -> [String: String] {
        var locales = [String: String]()
        locales["languageCode"] = currentLocale.languageCode
        locales["identifier"] = currentLocale.identifier
        locales["localizedName"] = currentLocale.localizedString(forLanguageCode: currentLocale.languageCode!)
        return locales
    }


}
