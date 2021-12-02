//
//  AddToolStockViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/11.
//

import UIKit

class AddToolStockViewController: UIViewController {

    @IBOutlet weak var indicatorView: UIView! {
        didSet {
            indicatorView.layer.cornerRadius = indicatorView.bounds.height / 2
            indicatorView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var floatingView: UIView! {
        didSet {
            floatingView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            floatingView.layer.cornerRadius = 10
            floatingView.layer.masksToBounds = true
        }
    }
    
    private var animator: UIViewPropertyAnimator!
    
    weak var parentVC: UIViewController?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var buyPlaceTextField: UITextField!
    @IBOutlet weak var stockTextField: UITextField!
    
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var stock: Int = 0 {
        didSet {
            stockTextField.text = String(stock)
        }
    }
    
    var tool: Tool?
    
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
        
        if let tool = tool {
            nameTextField.text = tool.name
            buyPlaceTextField.text = tool.buyPlace
            stock = tool.stock
            
            titleLabel.text = "編輯"
            addButton.setTitle("送出編輯", for: .normal)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        
        if touch?.view != floatingView {
            self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func stockChange(_ sender: UITextField) {
        if let stockText = sender.text,
           let stock = Int(stockText) {
            self.stock = stock
        } else {
            self.stock = 0
        }
    }
    
    @IBAction func minusButton(_ sender: Any) {
        if stock > 0 {
            stock -= 1
        }
    }
    
    @IBAction func plusButton(_ sender: Any) {
        stock += 1
    }
    
    @IBAction func addToolAction(_ sender: UIButton) {
        guard let name = nameTextField.text,
              let buyPlace = buyPlaceTextField.text else { return }
        
        if name == "" {
            nameTextField.shake(count: 3, for: 0.3, withTranslation: 1)
            
            nameTextField.attributedPlaceholder = NSAttributedString(
                string: "請輸入工具材料名字",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
            )
            
            return
        }
        
        if let tool = tool {
            let newTool = Tool(id: tool.id, name: name, stock: stock, buyPlace: buyPlace)
            uploadTool(tool: newTool)
            
        } else {
            let newTool = Tool(name: name, stock: stock, buyPlace: buyPlace)
            uploadTool(tool: newTool)
        }
    }
    
    func uploadTool(tool: Tool) {
        
        let animationView = loadAnimation(name: "9131-loading", loopMode: .loop)
        
        animationView.play()
        
        FirebaseManager.shared.uploadTool(tool: tool) { [weak self] isSuccess in
            guard let self = self else { return }
            
            if isSuccess {
                animationView.stop()
                
                if let parentVC = parentVC,
                   let toolListPage = parentVC as? ToolStockViewController {
                    toolListPage.reloadData()
                }
                dismiss(animated: true)
            }
        }
    }
}
