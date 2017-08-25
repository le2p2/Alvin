//
//  Loopback.swift
//  Alvin
//
//  Created by Thibaut WEISSGERBER on 25/08/2017.
//  Copyright © 2017 Gaetan GROMER. All rights reserved.
//

import Foundation
import AVFoundation

class Loopback
{
    static var shared: Loopback = Loopback()
    
    let documentDirectory: URL = FileManager.shared.documentsDirectory!
    let recordingSettings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    var recorder: AVAudioRecorder? = nil
    var player: AVAudioPlayer? = nil
    var isRecording: Bool = false
    var isLoopbacking: Bool = false
    var recordingIndex: Int = 1
    var playingIndex: Int = 0

    
    private init() {
        let listOfInputs = AVAudioSession.sharedInstance().availableInputs
        let availableInput: AVAudioSessionPortDescription = listOfInputs![0] as AVAudioSessionPortDescription
        
        do {
            try AVAudioSession.sharedInstance().setPreferredInput(availableInput)
            
            let recordingName: String = self.getInitialRecordingName()
            let recordingUrl: URL = self.documentDirectory.appendingPathComponent(recordingName)
            
            self.recorder = try AVAudioRecorder(url: recordingUrl, settings: self.recordingSettings)
            self.recorder?.isMeteringEnabled = true
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    public func updateMeters() {
        self.recorder?.updateMeters()
    }
    
    public func getAveragePower() -> CGFloat {
        return pow(10, CGFloat((self.recorder?.averagePower(forChannel: 0))!) / 20)
    }
    
    public func getInitialRecordingName() -> String {
        return "recording_0.caf"
    }
    
    public func getNextRecordingName() -> String {
        return "recording_\(self.recordingIndex).caf"
    }
    
    public func getNextPlayingName() -> String {
        return "playing_\(self.playingIndex).caf"
    }
    
    public func startRecording() {
        self.recorder?.record()
    }
    
    public func stopRecording() {
        self.recorder?.stop()
    }
    
    public func startLoopback() {
        
    }
    
    public func stopLoopback() {
        
    }
}
