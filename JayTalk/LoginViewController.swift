//
//  LoginViewController.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/11.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    // MARK: - ProPerties
    
    // MARK: - Methods
    @objc func loginEvent() {
        if let email = self.emailTextField.text, let password = self.passwordTextField.text {
            Auth.auth().signIn(withEmail: email , password: password) { (user, error) in
                if(error != nil) {
                    self.alert(message: error.debugDescription)
                }
            }
        } else {
            self.alert(message: "회원정보 오류")
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
        
        try! Auth.auth().signOut()
        
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
        
        self.emailTextField.text = "jay@naver.com"
        self.passwordTextField.text = "123456"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewDidLoad()
    }
}
