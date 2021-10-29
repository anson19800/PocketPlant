//
//  LottieWrapper.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/29.
//

import UIKit
import Lottie

extension UIViewController {
    
    func loadAnimation(name: String, loopMode: LottieLoopMode) -> AnimationView {
        let animationView = AnimationView(name: name)
        let width = self.view.frame.width
        animationView.frame = CGRect(x: 0, y: 0, width: width, height: 400)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        view.addSubview(animationView)
        animationView.loopMode = loopMode
        
        return animationView
    }
}
