//
//  FileManagerTableViewCell.swift
//  Alvin
//
//  Created by Thibaut WEISSGERBER on 24/08/2017.
//  Copyright © 2017 Gaetan GROMER. All rights reserved.
//

import Foundation
import UIKit

class FileManagerTableViewCell: UITableViewCell
{
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var isPlaying: Bool = false
}
