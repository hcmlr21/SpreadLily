//
//  ChatRoomsViewController.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/14.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit

class ChatRoomsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    // MARK: - ProPerties
    let cellIdentifier: String = "chatRoomCell"
    var chatRoomUid: String?
    var chatRooms: [ChatModel] = []
    
    // MARK: - Methods
    
    // MARK: - IBOutlets
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? ChatRoomTableCell else {
            return UITableViewCell()
        }
        
        
        
        return cell
    }
    
    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

class ChatRoomTableCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
}
