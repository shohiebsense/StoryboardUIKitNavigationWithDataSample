//
//  TaskCell.swift
//  To-Do2
//
//  Created by User on 2024/05/12.
//

import UIKit

class TaskCell: UITableViewCell {
    
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.starImage.image = UIImage(systemName: "star.fill")
    }
    
    
    
}
