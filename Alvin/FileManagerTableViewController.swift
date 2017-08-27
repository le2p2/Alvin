//
//  FileManagerTableViewController.swift
//  Alvin
//
//  Created by Thibaut WEISSGERBER on 24/08/2017.
//  Copyright © 2017 Gaetan GROMER. All rights reserved.
//

import UIKit

class FileManagerTableViewController: UITableViewController
{
    var files: Array<FileManagerTableViewCellModel> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.files = FileManager.shared.listFiles()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        FileManager.shared.stopFile()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "FileManagerTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FileManagerTableViewCell  else {
            fatalError("The dequeued cell is not an instance of FileManagerTableViewCell.")
        }
        
        // Fetches the appropriate file for the data source layout.
        let file = self.files[indexPath.row]
        
        cell.backgroundColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        cell.selectionStyle = .none
        cell.label.textColor = UIColor.white
        cell.label.text = file.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // Return false if you do not want the specified item to be editable.
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let uploadRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Upload", handler: { action, indexpath in
            FileManager.shared.uploadFile(name: self.files[indexPath.row].name)
            
            self.tableView.isEditing = false
        });
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete", handler: { action, indexpath in
            FileManager.shared.deleteFile(name: self.files[indexPath.row].name)
            
            self.files = FileManager.shared.listFiles()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.isEditing = false
        });
        
        return [deleteRowAction, uploadRowAction];
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileName: String = self.files[indexPath.row].name
        let currentCell = tableView.cellForRow(at: indexPath) as! FileManagerTableViewCell
        let visibleCells = tableView.visibleCells as! Array<FileManagerTableViewCell>
        
        // Reset all cells
        for cell in visibleCells {
            if cell == currentCell {
                if cell.isPlaying == true {
                    cell.playButton.setImage(UIImage(named: "PlayIcon"), for: .normal)
                    FileManager.shared.stopFile()
                }
                else {
                    cell.playButton.setImage(UIImage(named: "PauseIcon"), for: .normal)
                    FileManager.shared.playFile(name: fileName)
                }
        
                cell.isPlaying = !cell.isPlaying
            }
            else {
                cell.playButton.setImage(UIImage(named: "PlayIcon"), for: .normal)
                cell.isPlaying = false
            }
        }
    }

    @IBAction func onCloseButtonTouch(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
