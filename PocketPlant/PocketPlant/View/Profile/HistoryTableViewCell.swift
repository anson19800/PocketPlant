//
//  HistoryTableViewCell.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/5.
//

import UIKit
import Lottie

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var historyLabel: UILabel!
    
    var animationView: AnimationView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        containerView.isUserInteractionEnabled = true
        
    }
    
    func layoutCell(animationView: AnimationView, historyTitle: String) {
        
        animationView.frame = containerView.bounds
        
        animationView.contentMode = .scaleAspectFill
        
        containerView.addSubview(animationView)
        
        animationView.play()
        
        historyLabel.text = historyTitle
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(playAnimation))
        
        animationView.addGestureRecognizer(tap)
        
        animationView.isUserInteractionEnabled = true
    }
    
    @objc func playAnimation() {
        if let animationView = animationView {
            if !animationView.isAnimationPlaying {
                animationView.play()
            } else {
                animationView.stop()
            }
        }
    }
    
}
