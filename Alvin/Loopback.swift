//
//  Loopback.swift
//  Alvin
//
//  Created by Thibaut WEISSGERBER on 25/08/2017.
//  Copyright © 2017 Gaetan GROMER. All rights reserved.
//

import Foundation
import AVFoundation

class Loopback: NSObject, AVAudioPlayerDelegate
{
    static var shared: Loopback = Loopback()
    
    let documentDirectory: URL = FileManager.shared.documentsDirectory!
    let fileExtension: String = "caf"
    let dateFormatter: DateFormatter = DateFormatter()
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
    var lastDate: Date = Date()

    
    private override init() {
        self.dateFormatter.dateFormat = "yyyy_MM_dd-HH_mm_ss"
    }
    
    public func updateMeters() {
        self.recorder?.updateMeters()
    }
    
    public func getAveragePower() -> CGFloat {
        if self.recorder?.isRecording == true {
            return pow(10, CGFloat((self.recorder?.averagePower(forChannel: 0))!) / 20)
        }
        else {
            return 0
        }
    }
    
    public func getRecordingBaseName() -> String {
        return self.dateFormatter.string(from: self.lastDate)
    }
    
    public func getInitialRecordingName() -> String {
        return "\(self.getRecordingBaseName())-0.\(self.fileExtension)"
    }
    
    public func getNextRecordingName() -> String {
        return "\(self.getRecordingBaseName())-\(self.recordingIndex.description).\(self.fileExtension)"
    }
    
    public func getNextPlayingName() -> String {
        return "\(self.getRecordingBaseName())-\(self.playingIndex.description).\(self.fileExtension)"
    }
    
    public func startRecording() {
        let listOfInputs = AVAudioSession.sharedInstance().availableInputs
        let availableInput: AVAudioSessionPortDescription = listOfInputs![0] as AVAudioSessionPortDescription
        
        self.lastDate = Date()
        
        do {
            try AVAudioSession.sharedInstance().setPreferredInput(availableInput)
            
            let recordingName: String = self.getInitialRecordingName()
            let recordingUrl: URL = self.documentDirectory.appendingPathComponent(recordingName)
            
            self.recorder = try AVAudioRecorder(url: recordingUrl, settings: self.recordingSettings)
            self.recorder?.isMeteringEnabled = true
            self.recorder?.record()
        }
        catch let error {
            log.error(error.localizedDescription)
        }
    }
    
    public func stopRecording() {
        self.recorder?.stop()
    }
    
    public func startLoopback() {
        do {
            let recordingName: String = self.getNextRecordingName()
            let playingName: String = self.getNextPlayingName()
            let recordingUrl: URL = self.documentDirectory.appendingPathComponent(recordingName)
            let playingUrl: URL = self.documentDirectory.appendingPathComponent(playingName)
            
            try self.recorder = AVAudioRecorder(url: recordingUrl, settings: self.recordingSettings)
            self.recorder?.record()
            
            log.info("recording \(recordingName)")
            
            try self.player = AVAudioPlayer(contentsOf: playingUrl)
            self.player?.delegate = self
            self.player?.play()
            
            log.info("playing \(playingName)")
            
            self.playingIndex += 1
            self.recordingIndex += 1
        }
        catch let error {
            log.error(error.localizedDescription)
        }
    }
    
    public func stopLoopback() {
        self.recorder?.stop()
        self.player?.stop()
        self.recordingIndex = 1
        self.playingIndex = 0
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player?.stop()
        self.recorder?.stop()
        
        if self.isLoopbacking == true {
            self.startLoopback()
        }
        else {
            self.stopLoopback()
        }
    }
}
