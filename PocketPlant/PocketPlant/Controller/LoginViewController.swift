//
//  LoginViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/11/3.
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    fileprivate var currentNonce: String?
    
    var appleLogInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .default,
                                                  authorizationButtonStyle: .black)
        button.cornerRadius = 3
        button.addTarget(self, action: #selector(handleLogInWithAppleID), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @IBOutlet weak var imageContainer: UIView!
    
    @IBOutlet weak var mainImageView: UIImageView! {
        didSet {
            mainImageView.applyshadowWithCorner(
                containerView: imageContainer,
                cornerRadious: 3,
                opacity: 0.15)
        }
    }
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainTitle: UILabel!
    
    @IBOutlet weak var subTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(appleLogInButton)
        setUpButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainImageView.alpha = 0
        imageContainer.alpha = 0
        mainTitle.alpha = 0
        subTitle.alpha = 0
        appleLogInButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        imageContainer.transform = CGAffineTransform(translationX: 0, y: 100)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1) {
                self.mainImageView.alpha = 1
                self.imageContainer.alpha = 1
                self.imageContainer.transform = CGAffineTransform(translationX: 0, y: 0)
                self.appleLogInButton.transform = CGAffineTransform.identity
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            UIView.animate(withDuration: 0.5) {
                self.mainTitle.alpha = 1
                self.subTitle.alpha = 1
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "Login", sender: nil)
        } else {
          print("No user signed in.")
        }
    }
    
    private func setUpButton() {
        let guide = view.safeAreaLayoutGuide
        appleLogInButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 50).isActive = true
        appleLogInButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -50).isActive = true
        appleLogInButton.topAnchor.constraint(equalTo: subTitle.bottomAnchor, constant: 40).isActive = true
        appleLogInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    @available(iOS 13, *)
    @objc func handleLogInWithAppleID() {
        
        let nonce = randomNonceString()
        
        currentNonce = nonce
        
        let provider = ASAuthorizationAppleIDProvider()
        
        let request = provider.createRequest()
        
        request.requestedScopes = [.email, .fullName]
        
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            if let giveName = appleIDCredential.fullName?.givenName {
                UserManager.shared.userName = "\(giveName)"
            }
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print("登入失敗")
                    print(error.localizedDescription)
                    return
                }
                UserManager.shared.createUserInfo()
                print("登入成功")
                self.performSegue(withIdentifier: "Login", sender: nil)
            }
//            Auth.auth().currentUser?.metadata.lastSignInDate
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
