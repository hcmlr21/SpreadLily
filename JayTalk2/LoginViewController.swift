//
//  LoginViewController.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/11.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    // MARK: - ProPerties
    
    // MARK: - Methods
    @objc func loginEvent() {
        if let email = self.emailTextField.text, let password = self.passwordTextField.text {
            Auth.auth().signIn(withEmail: email , password: password) { (user, error) in
                self.alert(message: error.debugDescription)
            }
        }
    }
    
    @objc func presentSignIn() {
        let signInVC = self.storyboard?.instantiateViewController(identifier: "signInViewController") as! SignInViewController
        signInVC.modalPresentationStyle = .fullScreen
        present(signInVC, animated: true, completion: nil)
    }

    @objc func tapView() {
        self.view.endEditing(true)
    }
    
    func alert(message: String) {
        let alertController = UIAlertController(title: "로그인 실패", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.addTarget(self, action: #selector(self.loginEvent), for: .touchUpInside)
        self.signInButton.addTarget(self, action: #selector(self.presentSignIn), for: .touchUpInside)
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.tapView))
        self.view.addGestureRecognizer(tapView)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user != nil) {
                let mainVC = self.storyboard?.instantiateViewController(identifier: "mainViewTabBarController") as! UITabBarController
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: false, completion: nil)
            }
        }
    }
}
