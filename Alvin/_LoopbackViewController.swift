//
//  ViewController.swift
//  Alvin
//
//  Created by Thibaut WEISSGERBER on 23/08/2017.
//  Copyright © 2017 Gaetan GROMER. All rights reserved.
//

import UIKit
import AVFoundation
import SCSiriWaveformView

class LoopbackViewController: UIViewController, AVAudioPlayerDelegate
{
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
    var displayLink: CADisplayLink? = nil
    var waveformView: SCSiriWaveformView? = nil
    
    @IBOutlet weak var waveContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bounds = self.waveContainer.bounds
        self.waveformView = SCSiriWaveformView(frame: CGRect.init(x: 0, y: 0, width: bounds.width, height: bounds.height))
        self.waveformView?.waveColor = UIColor.white
        self.waveformView?.primaryWaveLineWidth = 3.0
        self.waveformView?.secondaryWaveLineWidth = 1.0
        self.waveformView?.phaseShift = -0.3
        self.waveformView?.backgroundColor = UIColor.clear
        self.waveContainer.addSubview(waveformView!)
        
        let listOfInputs = AVAudioSession.sharedInstance().availableInputs //get all avaialable Inputs
        let availableInput: AVAudioSessionPortDescription = listOfInputs![0] as AVAudioSessionPortDescription //pick which one you want (change index)
        
        do {
            try AVAudioSession.sharedInstance().setPreferredInput(availableInput) //set the Prefered Input
            
            let recordingName: String = "recording_0.caf"
            let recordingUrl: URL = self.documentDirectory.appendingPathComponent(recordingName)
            
            self.recorder = try AVAudioRecorder(url: recordingUrl, settings: self.recordingSettings)
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(updateMeters))
        displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
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
    
    @IBAction func onRecordButtonClick(_ sender: UIButton) {
        if self.isRecording == false {
            self.recorder?.isMeteringEnabled = true
            self.recorder?.record()
        }
        else {
            self.recorder?.stop()
        }
        
        self.isRecording = !self.isRecording
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player?.stop()
        self.recorder?.stop()
        
        print(" ")
        
        if self.isLoopbacking == true {
            self.loopback()
        }
    }
    
    func updateMeters() {
        self.recorder?.updateMeters()
        
        let normalizedValue:CGFloat = pow(10, CGFloat(recorder!.averagePower(forChannel: 0))/20)
        
        self.waveformView?.update(withLevel: normalizedValue)
    }
}

