//
//  FileManager.swift
//  Alvin
//
//  Created by Thibaut WEISSGERBER on 24/08/2017.
//  Copyright © 2017 Gaetan GROMER. All rights reserved.
//

import Foundation

class FileManager
{
    static var shared: FileManager = FileManager()
    
    var defaultFileManager: Foundation.FileManager? = nil
    var documentsDirectory: URL? = nil
    
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
        log.info("uploadFile \(name)")
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
}
