//
//  QuestionAndAnswerRoomViewController.swift
//  JayTalk
//
//  Created by Jkookoo on 2021/04/08.
//  Copyright © 2021 Jkookoo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class QuestionAndAnswerRoomViewController: UIViewController {
    // MARK: - Properties
    var myUid: String?
    var databaseRef: DatabaseReference?
    var observe: UInt?
    var messages: [String] = []
    var QAAs: [QAModel] = []
    let answerTableCellIdentifier = "answerCell"
    let questionTableCellIdentifier = "questionCell"
    
    // MARK: - Methods
    func keyboardDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func getMessages() {
        self.databaseRef = Database.database().reference().child("QnAData").child(self.myUid!).child("QnAs")
            
        self.observe = self.databaseRef?.observe(.value, with: { [self] (dataSnapShot) in
            self.QAAs.removeAll()
            self.messages.removeAll()
            
            var messagesDic: [String:AnyObject] = [:]
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                let key = item.key
                let QAA = QAModel(JSON: item.value as! [String : Any])
//                let modifiedMessage = ChatModel.Comment(JSON: item.value as! [String : Any])
//                modifiedMessage?.readUsers[self.myUid!] = true
//                messagesDic[key] = modifiedMessage?.toJSON() as! NSDictionary
                if let question = QAA?.question {
                    self.messages.append(question)
                }
                
                if let answer = QAA?.answer {
                    self.messages.append(answer)
                }
                
                self.QAAs.append(QAA!)
            }
            
            self.tableView.reloadData()
            
            
//            let nsMessagesDic = messagesDic as NSDictionary
            
//            if(self.QAAs.last?.readUsers == nil) {
//                return
//            }
            
//            if(!(self.QAAs.last?.readUsers.keys.contains(self.myUid!))!) {
//                dataSnapShot.ref.updateChildValues(nsMessagesDic as! [AnyHashable : Any]) { (error, ref) in
//                    self.tableView.reloadData()
//
//                    if(self.QAAs.count > 0) {
//                        self.tableView.scrollToRow(at: IndexPath(item: self.QAAs.count - 1, section: 0), at: .bottom, animated: false)
//                    }
//                }
//            } else {
//                self.tableView.reloadData()
//
//                if(self.QAAs.count > 0) {
//                    self.tableView.scrollToRow(at: IndexPath(item: self.QAAs.count - 1, section: 0), at: .bottom, animated: false)
//                }
//            }
            
        })
    }
    
    func checkQuestionRoom() {
        let QnADataRef = Database.database().reference().child("QnAData")
         
        QnADataRef.child(myUid!).child("QnAs").observeSingleEvent(of: .value, with: { (dataSnapShot) in
            if let QnAList = dataSnapShot.children.allObjects as? [DataSnapshot] {
                if QnAList.isEmpty {
                    let question = "안녕하세요!"
                    let QnA = [
                        "question":question
                    ]
                    QnADataRef.child(self.myUid!).child("QnAs").childByAutoId().setValue(QnA)
                    
                    
                }
            }
            
            self.getMessages()
        })
    }
    
    func getQuestion() {
        
    }
    
    @objc func touchUpsendButton() {
        let QnADataRef = Database.database().reference().child("QnAData")
        let questionsRef = QnADataRef.child(myUid!).child("questions")
        
        
        QnADataRef.child(myUid!).child("QnAs").observeSingleEvent(of: .value) { (dataSnapShot) in
            if let QnAs =  dataSnapShot.children.allObjects as? [DataSnapshot] {
                if let QnA = QAModel(JSON: QnAs.last?.value as! [String : Any]), let question = QnA.question {
                    let answer = self.messageTextField.text!
                    
                    let QnA = [
                        "question": question,
                        "answer": answer
                    ]
        
                    QnADataRef.child(self.myUid!).child("QnAs").child(QnAs.last!.key).setValue(QnA)
                    
                    self.messageTextField.text = ""
                    
                    questionsRef.observeSingleEvent(of: .value) { (dataSnapShot) in
                        let questions = dataSnapShot.children.allObjects as! [DataSnapshot]
                        let questionSize = questions.count
                        let randNum = arc4random_uniform(UInt32(questionSize))
                        let questionDic = questions[Int(randNum)]
                        let key = questionDic.key
                        let question = questionDic.value

                        questionsRef.child("\(key)").removeValue()
                        
                        let QnA = [
                            "question":question
                        ]
                        
                        QnADataRef.child(self.myUid!).child("QnAs").childByAutoId().setValue(QnA) { (error, ref) in
                            if(error == nil) {
                //                self.tableView.setContentOffset(CGPoint(x: 0, y: CGFloat.greatestFiniteMagnitude), animated: false)
                            }
                        }
                    }
                }
            }
        }
        
        
        
        
        
//        Database.database().reference().child("chatRooms").child(self.chatRoomUid!).child("comments").childByAutoId().setValue(messageInfo)
        
//        Database.database().reference().child("questions").observeSingleEvent(of: .value) { (dataSnapShot) in
//            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
//                print(item.key)
//                print(item.value)
//            }
//        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: - IBActions
    
    // MARK: - Objcs
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - (tabBarController?.tabBar.frame.height)!
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: - Delegates And DataSources
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardDismissGesture()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        
        self.myUid = Auth.auth().currentUser?.uid

        checkQuestionRoom()
        
        self.sendButton.addTarget(self, action: #selector(self.touchUpsendButton), for: .touchUpInside)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.databaseRef?.removeObserver(withHandle: self.observe!)
    }
}

extension QuestionAndAnswerRoomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        let message = self.messages[index]
        if(index % 2 == 1) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: answerTableCellIdentifier, for: indexPath) as? AnswerTableCell else {
                return UITableViewCell()
            }
            
            cell.answerLabel.numberOfLines = 0
            cell.answerLabel.text = message
            
//            if let time = messageInfo.timeStamp {
//                cell.timeStampLabel.text = time.todayTime
//            }
            
//            self.setUnreadCount(label: cell.unreadCountLabel, position: indexPath.row)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: questionTableCellIdentifier, for: indexPath) as? QuestionTableCell else {
                return UITableViewCell()
            }
            
            cell.questionLabel.numberOfLines = 0
            cell.questionLabel.text = message
            
//            if let time = messageInfo.timeStamp {
//                cell.timeStampLabel.text = time.todayTime
//            }
//
//            let imageUrl = URL(string: (self.destinationUserModel?.profileImageUrl)!)
//            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
//            cell.profileImageView.clipsToBounds = true
//            cell.profileImageView.kf.setImage(with: imageUrl)
//
//            cell.userNameLabel.text = self.destinationUserModel?.userName
            
//            self.setUnreadCount(label: cell.unreadCountLabel, position: indexPath.row)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

class QuestionTableCell: UITableViewCell {
    @IBOutlet weak var questionLabel: UILabel!
    
}

class AnswerTableCell: UITableViewCell {
    @IBOutlet weak var answerLabel: UILabel!
    
}
