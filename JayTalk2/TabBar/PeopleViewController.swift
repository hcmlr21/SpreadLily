//
//  PeopleViewController.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/13.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Firebase
import SnapKit
import Kingfisher

class PeopleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - ProPerties
    var myUid: String?
    let cellIdentifier: String = "userCell"
    var myInfo: [UserModel] = []
    var friendsInfo: [UserModel] = []
    
    // MARK: - Methods
    func addSelectFriendButton() {
        let selectFriendButton = UIButton()
        self.view.addSubview(selectFriendButton)
        selectFriendButton.snp.makeConstraints { (m) in
            m.bottom.equalTo(self.view).offset(-90)
            m.right.equalTo(self.view).offset(-20)
            m.width.height.equalTo(50)
        }
        selectFriendButton.backgroundColor = UIColor.black
        selectFriendButton.addTarget(self, action: #selector(self.showSelectFriendViewController), for: .touchUpInside)
        selectFriendButton.layer.cornerRadius = 25
        selectFriendButton.layer.masksToBounds = true
        

        let label = UILabel()
        label.text = "+"
        label.font = label.font.withSize(30)
        label.textColor = UIColor.white
        selectFriendButton.addSubview(label)
        label.snp.makeConstraints { (m) in
            m.centerX.equalTo(selectFriendButton)
            m.centerY.equalTo(selectFriendButton)
        }
    }
    
    @objc func showSelectFriendViewController() {
        let selectFrinedVC = self.storyboard?.instantiateViewController(identifier: "selectFrinedViewController") as! SelectFrinedViewController
        selectFrinedVC.pvc = self
        self.present(selectFrinedVC, animated: true, completion: nil)
    }
    
    func getUserList() {
        Database.database().reference().child("users").observe(.value, with: { (dataSnapShot) in
            self.myInfo.removeAll()
            self.friendsInfo.removeAll()
            
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                
                let userModel = UserModel()
                userModel.setValuesForKeys(item.value as! [String : Any])
                
                if userModel.uid == self.myUid {
                    self.myInfo.append(userModel)
                } else {
                    self.friendsInfo.append(userModel)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String = ""
        if(section == 0) {
            title = "내 프로필"
        } else if(section == 1) {
            title = "친구"
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return self.myInfo.count
        }else if(section == 1) {
            return self.friendsInfo.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? PeoPleTableViewCell else {
            return UITableViewCell()
        }
        
        var userInfo: UserModel = UserModel()
        if(indexPath.section == 0) {
            userInfo = self.myInfo[indexPath.row]
        } else  if(indexPath.section == 1) {
            userInfo = self.friendsInfo[indexPath.row]
        }
            
        
        let profileImageView = cell.profileImageView!
        let imageUrl = URL(string: userInfo.profileImageUrl!)
        profileImageView.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(cell).offset(10)
            m.height.width.equalTo(50)
        }
        profileImageView.kf.setImage(with: imageUrl!)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.clipsToBounds = true
        
        let nameLabel = cell.nameLabel!
        nameLabel.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(cell.profileImageView.snp.right).offset(20)
        }
        nameLabel.text = userInfo.userName
        
        if let conditionComment = userInfo.conditionComment {
            cell.conditionCommentLabel.isHidden = false
            cell.conditionCommentBackground.isHidden = false
            
            let conditionCommentLabel = cell.conditionCommentLabel!
            
            cell.conditionCommentBackground.snp.makeConstraints { (m) in
                m.height.equalTo(35)
                m.width.equalTo(15 * conditionComment.count)
                m.right.equalTo(cell).offset(-10)
                m.centerY.equalTo(cell)
            }
            
            conditionCommentLabel.snp.makeConstraints { (m) in
                m.centerX.equalTo(cell.conditionCommentBackground)
                m.centerY.equalTo(cell.conditionCommentBackground)
            }
            conditionCommentLabel.text = conditionComment
            
            cell.conditionCommentBackground.backgroundColor = UIColor.gray
        } else {
            cell.conditionCommentLabel.isHidden = true
            cell.conditionCommentBackground.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if(indexPath.section == 0){
            let alertController = UIAlertController(title: "내 프로필", message: nil, preferredStyle: .actionSheet)
            
            let conditionCommentAction = UIAlertAction(title: "상태메세지", style: .default) { (action) in
                let alertController = UIAlertController(title: "상태메세지", message: nil, preferredStyle: .alert)
                alertController.addTextField { (textField) in
                    textField.placeholder = "상태메세지"
                }

                let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                    if let textField = alertController.textFields?.first {
                        let dic = ["conditionComment": textField.text]
                        Database.database().reference().child("users").child(self.myUid!).updateChildValues(dic)
                    }
                }

                let cancelAction = UIAlertAction(title: "취소", style: .default) { (action) in
                }

                alertController.addAction(cancelAction)
                alertController.addAction(okAction)

                self.present(alertController, animated: true, completion: nil)
            }
            
            let profileImageAction = UIAlertAction(title: "프로필 사진", style: .default) { (action) in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alertController.addAction(conditionCommentAction)
            alertController.addAction(profileImageAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        } else if(indexPath.section == 1) {
            let viewIdentifier: String = "chatRoomViewController"
            let chatRoomVC = self.storyboard?.instantiateViewController(identifier: viewIdentifier) as! ChatRoomViewController
            chatRoomVC.destinationUid = friendsInfo[indexPath.row].uid
            
            self.navigationController?.pushViewController(chatRoomVC, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let profileImage = (info[.originalImage] as? UIImage)?.jpegData(compressionQuality: 0.1)
        
        let storageRef = Storage.storage().reference().child("userImage").child(myUid!)
//        storageRef.delete { (error) in
//            if(error == nil) {
//
//            }
//        }
        storageRef.putData(profileImage!, metadata: nil) { (data, error) in
            storageRef.downloadURL { (url, error) in
                let value = ["profileImageUrl":url?.absoluteString]
                Database.database().reference().child("users").child(self.myUid!).updateChildValues(value) { (error, ref) in
                    if(error == nil) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myUid = Auth.auth().currentUser?.uid
        
        self.getUserList()
     
        self.addSelectFriendButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.tableView.reloadData()
    }
}

class PeoPleTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var conditionCommentBackground: UIView!
    @IBOutlet weak var conditionCommentLabel: UILabel!
}
