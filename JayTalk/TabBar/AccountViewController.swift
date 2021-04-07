//
//  AccountViewController.swift
//  JayTalk
//
//  Created by Jkookoo on 2021/04/07.
//  Copyright © 2021 Jkookoo. All rights reserved.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController {
    // MARK: - Properties
    
    // MARK: - Methods
    
    // MARK: - IBOutlets
    
    // MARK: - IBActions
    @IBAction func touchLogOutButton(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        } catch(let e) {
            print(e.localizedDescription)
        }
        
    }
    
    // MARK: - Objcs
    
    // MARK: - Delegates And DataSources
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
