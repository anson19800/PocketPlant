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
    func goToSharePlantPage()
}

class QRCodePlantDetailViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var plantImageView: UIImageView! {
        didSet {
            plantImageView.applyshadowWithCorner(
                containerView: imageContainer,
                cornerRadious: 0,
                opacity: 0.3)
        }
    }
    
    @IBOutlet weak var imageContainer: UIView!
    
    @IBOutlet weak var plantNameLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel! {
        didSet {
            categoryLabel.layer.cornerRadius = 10
            categoryLabel.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var descriptionLabel: PaddingLabel! {
        didSet {
            descriptionLabel.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var collectButton: UIButton! {
        didSet {
            collectButton.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.cornerRadius = 5
        }
    }
    
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
        if plant.category == "" {
            categoryLabel.text = "未分類"
        } else {
            categoryLabel.text = plant.category
        }
        descriptionLabel.text = plant.description
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
    
    @IBAction func collectAction(_ sender: UIButton) {
        
        let animationView = loadAnimation(
            name: "9131-loading",
            loopMode: .loop)
        
        animationView.play()
        self.view.isUserInteractionEnabled = false
        
        guard let plant = plant else { return }

        UserManager.shared.addSharePlant(plantID: plant.id) { [weak self] isSuccess in
            guard let self = self else { return }
            
            if isSuccess {
                animationView.stop()
                animationView.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
                
                self.dismiss(animated: true, completion: nil)
                
                if let delegate = self.delegate {
                    delegate.goToSharePlantPage()
                }

            } else {
                animationView.stop()
                animationView.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
            }
        }
        
    }
}
