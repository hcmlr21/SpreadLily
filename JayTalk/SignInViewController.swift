//
//  SignInViewController.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/11.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class SignInViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - ProPerties
    
    // MARK: - Methods
    @objc func tapView() {
        self.view.endEditing(true)
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - IBActions
    @objc func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func signIn() {
        if let name = self.nameTextField.text, let email = self.emailTextField.text, let password = self.passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if(error == nil) {
                    let myUid = user?.user.uid
                    let image = self.profileImageView.image?.jpegData(compressionQuality: 0.1)
                    let storageRef = Storage.storage().reference().child("userImage").child(myUid!)
                    storageRef.putData(image!, metadata: nil) { (data, error) in
                        storageRef.downloadURL { (url, error) in
                            let value = [
                                "userName":name,
                                "profileImageUrl":url?.absoluteString,
                                "uid":myUid!,
                                "accountType": "user"
                            ]
                            Database.database().reference().child("users").child(myUid!).setValue(value) { (error, ref) in
                                if(error == nil) {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                } else {
                    self.alert(message: "회원가입 오류")
                }
            }
        }
    }
    
    @objc func pressCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func alert(message: String) {
        let alertController = UIAlertController(title: "로그인 실패", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    // MARK: - Delegates And DataSource
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.profileImageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.tapView))
        self.view.addGestureRecognizer(tapView)
        
        let imagePick = UITapGestureRecognizer(target: self, action: #selector(self.pickImage))
        self.profileImageView.addGestureRecognizer(imagePick)
        self.profileImageView.isUserInteractionEnabled = true
        
        self.signInButton.addTarget(self, action: #selector(self.signIn), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(self.pressCancel), for: .touchUpInside)
    }
}
