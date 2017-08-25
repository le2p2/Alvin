//
//  LoopbackViewController.swift
//  Alvin
//
//  Created by Thibaut WEISSGERBER on 25/08/2017.
//  Copyright © 2017 Gaetan GROMER. All rights reserved.
//

import Foundation
import AVFoundation
import SCSiriWaveformView

class LoopbackViewController: UIViewController, AVAudioPlayerDelegate
{
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var waveContainer: UIView!
    @IBOutlet weak var folderButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var loopbackButton: UIButton!
    
    var waveformView: SCSiriWaveformView? = nil
    var displayLink: CADisplayLink? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup waveform
        self.waveformView = SCSiriWaveformView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.waveContainer.bounds.height)) // Cheating by using superview width instead of parent view
        self.waveformView?.waveColor = UIColor.white
        self.waveformView?.primaryWaveLineWidth = 3.0
        self.waveformView?.secondaryWaveLineWidth = 1.0
        self.waveformView?.phaseShift = -0.3
        self.waveformView?.backgroundColor = UIColor.clear
        self.waveContainer.addSubview(waveformView!)
        
        // Setup refresh of waveform
        self.displayLink = CADisplayLink(target: self, selector: #selector(updateRecorderMeters))
        self.displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    @IBAction func onFolderButtonTouch(_ sender: Any) {
        print("folder touch")
    }
    
    @IBAction func onRecordButtonTouch(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        let isRecording: Bool = Loopback.shared.isRecording
        
        if isRecording == true {
            button.setImage(UIImage(named: "MicroOnIcon"), for: .normal)
            Loopback.shared.stopRecording()
        }
        else {
            button.setImage(UIImage(named: "MicroOffIcon"), for: .normal)
            Loopback.shared.startRecording()
        }
        
        Loopback.shared.isRecording = !isRecording
    }
    
    @IBAction func onLoopbackButtonTouch(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        let isLoopbacking: Bool = Loopback.shared.isLoopbacking
        
        if isLoopbacking == true {
            button.setImage(UIImage(named: "MicroOnIcon"), for: .normal)
            Loopback.shared.stopLoopback()
        }
        else {
            button.setImage(UIImage(named: "MicroOffIcon"), for: .normal)
            Loopback.shared.startLoopback()
        }
        
        Loopback.shared.isLoopbacking = !isLoopbacking
    }
    
    public func updateRecorderMeters() {
        Loopback.shared.updateMeters()
        
        self.waveformView?.update(withLevel: Loopback.shared.getAveragePower())
        
        if Loopback.shared.isRecording {
            let time: Double = Loopback.shared.recorder!.currentTime
            let minutes: Double = floor(time / 60)
            let seconds: Double = floor(time - (minutes * 60))
            let minutesString = String(format: "%02d", Int(minutes))
            let secondsString = String(format: "%02d", Int(seconds))
            
            self.timeLabel.text = "\(minutesString):\(secondsString)"
        }
        else {
            self.timeLabel.text = "00:00"
        }
    }
    
}
