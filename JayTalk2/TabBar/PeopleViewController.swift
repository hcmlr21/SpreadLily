//
//  PeopleViewController.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/13.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class PeopleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - ProPerties
    var myUid: String?
    let cellIdentifier: String = "userCell"
    var myInfo: [UserModel] = []
    var friendsInfo: [UserModel] = []
    
    // MARK: - Methods
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0) {
            return "나"
        } else if(section == 1) {
            return "친구"
        }
        return ""
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
        let imageUrl = URL(string: userInfo.profileUrl!)
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
        
        let conditionCommentLabel = cell.conditionCommentLabel!
        conditionCommentLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(cell.conditionCommentBackground)
            m.centerY.equalTo(cell.conditionCommentBackground)
        }
        
        if let conditionComment = userInfo.conditionComment {
            conditionCommentLabel.text = conditionComment
        }
        
        cell.conditionCommentBackground.snp.makeConstraints { (m) in
            m.right.equalTo(cell).offset(-10)
            m.centerY.equalTo(cell)
            
            if let count = conditionCommentLabel.text?.count {
                m.width.equalTo(10 * count)
            } else{
                m.width.equalTo(0)
            }
            m.height.equalTo(35)
        }
        cell.conditionCommentBackground.backgroundColor = UIColor.gray
        
        return cell
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myUid = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("users").observe(.value, with: { (dataSnapShot) in
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
}

class PeoPleTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var conditionCommentBackground: UIView!
    @IBOutlet weak var conditionCommentLabel: UILabel!
}
