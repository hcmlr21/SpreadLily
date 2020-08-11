//
//  ViewController.swift
//  JayTalk2
//
//  Created by Jkookoo on 2020/08/11.
//  Copyright © 2020 Jkookoo. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class ViewController: UIViewController {
    // MARK: - ProPerties
    var remoteConfig: RemoteConfig!
    
    // MARK: - Methods
    func initPage() {
        let color = self.remoteConfig["splash_background"].stringValue
        let messageCaps = self.remoteConfig["splash_message_caps"].boolValue
        let message = self.remoteConfig["splash_message"].stringValue
        
        self.view.backgroundColor = UIColor(hex: color!)
        
        if(messageCaps) {
            //서버 닫혀있을 때
            let alertController = UIAlertController(title: "공지사항", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { (action) in
                exit(0)
            }
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            //서버 열려있을 때
            let loginVC = self.storyboard?.instantiateViewController(identifier: "loginViewController") as! LoginViewController
            loginVC.modalPresentationStyle = .fullScreen
            
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - IBOutlets
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSource
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let box = UIImageView()
        self.view.backgroundColor = UIColor(hex: "#000000")
        self.view.addSubview(box)
        box.snp.makeConstraints { (m) in
            m.center.equalTo(self.view)
        }
        box.image = #imageLiteral(resourceName: "loading_icon")
        
        
        self.remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSetting = RemoteConfigSettings()
        remoteConfigSetting.minimumFetchInterval = 0
        self.remoteConfig.configSettings = remoteConfigSetting
        self.remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        self.remoteConfig.fetch { (status, error) in
            if status == .success {
                print("Config fetched")
                self.remoteConfig.activate { (changed, error) in
                    //...
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            self.initPage()
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        
        scanner.scanLocation = 1 // 16진수로 값 입력시 앞에 #을 붙이게 되는데 그 이후의 값부터 읽기 위함
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
