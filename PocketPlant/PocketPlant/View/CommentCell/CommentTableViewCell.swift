//
//  CommentTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/31.
//

import UIKit
import Kingfisher

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.layer.cornerRadius = userImageView.frame.width / 2
        }
    }
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentView.autoresizingMask = [.flexibleHeight]
    }

    func layoutCell(comment: Comment, user: User? = nil, isOwner: Bool) {
        
        commentLabel.text = comment.content
        
        let date = Date(timeIntervalSince1970: comment.createdTime)
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy.MM.dd HH:mm"
        let createdTime = dateFormater.string(from: date)
        timeLabel.text = createdTime
        guard let user = user else { return }
        if isOwner {
            userLabel.text = "草主-\(user.name ?? "匿名")"
        } else {
            userLabel.text = user.name
        }
        if let imageURL = user.userImageURL {
            userImageView.kf.setImage(with: URL(string: imageURL))
        } else {
            userImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
}
