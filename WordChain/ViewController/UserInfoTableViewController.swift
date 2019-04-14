//
//  UserInfoTableViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/2.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class UserInfoTableViewController: UITableViewController {
    
    //TODO 几乎都要重新写
    
    @IBOutlet var userInfoTableView: UITableView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var personaStatusLabel: UILabel!
    
    let userId = UserDefaults.standard.integer(forKey: "userId")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userInfoTableView.sectionHeaderHeight = 16
        userInfoTableView.sectionFooterHeight = 16
        
        // 调用接口获取用户信息
        getUserInfo()
    }
    
    //http://47.103.3.131:5000/getUserInfo
    func getUserInfo()
    {
        let session = URLSession(configuration: .default)
        
        let json = ["id":userId]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "http://47.103.3.131:5000/getUserInfo")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = session.dataTask(with: request) { [weak self] (data: Data?, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                    let user = try! JSONDecoder().decode(User.self, from: data)
                    DispatchQueue.main.async {
                        self?.nicknameLabel.text = user.nickname
                        // TODO 存储
                    }
                }
            }
        }
        task.resume()
    }
    
    @IBAction func touchLikes(_ sender: Any) {
        print("likes")
    }
    
}
