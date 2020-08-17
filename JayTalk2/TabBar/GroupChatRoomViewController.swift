//
//  GroupChatRoomViewController.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/17.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import Firebase

class GroupChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - ProPerties
    var myUid: String?
    var destinationsUid: [String] = []
    var chatRoomUid: String?
    var destinationUsersModel: [UserModel] = []
    var messages: [ChatModel.Comment] = []
    var databaseRef: DatabaseReference?
    var observe: UInt?
    
    // MARK: - Methods
    
    // MARK: - IBOutlets
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageInfo = self.messages[indexPath.row]
        if(messageInfo.uid == self.myUid) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "myMessageCell", for: indexPath) as? MyMessageTableCell else {
                return UITableViewCell()
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "destinationMessageCell", for: indexPath) as? DestinationMessageTableCell else {
                return UITableViewCell()
            }
            return cell
        }
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myUid = Auth.auth().currentUser?.uid
        
    }
}
