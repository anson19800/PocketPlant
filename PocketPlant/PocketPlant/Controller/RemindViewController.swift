//
//  RemindViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/26.
//

import UIKit

protocol RemindDelegate: AnyObject {
    func updateRemind(plant: Plant)
}

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
    
    var plant: Plant?
    
    weak var delegate: RemindDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
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
        
        guard var plant = plant else { return }
        
        var dict: [ReminderType: (Int, Date?)] = [:]
        
        var reminds: [Remind] = []
        
        for index in 0..<ReminderType.allCases.count {
            
            guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)),
                  let remindCell = cell as? ReminderTableViewCell else { return }
            
            if remindCell.dayTextField.text != "0" {
                
                guard let timesString = remindCell.dayTextField.text,
                      timesString != "",
                      let times = Int(timesString)
                else {
                    dict[ReminderType.allCases[index]] = (0, nil)
                    continue
                }
                
                let time = remindCell.timePicker.date
                let timeDate = time.timeIntervalSince1970
                dict[ReminderType.allCases[index]] = (times, time)
                
                let remind = Remind(plantID: plant.id,
                                    type: ReminderType.allCases[index].rawValue,
                                    times: times,
                                    time: timeDate)
                
                reminds.append(remind)
                
            } else {
                
                dict[ReminderType.allCases[index]] = (0, nil)
                
            }
        }
        RemindManager.shared.setRemind(plant, remindDict: dict)
       
        plant.reminder = reminds
        
        FirebaseManager.shared.updatePlant(plant: plant) { result in
            
            switch result {
                
            case .success(_):
                
                UIView.animate(withDuration: 0.3) {
                    
                    if let delegate = self.delegate {
                        delegate.updateRemind(plant: plant)
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension RemindViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReminderType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReminderTableViewCell.self),
                                                 for: indexPath)
        
        guard let reminderCell = cell as? ReminderTableViewCell,
              let plant = plant else { return cell }
    
        reminderCell.layoutCell(type: ReminderType.allCases[indexPath.row], reminds: plant.reminder)
        
        return reminderCell
    }
}
