//
//  RemindViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/26.
//

import UIKit

class RemindViewController: UIViewController {

    @IBOutlet weak var floatingView: UIView! {
        didSet {
            floatingView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            floatingView.layer.cornerRadius = 10
            floatingView.layer.masksToBounds = true
        }
    }
    
    private var animator: UIViewPropertyAnimator!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerCellWithNib(identifier: String(describing: ReminderTableViewCell.self),
                                          bundle: nil)
        }
    }
    @IBOutlet weak var indicatorView: UIView! {
        didSet {
            indicatorView.layer.cornerRadius = indicatorView.bounds.height / 2
            indicatorView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        floatingView.transform = CGAffineTransform(translationX: 0, y: floatingView.bounds.height)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panOnFloatingView(_:)))
        floatingView.isUserInteractionEnabled = true
        floatingView.addGestureRecognizer(pan)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3,
                                                       delay: 0,
                                                       options: [.curveEaseOut]) {
            self.view.backgroundColor = UIColor(white: 0, alpha: 0.8)
            self.floatingView.transform = .identity
        }
    }

    @objc private func panOnFloatingView(_ recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .began:
            animator = UIViewPropertyAnimator(duration: 0.3,
                                              curve: .easeOut,
                                              animations: {
                let translationY = self.floatingView.bounds.height
                self.floatingView.transform = CGAffineTransform(translationX: 0, y: translationY)
                self.view.backgroundColor = .clear
            })
        case .changed:
            let translation = recognizer.translation(in: floatingView)
            let fractionComplete = translation.y / floatingView.bounds.height
            animator.fractionComplete = fractionComplete
        case .ended:
            if animator.fractionComplete <= 0.4 {
                animator.isReversed = true
            } else {
                animator.addCompletion { _ in
                    self.dismiss(animated: true, completion: nil)
                }
            }
            animator.continueAnimation(withTimingParameters: nil,
                                       durationFactor: 0)
        default:
            break
        }
        
    }
    @IBAction func setReminder(_ sender: UIButton) {
        
        var dict: [ReminderType: Int] = [:]
        
        for index in 0..<ReminderType.allCases.count {
            
            guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)),
                  let remindCell = cell as? ReminderTableViewCell else { return }
            
            if remindCell.imageIsSelectes {
                
                guard let timesString = remindCell.dayTextField.text,
                      timesString != "",
                      let times = Int(timesString)
                else {
                    dict[ReminderType.allCases[index]] = 0
                    continue
                }
                
                dict[ReminderType.allCases[index]] = times
            
            } else {
                
                dict[ReminderType.allCases[index]] = 0
                
            }
        }
        print(dict)
    }
    
}

extension RemindViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReminderType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReminderTableViewCell.self),
                                                 for: indexPath)
        
        guard let reminderCell = cell as? ReminderTableViewCell else { return cell }
        
        reminderCell.layoutCell(type: ReminderType.allCases[indexPath.row])
        
        return reminderCell
        
    }
    
}
