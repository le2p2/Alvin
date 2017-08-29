//
//  FileManager.swift
//  Alvin
//
//  Created by Thibaut WEISSGERBER on 24/08/2017.
//  Copyright © 2017 Gaetan GROMER. All rights reserved.
//

import Foundation
import AVFoundation
import Alamofire
import PKHUD

class FileManager
{
    static var shared: FileManager = FileManager()
    
    var defaultFileManager: Foundation.FileManager? = nil
    var documentsDirectory: URL? = nil
    var player: AVAudioPlayer? = nil
    
    private init() {
        self.defaultFileManager = Foundation.FileManager.default
        self.documentsDirectory = self.defaultFileManager?.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    public func deleteFile(name: String) {
        let fileUrl: URL? = self.documentsDirectory?.appendingPathComponent(name)
        
        do {
            try self.defaultFileManager?.removeItem(at: fileUrl!)
        }
        catch let error {
            log.error(error.localizedDescription)
        }
    }
    
    public func uploadFile(name: String) {
        let fileFolderName: String = name.substring(to: name.index(name.startIndex, offsetBy: 19)) // from 0 to index 18 == current datetime
        let fileUrl: URL = (self.documentsDirectory?.appendingPathComponent(name))!
        
        log.info("upload file with name \(name) at folder \(fileFolderName)")
        
        HUD.show(.progress)
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(fileUrl, withName: "file")
            },
            to: "http://167.114.231.178/Puzl/web/app.php/applications/Alvin/itineraries/\(fileFolderName)/sounds/new",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                    case .success(let upload, _, _):
                        upload.response { response in
                            HUD.flash(.success, delay: 1.0)
                        }
                    case .failure( _):
                        HUD.flash(.error, delay: 1.0)
                }
            }
        )
    }
    
    public func listFiles() -> Array<FileManagerTableViewCellModel> {
        do {
            let rawFiles = try Foundation.FileManager.default.contentsOfDirectory(at: self.documentsDirectory!, includingPropertiesForKeys: nil, options: [])
            let filteredFiles = rawFiles.filter { $0.pathExtension == Loopback.shared.fileExtension }
            var files: Array<FileManagerTableViewCellModel> = []
            
            for file in filteredFiles {
                files.append(FileManagerTableViewCellModel(name: file.lastPathComponent))
            }
            
            return files
        }
        catch let error as NSError {
            log.error(error.localizedDescription)
            
            return []
        }
    }
    
    public func playFile(name: String) {
        let fileUrl: URL? = self.documentsDirectory?.appendingPathComponent(name)
                
        do {
            self.player = try AVAudioPlayer(contentsOf: fileUrl!)
            self.player?.play()
        }
        catch let error {
            log.error(error.localizedDescription)
        }
    }
    
    public func stopFile() {
        self.player?.stop()
    }
}
