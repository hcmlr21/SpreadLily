//
//  ChatRoomsViewController.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/14.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ChatRoomsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    // MARK: - ProPerties
    let cellIdentifier: String = "chatRoomCell"
    var myUid: String?
    var chatRoomUid: [String] = []
    var destinationsUids: [[String]] = []
    var destinationsUsersModel: [[UserModel]] = []
    var chatRooms: [ChatModel] = []
    
    // MARK: - Methods
    func getChatRoomsList() {
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "users/" + self.myUid!).queryEqual(toValue: true).observeSingleEvent(of: .value, with: { (dataSnapShot) in
            self.chatRooms.removeAll()
            self.chatRoomUid.removeAll()
            
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                if let chatRoomDic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomDic)
                    self.chatRoomUid.append(item.key)
                    self.chatRooms.append(chatModel!)
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? ChatRoomTableCell else {
            return UITableViewCell()
        }
        
        var usersUid: [String] = []

        for user in self.chatRooms[indexPath.row].users {
            if user.key != self.myUid {
                usersUid.append(user.key)
            }
        }

        usersUid = usersUid.sorted(by: {$0 > $1})
        self.destinationsUids.append(usersUid)
        
        var usersModel: [UserModel] = []
        for destinationUid in usersUid {
            
            Database.database().reference().child("users").child(destinationUid).observeSingleEvent(of: .value, with: { (dataSnapShot) in
                let userModel = UserModel()
                userModel.setValuesForKeys(dataSnapShot.value as! [String : AnyObject])
                usersModel.append(userModel)
                
                if(usersModel.count > 1) {
                    for (index, userModel) in usersModel.enumerated() {
                        if(index == 0) {
                            cell.titleLabel.text = userModel.userName
                            continue
                        } else if(index > 2) {
                            break
                        }
                        
                        cell.titleLabel.text! += ", " + userModel.userName!
                    }
                    
                    cell.usersCountLabel.isHidden = false
                    cell.usersCountLabel.text = String(usersModel.count + 1)
                    
                    //profile image 추가 필요
                } else {
                    cell.titleLabel.text = userModel.userName
                    
                    let imageUrl = URL(string: userModel.profileImageUrl!)
                    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
                    cell.profileImageView.clipsToBounds = true
                    cell.profileImageView.kf.setImage(with: imageUrl!)
                    
                    cell.usersCountLabel.isHidden = true
                }
                
                if(self.chatRooms[indexPath.row].comments.keys.count == 0) {
                    cell.lastMessageLabel.text = ""
                    cell.timeStampLabel.text = ""
                } else {
                    let lastMessageKey = self.chatRooms[indexPath.row].comments.keys.sorted() {$0 > $1}
                    let lastMessageInfo = self.chatRooms[indexPath.row].comments[lastMessageKey[0]]
                    cell.lastMessageLabel.text = lastMessageInfo?.message
                    cell.timeStampLabel.text = lastMessageInfo?.timeStamp?.todayTime
                }
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let usersCount = self.chatRooms[indexPath.row].users.count
        if(usersCount > 2) {
            let groupChatRoomVC = self.storyboard?.instantiateViewController(identifier: "groupChatRoomViewController") as! GroupChatRoomViewController
            groupChatRoomVC.destinationsUid = self.destinationsUids[indexPath.row]
            groupChatRoomVC.chatRoomUid = self.chatRoomUid[indexPath.row]
            
            self.navigationController?.pushViewController(groupChatRoomVC, animated: true)
        } else {
            let chatRoomVC = self.storyboard?.instantiateViewController(identifier: "chatRoomViewController") as! ChatRoomViewController
            chatRoomVC.destinationUid = self.destinationsUids[indexPath.row][0]
            chatRoomVC.chatRoomUid = self.chatRoomUid[indexPath.row]
            
            self.navigationController?.pushViewController(chatRoomVC, animated: true)
        }
    }
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myUid = Auth.auth().currentUser?.uid
        
        self.getChatRoomsList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.getChatRoomsList()
    }
}

class ChatRoomTableCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var usersCountLabel: UILabel!
}
