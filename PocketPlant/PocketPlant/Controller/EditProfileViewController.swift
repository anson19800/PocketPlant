//
//  EditProfileViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/9.
//

import UIKit
import PhotosUI

enum EditStep {
    case nameStep
    case photoStep
}

class EditProfileViewController: UIViewController {

    @IBOutlet weak var animationContainer: UIView! {
        didSet {
            animationContainer.layer.cornerRadius = 10
            animationContainer.clipsToBounds = true
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var notificationLabel: UILabel!
    
    @IBOutlet weak var nameInputTextField: UITextField! {
        didSet {
            nameInputTextField.layer.borderColor = UIColor.white.cgColor
        }
    }
    @IBOutlet weak var skipButton: UIButton! {
        didSet {
            skipButton.layer.cornerRadius = 3
        }
    }
    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.layer.cornerRadius = 3
        }
    }
    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    var editStepNow: EditStep = .nameStep
    
    var name: String?
    
    var imageURL: String?
    
    var imageID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "我叫做"
        let animationView = generateAnimationView(name: "9624-plantPeople", loopMode: .loop)
        animationView.frame = animationContainer.bounds
        animationContainer.addSubview(animationView)
        if #available(iOS 14, *) {
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectUserPhoto))
            animationContainer.addGestureRecognizer(tap)
        }
        animationContainer.isUserInteractionEnabled = false
        animationView.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        editStepNow = .nameStep
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func determineAction(_ sender: UIButton) {
        
        switch editStepNow {
        case .nameStep:
            
            if let name = nameInputTextField.text,
               name != "",
               name.count <= 8 {
                
                self.name = name
                
                nextAnimation()
                
                editStepNow = .photoStep
                
            } else {
                
                nameInputTextField.shake(count: 3, for: 0.3, withTranslation: 1)
                
                nameInputTextField.attributedPlaceholder = NSAttributedString(
                    string: "輸入您的名字，最多8個字",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
                )
                
            }
            
        case .photoStep:
            
            if let userPhoto = userPhotoImageView.image {
                
                ImageManager.shared.uploadImageToGetURL(image: userPhoto) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                        
                    case .success((let uuid, let url)):
                        
                        UserManager.shared.updateUserInfo(userName: self.name ?? "使用者",
                                                          userImageID: uuid,
                                                          userImageURL: url) { [weak self] isSuccess in
                            guard let self = self else { return }
                            
                            if !isSuccess {
                                self.showAlert(title: "Oops", message: "建立的過程好像出了問題請重新試過", buttonTitle: "好的")
                                return
                            }
                        }
                        
                    case .failure(let error):
                        
                        self.showAlert(title: "Oops", message: "網路好像出了問題請重新試過", buttonTitle: "好的")
                        
                        print(error)
                        
                        return
                    }
                }
            } else {
                
                UserManager.shared.updateUserInfo(userName: self.name ?? "使用者",
                                                  userImageID: nil,
                                                  userImageURL: nil) { isSuccess in
                    
                    if !isSuccess {
                        self.showAlert(title: "Oops", message: "建立的過程好像出了問題請重新試過", buttonTitle: "好的")
                        return
                    }
                }
            }
            
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            
            let homeVC = storyBoard.instantiateViewController(
                withIdentifier: "HomePage")
            
            homeVC.modalPresentationStyle = .fullScreen
            
            self.present(homeVC, animated: true, completion: nil)
        }
    }
    
    func nextAnimation() {
        
        nameInputTextField.endEditing(true)
        
        let animationViewTranslateX = view.center.x - animationContainer.center.x
        let animationViewTranslateY = view.center.y - animationContainer.center.y
        
        let titleTranslateX = animationViewTranslateX
        let titleTranslateY = animationViewTranslateY
        - animationContainer.frame.height
        - titleLabel.frame.height
        
        titleLabel.alpha = 0
        
        UIView.animate(withDuration: 1) {
            self.notificationLabel.alpha = 0
            self.nameInputTextField.alpha = 0
            self.nameInputTextField.isEnabled = false
            self.animationContainer.transform = CGAffineTransform(
                translationX: animationViewTranslateX,
                y: animationViewTranslateY)
            self.titleLabel.transform = CGAffineTransform(
                translationX: titleTranslateX,
                y: titleTranslateY - 50)
            if let name = self.name {
                self.titleLabel.text = "嗨！\(name)\n換張照片吧"
            } else {
                self.titleLabel.text = "嗨！換張照片吧"
            }
            self.titleLabel.alpha = 1
            self.sendButton.transform = CGAffineTransform(translationX: 0, y: 20)
            self.skipButton.alpha = 1
            self.skipButton.transform = CGAffineTransform(translationX: 0, y: 20)
            self.skipButton.isEnabled = true
            self.animationContainer.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func skipAction(_ sender: UIButton) {
        
        if editStepNow == .photoStep {
            
        }
    }
    
    @available(iOS 14, *)
    @objc func selectUserPhoto() {
        let controller = UIAlertController(title: nil,
                                           message: nil,
                                           preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "從相簿選擇",
                                        style: .default) { _ in
            
            var configuration = PHPickerConfiguration()
            
            configuration.filter = .images
            
            let picker = PHPickerViewController(configuration: configuration)
            
            picker.delegate = self
            
            self.present(picker, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "開啟相機拍照",
                                         style: .default) { _ in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.allowsEditing = true
                
                imagePicker.sourceType = .camera
                
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消",
                                         style: .cancel,
                                         handler: nil)
        
        controller.addAction(photoAction)
        controller.addAction(cameraAction)
        controller.addAction(cancelAction)
        
        present(controller, animated: true, completion: nil)
    }
}

@available(iOS 14, *)
extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        let itemProviders = results.map(\.itemProvider)
        
        if let itemProvider = itemProviders.first,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                
                DispatchQueue.main.async {
                    
                    guard let self = self,
                          let image = image as? UIImage else { return }
                    
                    self.userPhotoImageView.image = image
                    self.animationContainer.bringSubviewToFront(self.userPhotoImageView)

                }
            }
        }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            self.userPhotoImageView.image = image
            self.animationContainer.bringSubviewToFront(self.userPhotoImageView)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
}
