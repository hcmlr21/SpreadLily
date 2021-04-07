//
//  SelectFrinedViewController.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/17.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import BEMCheckBox

class SelectFrinedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BEMCheckBoxDelegate {
    // MARK: - ProPerties
    var myUid: String?
    var friends: [UserModel] = []
    var selectedUsersUid: [String] = []
    let cellIdentifier: String = "friendCell"
    var pvc: PeopleViewController?
    
    // MARK: - Methods
    func getFriendList() {
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (dataSnapShot) in
            self.friends.removeAll()
            
            for userInfo in dataSnapShot.children.allObjects as! [DataSnapshot] {
                let userModel = UserModel()
                userModel.setValuesForKeys(userInfo.value as! [String : Any])
                
                if(userModel.uid != self.myUid) {
                    self.friends.append(userModel)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    @objc func createRoom() {
        self.dismiss(animated: false) {
            if(self.selectedUsersUid.count > 1) {
                let groupChatRoomVC = self.storyboard?.instantiateViewController(identifier: "groupChatRoomViewController") as! GroupChatRoomViewController
                groupChatRoomVC.destinationsUid = self.selectedUsersUid
                
                self.pvc?.navigationController?.pushViewController(groupChatRoomVC, animated: true)
            } else {
                let chatRoomVC = self.storyboard?.instantiateViewController(identifier: "chatRoomViewController") as! ChatRoomViewController
                chatRoomVC.destinationUid = self.selectedUsersUid[0]

                self.pvc?.navigationController?.pushViewController(chatRoomVC, animated: true)
            }
        }
    }
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createRoomButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? SelectFrinedTableCell else {
            return UITableViewCell()
        }
        
        let friendInfo = self.friends[indexPath.row]
        
        cell.userNameLabel.text = friendInfo.userName
        
        let imageUrl = URL(string: friendInfo.profileImageUrl!)
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
        cell.profileImageView.kf.setImage(with: imageUrl!)
        
        cell.checkBoxView.delegate = self
        cell.checkBoxView.tag = indexPath.row
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! SelectFrinedTableCell
        
//        cell.checkBoxView.setOn(!(cell.checkBoxView.on), animated: true)
//        cell.checkBoxView.reload()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        let selectedFriend = self.friends[checkBox.tag]
        if(checkBox.on) {
            selectedUsersUid.append(selectedFriend.uid!)
        } else {
            self.selectedUsersUid.removeLast()
        }
        
        if(self.selectedUsersUid.count < 1) {
            self.createRoomButton.isEnabled = false
        } else {
            self.createRoomButton.isEnabled = true
        }
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myUid = Auth.auth().currentUser?.uid
        
        self.getFriendList()
        
        self.createRoomButton.addTarget(self, action: #selector(self.createRoom), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
    }
}

class SelectFrinedTableCell: UITableViewCell {
    @IBOutlet weak var checkBoxView: BEMCheckBox!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
}

extension UINavigationController {
    func popViewController(animated: Bool, completion:@escaping (()->())) -> UIViewController? {
        CATransaction.setCompletionBlock(completion)
        CATransaction.begin()
        let poppedViewController = self.popViewController(animated: animated)
        CATransaction.commit()
        return poppedViewController
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool, completion:@escaping (()->())) {
        CATransaction.setCompletionBlock(completion)
        CATransaction.begin()
        self.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
}
