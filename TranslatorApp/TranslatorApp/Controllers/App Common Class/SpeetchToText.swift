//
//  SpeetchToText.swift
//  Translate All
//
//  Created by admin on 12/07/22.
//

import Foundation
import Speech
import AVFAudio

class SpeetchToText: NSObject {
    
    // Voice To Text
    var speechRecognizer = SFSpeechRecognizer()
    var recognitionRequest : SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    var isStartRecognize = true
    
    // MARK: - Start
    func startRecording(languageCode: String ,_ complition: @escaping (String) -> Void) {
        if !audioEngine.isRunning {
            isStartRecognize = true
            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: languageCode))
            
            // Create instance of audio session to record voice
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                
                 /*
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(AVAudioSession.Category.record)
                try audioSession.setMode(AVAudioSession.Mode.measurement)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                 */
            } catch {
                debugPrint("AudioSession properties weren't set because of an error.")
            }
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            let inputNode = audioEngine.inputNode
            guard let recognitionRequest = recognitionRequest else {
                debugPrint("Unable to create the recognition request")
                return
            }
            
            // Configure request so that results are returned before audio recording is finished
            recognitionRequest.shouldReportPartialResults = true
            
            // A recognition task is used for speech recognition sessions
            // A reference for the task is saved so it can be cancelled
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { result, error in
                var isFinal = false
                if let result = result {
                    isFinal = result.isFinal
                    if result.bestTranscription.formattedString.count > 0 {
                        if self.isStartRecognize {
                            complition(result.bestTranscription.formattedString)
                        }
                    }
                }
                
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                }
            })
            
             /*
            if audioEngine.attachedNodes.count > 0 {
                audioEngine.inputNode.removeTap(onBus: 0)
            }
             */
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
                // recognitionRequest.append(buffer)
            }
            
            // Begin recording
            do {
                self.audioEngine.prepare()
                try self.audioEngine.start()
            } catch {
                debugPrint("audioEngine couldn't start because of an error.")
            }
        }
    }
    
    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            audioEngine.inputNode.removeTap(onBus: 0)
            
            // Cancel the previous task if it's running
            if let recognitionTask = recognitionTask {
                recognitionTask.finish()
                recognitionTask.cancel()
                self.recognitionTask = nil
                self.isStartRecognize = false
                
                // Create instance of Play audio session to record voice
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
                    try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                    
                     /*
                    let audioSession = AVAudioSession.sharedInstance()
                    try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
                    try audioSession.setMode(AVAudioSession.Mode.default)
                    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                      */
                } catch {
                    debugPrint("AudioSession properties weren't set because of an error.")
                }
            }
        }
    }
}
