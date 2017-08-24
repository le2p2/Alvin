//
//  ViewController.swift
//  Alvin
//
//  Created by Thibaut WEISSGERBER on 23/08/2017.
//  Copyright © 2017 Gaetan GROMER. All rights reserved.
//

import UIKit
import AudioKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate
{
    let documentDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    var microphone: AKMicrophone? = nil
    var frequencyTracker: AKFrequencyTracker? = nil
    var booster: AKBooster? = nil
    var recorder: AVAudioRecorder? = nil
    var player: AVAudioPlayer? = nil
    var isRecording: Bool = false
    var isLoopbacking: Bool = false
    var recordingIndex: Int = 1
    var playingIndex: Int = 0
    var recordingSettings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    @IBOutlet weak var nodeOutputPlot: EZAudioPlot!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var loopbackButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.microphone = AKMicrophone()
        self.frequencyTracker = AKFrequencyTracker(self.microphone)
        self.booster = AKBooster(self.frequencyTracker, gain: 0)
        
        let plot = AKNodeOutputPlot(self.microphone, frame: self.nodeOutputPlot.bounds)
        plot.plotType = .buffer
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        
        self.nodeOutputPlot.addSubview(plot)
        
        var listOfInputs = AVAudioSession.sharedInstance().availableInputs //get all avaialable Inputs

        print(listOfInputs)
        
        let availableInput: AVAudioSessionPortDescription = listOfInputs![0] as AVAudioSessionPortDescription //pick which one you want (change index)
        
        do {
            try AVAudioSession.sharedInstance().setPreferredInput(availableInput) //set the Preffered Input
            
            let recordingName: String = "recording_0.caf"
            let recordingUrl: URL = self.documentDirectory.appendingPathComponent(recordingName)
            
            self.recorder = try AVAudioRecorder(url: recordingUrl, settings: self.recordingSettings)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AudioKit.output = self.booster
        AudioKit.start()
    }
    
    @IBAction func onRecordButtonTap(_ sender: UIButton) {
        if self.isRecording == false {
            sender.setTitle("Stop record", for: .normal)
            sender.setTitleColor(UIColor.red, for: .normal)
            self.recorder?.record()
        }
        else {
            sender.setTitle("Start record", for: .normal)
            sender.setTitleColor(UIColor.blue, for: .normal)
            self.recorder?.stop()
        }
        
        self.isRecording = !self.isRecording
    }

    @IBAction func onLoopbackButtonTap(_ sender: UIButton) {
        if self.isLoopbacking == false {
            sender.setTitle("Stop loopback", for: .normal)
            sender.setTitleColor(UIColor.red, for: .normal)
            self.loopback()
        }
        else {
            sender.setTitle("Start loopback", for: .normal)
            sender.setTitleColor(UIColor.blue, for: .normal)
            self.player?.stop()
            self.recorder?.stop()
            self.recordingIndex = 1
            self.playingIndex = 0
        }
        
        self.isLoopbacking = !self.isLoopbacking
    }
    
    func loopback() {
        do {
            let recordingUrl: URL = self.documentDirectory.appendingPathComponent("recording_" + String(self.recordingIndex) + ".caf")
            let playingUrl: URL = self.documentDirectory.appendingPathComponent("recording_" + String(self.playingIndex) + ".caf")
            
            try self.recorder = AVAudioRecorder(url: recordingUrl, settings: self.recordingSettings)
            self.recorder?.record()
            
            print("Now recording \(recordingUrl.relativeString)")
            
            try self.player = AVAudioPlayer(contentsOf: playingUrl)
            self.player?.delegate = self
            self.player?.play()
                
            print("Now playing \(playingUrl.relativeString)")
            
            self.playingIndex += 1
            self.recordingIndex += 1
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player?.stop()
        self.recorder?.stop()
        
        print("delegate called")
        
        if self.isLoopbacking == true {
            self.loopback()
        }
    }
}

