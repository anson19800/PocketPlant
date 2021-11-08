//
//  ShowQRCodePageViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/29.
//

import UIKit

class ShowQRCodePageViewController: UIViewController {
    
    private var animator: UIViewPropertyAnimator!
    
    var plantID: String?

    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            backgroundView.layer.cornerRadius = 10
            backgroundView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var qrcodeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.transform = CGAffineTransform(translationX: 0, y: backgroundView.bounds.height)
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(panOnFloatingView(_:)))
        backgroundView.isUserInteractionEnabled = true
        backgroundView.addGestureRecognizer(pan)
        
        guard let plantID = plantID else { return }

        qrcodeImageView.generateQRCode(from: "\(plantID)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseOut]) {
            self.view.backgroundColor = UIColor(white: 0, alpha: 0.8)
            self.backgroundView.transform = .identity
        }
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func panOnFloatingView(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animator = UIViewPropertyAnimator(
                duration: 0.3,
                curve: .easeOut) {
                let translationY = self.backgroundView.bounds.height
                self.backgroundView.transform = CGAffineTransform(translationX: 0, y: translationY)
                self.view.backgroundColor = .clear
            }
        case .changed:
            let translation = recognizer.translation(in: backgroundView)
            let fractionComplete = translation.y / backgroundView.bounds.height
            animator.fractionComplete = fractionComplete
        case .ended:
            if animator.fractionComplete <= 0.4 {
                animator.isReversed = true
            } else {
                animator.addCompletion { (_) in
                    self.dismiss(animated: true, completion: nil)
                }
            }
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            break
        }
    }
    
}
