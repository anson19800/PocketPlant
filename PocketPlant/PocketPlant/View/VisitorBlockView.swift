//
//  VisitorBlockView.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/20.
//

import UIKit

protocol VisitorBlockViewDelegate: AnyObject {
    
    func loginAction()
    
}

class VisitorBlockView: UIView {
    
    weak var delegate: VisitorBlockViewDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.clipsToBounds = true
        
        setupVisitorBlockView()
        
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func setupVisitorBlockView() {
        
        let backgroundView = UIView()
        
        backgroundView.backgroundColor = .DarkGreen
        
        self.addSubview(backgroundView)
        
        backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -15).isActive = true
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.layer.cornerRadius = 10
        backgroundView.clipsToBounds = true
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        setUpLoginButton()
        setUpTitleLabel()
    }
    
    func setUpLoginButton() {
        
        let loginButton = UIButton()
        
        self.addSubview(loginButton)
        
        loginButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 20).isActive = true
        
        loginButton.setTitle("去登入", for: .normal)
        loginButton.backgroundColor = .white
        loginButton.setTitleColor(.DarkBlue, for: .normal)
        loginButton.setTitleColor(.black, for: .highlighted)
        loginButton.layer.cornerRadius = 10
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.isUserInteractionEnabled = true
        loginButton.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
    }
    
    func setUpTitleLabel() {
        
        let titleLabel = UILabel()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(titleLabel)
        
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -50).isActive = true
        
        let attributedString = NSMutableAttributedString(
            string: "目前為訪客狀態\n可以點擊底下瀏覽探索頁面\n或登入使用完整功能！")

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineSpacing = 3

        attributedString.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: paragraphStyle,
            range: NSMakeRange(0, attributedString.length))

        titleLabel.attributedText = attributedString
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
    }
    
    @objc func loginButtonAction() {
        
        guard let delegate = delegate else { return }

        delegate.loginAction()
    }
}
