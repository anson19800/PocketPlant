//
//  CommentTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/31.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func layoutCell(comment: Comment) {
        
        commentLabel.text = comment.content
        
        let date = Date(timeIntervalSince1970: comment.createdTime)
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy.MM.dd HH:mm"
        let createdTime = dateFormater.string(from: date)
        timeLabel.text = createdTime
        
    }
    
}
