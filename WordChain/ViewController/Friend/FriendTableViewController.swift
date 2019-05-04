//
//  FriendTableViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/5/3.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

class FriendTableViewController: UITableViewController {
    
    var friends = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "关注"
        
        // 去除导航栏下边框,设置颜色
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        // 去除tableview分割线
        self.tableView.separatorStyle = .none
        
        self.tableView.register(UINib(nibName:"UserCell", bundle:nil),forCellReuseIdentifier:"userCell")
        
        let addFriendBtn = UIButton(type: .custom)
        addFriendBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        addFriendBtn.setImage(UIImage(named:"add_friend"), for: .normal)
        addFriendBtn.tintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        let addFriendBarItem = UIBarButtonItem(customView: addFriendBtn)
        let currWidth = addFriendBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = addFriendBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = addFriendBarItem
        addFriendBtn.addTarget(self, action: #selector(self.pushAddFriendPage), for: UIControl.Event.touchUpInside)
    }
    
    @objc func pushAddFriendPage() {
        let sb = UIStoryboard(name: "Main", bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "searchFriend") as! SearchFriendViewController
        
        //去掉后退键文字
        let item = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFollowedUser()
    }
    
    func updateUI() {
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // 去掉多余的分割线
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        cell.user = friends[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showUserInfo", sender: tableView)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserInfo" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let controller = (segue.destination) as! UserInfoTableViewController
                controller.user = friends[indexPath.row]
                
                //去掉后退键文字
                let item = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
                self.navigationItem.backBarButtonItem = item
            }
        }
    }
    
    func getFollowedUser() {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let parameters = ["user_id": userId]
        let request = "http://47.103.3.131:5000/getFollowedUser"
        
        DispatchQueue.global(qos: .userInitiated).async {
            Alamofire.request(request, method: .post, parameters: parameters).responseJSON { [weak self] response in
                
                if let statusCode = response.response?.statusCode, let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if statusCode == 200 {
                        self?.friends = try! JSONDecoder().decode([User].self, from: data)
                    }
                }
                DispatchQueue.main.async {
                    UIView.transition(
                        with: self!.view,
                        duration: 0.5,
                        options: [.transitionCrossDissolve],
                        animations: {
                            self?.updateUI()
                    })
                }
            }
        }
    }

}
