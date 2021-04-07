//
//  ChatRoomViewController.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/15.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - ProPerties
    var myUid: String?
    var destinationUid: String?
    var chatRoomUid: String?
    var destinationUserModel: UserModel?
    var messages: [ChatModel.Comment] = []
    var databaseRef: DatabaseReference?
    var observe: UInt?
    
    // MARK: - Methods
    
    func checkMessageSent() {
        //if messages were not sent, room will be deleted
        Database.database().reference().child("chatRooms").child(self.chatRoomUid!).observeSingleEvent(of: .value, with: { (dataSnapShot) in
            let roomInfo = dataSnapShot.value as! [String: Any]
            if roomInfo["comments"] == nil {
                Database.database().reference().child("chatRooms").child(self.chatRoomUid!).removeValue()
            }
        })
    }
    
    func createRoom() {
        let roomInfo = [
            "users":[
                self.myUid!:true,
                self.destinationUid!:true
            ]
        ]
        
        Database.database().reference().child("chatRooms").childByAutoId().setValue(roomInfo) { (error, ref) in
            if(error == nil) {
                self.chatRoomUid = ref.key
                self.getDestinationInfo()
                //self.checkRoom()
            } else {
                print("방 생성 에러")
                print(error)
            }
        }
    }
    
    func checkRoom() {
        //get room uid in case user are from People section
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "users/" + self.myUid!).queryEqual(toValue: true).observeSingleEvent(of: .value, with: { (dataSnapShot) in
            for item in dataSnapShot.children.allObjects as! [DataSnapshot]  {
                if let chatRoomDic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomDic)
                    if(chatModel?.users.count == 2 && chatModel?.users[self.destinationUid!] == true) {
                        self.chatRoomUid = item.key
                        self.getDestinationInfo()
                    }
                }
            }
            
            if (self.chatRoomUid == nil) {
                self.createRoom()
            }
        })
    }
    
    func getDestinationInfo() {
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: .value, with: { (dataSnapShot) in
            let userModel = UserModel()
            userModel.setValuesForKeys(dataSnapShot.value as! [String : Any])
            self.destinationUserModel = userModel
            
            self.getMessages()
        })
    }
    
    func getMessages() {
        self.databaseRef = Database.database().reference().child("chatRooms").child(self.chatRoomUid!).child("comments")
        self.observe = self.databaseRef?.observe(.value, with: { (dataSnapShot) in
            self.messages.removeAll()
            
            var messagesDic: [String:AnyObject] = [:]
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                let key = item.key
                let message = ChatModel.Comment(JSON: item.value as! [String : Any])
                let modifiedMessage = ChatModel.Comment(JSON: item.value as! [String : Any])
                modifiedMessage?.readUsers[self.myUid!] = true
                messagesDic[key] = modifiedMessage?.toJSON() as! NSDictionary
                self.messages.append(message!)
            }
            
            let nsMessagesDic = messagesDic as NSDictionary
            
            if(self.messages.last?.readUsers == nil) {
                return
            }
            
            if(!(self.messages.last?.readUsers.keys.contains(self.myUid!))!) {
                dataSnapShot.ref.updateChildValues(nsMessagesDic as! [AnyHashable : Any]) { (error, ref) in
                    self.tableView.reloadData()
                    
                    if(self.messages.count > 0) {
                        self.tableView.scrollToRow(at: IndexPath(item: self.messages.count - 1, section: 0), at: .bottom, animated: false)
                    }
                }
            } else {
                self.tableView.reloadData()
                
                if(self.messages.count > 0) {
                    self.tableView.scrollToRow(at: IndexPath(item: self.messages.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
        })
    }
    
    @objc func sendMessage() {
        let messageInfo: [String:Any] = [
            "uid":self.myUid!,
            "message":self.messageTextField.text!,
            "timeStamp":ServerValue.timestamp()
        ]
        
        self.messageTextField.text = ""
        Database.database().reference().child("chatRooms").child(self.chatRoomUid!).child("comments").childByAutoId().setValue(messageInfo)
    }
    
    func setUnreadCount(label: UILabel?, position: Int?) {
        
        let readCount = self.messages[position!].readUsers.count
        
        let unreadCount = 2 - readCount
                       
        if(unreadCount > 0) {
            label?.isHidden = false
            label?.text = String(unreadCount)
        } else {
            label?.isHidden = true
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstraint.constant = keyboardSize.height
        }
        
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }) { (complete) in
            if(self.messages.count > 0) {
                self.tableView.scrollToRow(at: IndexPath(item: self.messages.count - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.bottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageInfo = self.messages[indexPath.row]
        if(messageInfo.uid == self.myUid!) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "myMessageCell", for: indexPath) as? MyMessageTableCell else {
                return UITableViewCell()
            }
            
            cell.messageLabel.numberOfLines = 0
            cell.messageLabel.text = messageInfo.message
            
            if let time = messageInfo.timeStamp {
                cell.timeStampLabel.text = time.todayTime
            }
            
            self.setUnreadCount(label: cell.unreadCountLabel, position: indexPath.row)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "destinationMessageCell", for: indexPath) as? DestinationMessageTableCell else {
                return UITableViewCell()
            }
            
            cell.messageLabel.numberOfLines = 0
            cell.messageLabel.text = messageInfo.message
            
            if let time = messageInfo.timeStamp {
                cell.timeStampLabel.text = time.todayTime
            }
            
            let imageUrl = URL(string: (self.destinationUserModel?.profileImageUrl)!)
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.kf.setImage(with: imageUrl)
            
            cell.userNameLabel.text = self.destinationUserModel?.userName
            
            self.setUnreadCount(label: cell.unreadCountLabel, position: indexPath.row)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.myUid = Auth.auth().currentUser?.uid
        
        if(self.chatRoomUid == nil) {
            self.checkRoom()
        } else {
            self.getDestinationInfo()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        self.sendButton.addTarget(self, action: #selector(self.sendMessage), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.removeObserver(self)
        self.databaseRef?.removeObserver(withHandle: self.observe!)
        
        self.checkMessageSent()
    }
}

extension Int {
    var todayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self) / 1000)
        return dateFormatter.string(from: date)
    }
}

class MyMessageTableCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
}

class DestinationMessageTableCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!
}

