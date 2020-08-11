//
//  SignInViewController.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/11.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    // MARK: - ProPerties
    
    // MARK: - Methods
    @objc func tapView() {
        self.view.endEditing(true)
    }
    
    // MARK: - IBOutlets
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.tapView))
        self.view.addGestureRecognizer(tapView)
    }
}
