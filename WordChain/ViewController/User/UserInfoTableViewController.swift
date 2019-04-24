//
//  UserInfoTableViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/2.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

class UserInfoTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userStatusLabel: UILabel!
    @IBOutlet weak var userCityInfo: UILabel!
    @IBOutlet weak var userAgeInfo: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    @IBOutlet weak var wordListTableView: UITableView!
    @IBOutlet weak var momentTableView: UITableView!
    @IBOutlet weak var tabPanel: UIView!
    @IBOutlet weak var wordListBtn: UIButton!
    @IBOutlet weak var momentBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var user: User? = nil
    
    let scrollBar = UIView()
    
    let userId = UserDefaults.standard.integer(forKey: "userId")
    
    var userWordLists = [WordList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wordList = WordList(name: "aaa", words: [Word(name: "apple"), Word(name: "peach")])
        userWordLists.append(wordList)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.title = "我"
        
        //设置按钮
        let settingBtn = UIButton(type: .custom)
        settingBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        settingBtn.setImage(UIImage(named:"setting"), for: .normal)
        settingBtn.tintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        let settingBarItem = UIBarButtonItem(customView: settingBtn)
        let currWidth = settingBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = settingBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = settingBarItem
        settingBtn.addTarget(self, action: #selector(self.pushSettingPage), for: UIControl.Event.touchUpInside)
        
        //初始化要用到的参数
        let WIDTH = self.view.frame.width
        let HEIGHT = self.view.frame.height - 88 - 30 - 180 - 5
        
        //设置 tab 标签面板底部阴影
        self.tabPanel.layer.shadowColor = UIColor.white.cgColor
        self.tabPanel.layer.shadowRadius = 0.5
        self.tabPanel.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        self.tabPanel.layer.shadowOpacity = 1
        
        //添加 tab 标签面板底部蓝条
        self.view.addSubview(self.scrollBar)
        self.scrollBar.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        self.scrollBar.frame = CGRect(x: WIDTH/8, y: 266, width: WIDTH / 4, height: 3)
        
        //初始化按钮颜色
        self.wordListBtn.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
        
        //设置 scrollView delegate
        self.scrollView.delegate = self
        self.scrollView.showsVerticalScrollIndicator = false;
        self.scrollView.showsHorizontalScrollIndicator = false;
        
        //设置 tableViewLeft delegate，并消除多余分割线
        self.wordListTableView.delegate = self
        self.wordListTableView.dataSource = self
        self.wordListTableView.tableFooterView = UIView()
        
        //设置 tableViewRight delegate，并消除多余分割线
        self.momentTableView.delegate = self
        self.momentTableView.dataSource = self
        self.momentTableView.tableFooterView = UIView()
        
        //设置 scrollView contentSize
        self.scrollView.contentSize = CGSize(width: WIDTH * 2, height: HEIGHT)
        //设置两个 tableView 大小位置
        self.wordListTableView.frame = CGRect(x: 8, y: 0, width: WIDTH - 16, height: HEIGHT)
        self.momentTableView.frame = CGRect(x: WIDTH + 8, y: 0, width: WIDTH - 16, height: HEIGHT)
        
        //TODO 有bug scrollView和TableView的手势问题
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        getUserInfo(userId: userId)
    }
    
    func updateUI(){
        // 没有头像用默认的
        userImageView.downloadedFrom(link: user?.image_url ?? "http://47.103.3.131/default.jpg", cornerRadius: 75)
        userStatusLabel.text = user?.status
        userNameLabel.text = user?.nickname
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.wordListTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wordListCell", for: indexPath)
            if let wordListCell = cell as? WordListCell {
                wordListCell.wordList = userWordLists[0]
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath)
            if let wordCell = cell as? WordCell {
                wordCell.word = userWordLists[0].words[0]
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            //改变 scrollBar x 坐标，达成同步滑动效果。
            let offsetX = scrollView.contentOffset.x
            self.scrollBar.frame = CGRect(x: offsetX / 2 + self.view.frame.width/8, y: 266, width: self.view.frame.width / 4, height: 3)
            
            //对应修改 btn 文字颜色
            if offsetX > self.view.frame.width / 2 {
                self.wordListBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                self.momentBtn.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
            } else {
                self.wordListBtn.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
                self.momentBtn.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            }
        }
    }
    
    @IBAction func switchTab(_ sender: Any) {
        if sender as? UIButton == wordListBtn {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: { () -> Void in
                self.scrollView.contentOffset.x = 0
            }, completion: nil)
        } else if sender as? UIButton == momentBtn {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: { () -> Void in
                self.scrollView.contentOffset.x = self.view.frame.width
            }, completion: nil)
        }
    }
    
    // 跳转到设置
    @objc func pushSettingPage (button: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "userSetting") as! UserSettingTableViewController
        vc.user = user
        vc.userImage = userImageView.image
        
        //去掉后退键文字
        let item = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //http://47.103.3.131:5000/getUserInfo
    func getUserInfo(userId: Int) {
        let parameters = ["user_id": userId]
        let request = "http://47.103.3.131:5000/getUserInfo"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
                self?.user = try! JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self?.updateUI()
                }
            }
        }
    }
    
}
