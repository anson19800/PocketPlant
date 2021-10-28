//
//  SharePlantDetailViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/28.
//

import UIKit
import Kingfisher

protocol SharePlantDetailDelegate: AnyObject {
    func cancelAction()
}

class SharePlantDetailViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var plantImageView: UIImageView! {
        didSet {
            plantImageView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var plantNameLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    var plant: Plant?
    
    private var animator: UIViewPropertyAnimator!
    
    weak var delegate: SharePlantDetailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.transform = CGAffineTransform(translationX: 0, y: backgroundView.bounds.height)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panOnFloatingView(_:)))
        backgroundView.isUserInteractionEnabled = true
        backgroundView.addGestureRecognizer(pan)
        
        guard let plant = plant,
              let imageURL = plant.imageURL else { return }
        
        plantImageView.kf.setImage(with: URL(string: imageURL))
        plantNameLabel.text = plant.name
        categoryLabel.text = plant.category
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3,
                                                       delay: 0,
                                                       options: [.curveEaseOut]) {
            self.view.backgroundColor = UIColor(white: 0, alpha: 0.8)
            self.backgroundView.transform = .identity
        }
    }
    
    @objc private func panOnFloatingView(_ recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            animator = UIViewPropertyAnimator(duration: 0.3,
                                              curve: .easeOut,
                                              animations: {
                let translationY = self.backgroundView.bounds.height
                self.backgroundView.transform = CGAffineTransform(translationX: 0, y: translationY)
                self.view.backgroundColor = .clear
            })
        case .changed:
            let translation = recognizer.translation(in: backgroundView)
            let fractionComplete = translation.y / backgroundView.bounds.height
            animator.fractionComplete = fractionComplete
        case .ended:
            if animator.fractionComplete <= 0.4 {
                animator.isReversed = true
            } else {
                animator.addCompletion { _ in
                    self.dismiss(animated: true, completion: nil)
                    guard let delegate = self.delegate else { return }
                    delegate.cancelAction()
                }
            }
            animator.continueAnimation(withTimingParameters: nil,
                                       durationFactor: 0)
        default:
            break
        }
    }
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        guard let delegate = self.delegate else { return }
        delegate.cancelAction()
    }
}
