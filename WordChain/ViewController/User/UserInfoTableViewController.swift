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
    
    var userId = UserDefaults.standard.integer(forKey: "userId")
    
    var userWordLists = [WordList]()
    var momentList = [Moment]()
    
    let semaphore = DispatchSemaphore(value: 1)
    
    var isUserHimself: Bool {
        if user == nil {
            return true
        } else {
            return user!.id == userId
        }
    }
    
    var settingBtn = UIButton()
    var isFollowed :Bool? = nil {
        didSet {
            DispatchQueue.main.async {
                self.followBtn.setTitle(self.isFollowed ?? false ? "已关注" : "关 注", for: .normal)
                self.followBtn.titleLabel?.textAlignment = .center
                self.followBtn.titleLabel?.textColor = UIColor.white
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        //设置按钮
        settingBtn = UIButton(type: .custom)
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
        let HEIGHT = self.view.frame.height - 88 - 30 - 196 - 5
        
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
        self.wordListTableView.separatorStyle = .none
        
        //设置 tableViewRight delegate，并消除多余分割线
        self.momentTableView.delegate = self
        self.momentTableView.dataSource = self
        self.momentTableView.tableFooterView = UIView()
        
        //设置 scrollView contentSize
        self.scrollView.contentSize = CGSize(width: WIDTH * 2, height: HEIGHT)
        //设置两个 tableView 大小位置
        self.wordListTableView.frame = CGRect(x: 8, y: 0, width: WIDTH - 16, height: HEIGHT)
        self.momentTableView.frame = CGRect(x: WIDTH + 8, y: 0, width: WIDTH - 16, height: HEIGHT)
        
        //创建重用cell
        self.wordListTableView.register(UINib(nibName:"WordListCell", bundle:nil),forCellReuseIdentifier:"wordListCell")
        self.momentTableView.register(UINib(nibName:"MomentTableViewCell", bundle:nil),forCellReuseIdentifier:"momentCell")
        
        self.momentTableView.estimatedRowHeight = 136
        self.momentTableView.rowHeight = 136
        self.momentTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        userId = UserDefaults.standard.integer(forKey: "userId")
        var id: Int
        if isUserHimself {
            id = userId
            settingBtn.isHidden = false
            followBtn.isHidden = true
            self.title = "我"
        } else {
            id = user!.id
            settingBtn.isHidden = true
            followBtn.isHidden = false
            self.title = user?.nickname
        }
        getUserInfo(userId: id)
        getUserWordList(userId: id)
        getMoment(userId: id)
        judgeIsFollowed(userId: userId, followUserId: id)
    }
    
    func updateUI(){
        // 没有头像用默认的
        if user?.image_url == "" {
            userImageView.downloadedFrom(link: "http://47.103.3.131/default.jpg", cornerRadius: 75)
        } else {
            userImageView.downloadedFrom(link: user?.image_url ?? "http://47.103.3.131/default.jpg", cornerRadius: 75)
        }
        userStatusLabel.text = user?.status
        userNameLabel.text = user?.nickname
        
        self.wordListTableView.reloadData()
        self.momentTableView.reloadData()
    }
    
    @IBAction func followUser(_ sender: Any) {
        var id: Int
        if isUserHimself {
            id = userId
        } else {
            id = user!.id
        }
        if isFollowed! == true {
            unfollowUser(userId: userId, followUserId: id)
        } else {
            followUser(userId: userId, followUserId: id)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.wordListTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wordListCell", for: indexPath)
            if let wordListCell = cell as? WordListCell {
                wordListCell.wordList = userWordLists[indexPath.row]
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "momentCell", for: indexPath)
            if let momentCell = cell as? MomentTableViewCell {
                momentCell.moment = momentList[indexPath.row]
                momentCell.selectionStyle = .none
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.wordListTableView {
            return userWordLists.count
        } else {
            return momentList.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == wordListTableView {
            self.performSegue(withIdentifier: "showWordListDetail", sender: tableView)
            wordListTableView.deselectRow(at: indexPath, animated: true)
        } else {
            self.performSegue(withIdentifier: "momentShowWordListDetail", sender: tableView)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWordListDetail" {
            if let indexPath = wordListTableView.indexPathForSelectedRow {
                let wordList = userWordLists[indexPath.row]
                
                let controller = (segue.destination) as! WordListDetailTableViewController
                controller.wordList = wordList
                
                //去掉后退键文字
                let item = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
                self.navigationItem.backBarButtonItem = item
            }
        } else if segue.identifier == "momentShowWordListDetail" {
            if let indexPath = momentTableView.indexPathForSelectedRow {
                let wordList = momentList[indexPath.row].wordList
                
                let controller = (segue.destination) as! WordListDetailTableViewController
                controller.wordList = wordList
                
                //去掉后退键文字
                let item = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
                self.navigationItem.backBarButtonItem = item
            }
        }
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
        
        // 强行
        vc.controller = self
        
        //去掉后退键文字
        let item = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //http://47.103.3.131:5000/getUserInfo
    func getUserInfo(userId: Int) {
        let parameters = ["user_id": userId]
        let request = "http://47.103.3.131:5000/getUserInfo"
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()
            Alamofire.request(request, method: .post, parameters: parameters).responseJSON { [weak self] response in
                
                if let statusCode = response.response?.statusCode, let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("getUserInfo: \(utf8Text)")
                    if statusCode == 200 {
                        self?.user = try! JSONDecoder().decode(User.self, from: data)
                    }
                }
                self?.semaphore.signal()
            }
        }
    }
    
    // 判断是否被用户关注
    //http://47.103.3.131:5000/judgeIsFollowed
    func judgeIsFollowed(userId: Int, followUserId: Int){
        let parameters = ["user_id": userId, "follow_user_id": followUserId ] as [String : Any]
        let request = "http://47.103.3.131:5000/judgeIsFollowed"
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()
            Alamofire.request(request, method: .post, parameters: parameters).responseJSON { [weak self] response in
                
                if let statusCode = response.response?.statusCode {
                    print("judge follow status code: \(statusCode)")
                    if statusCode == 200 {
                        self?.isFollowed = true
                    } else {
                        self?.isFollowed = false
                    }
                }
                self?.semaphore.signal()
            }
        }
    }
    
    // 关注用户
    func followUser(userId: Int, followUserId: Int) {
        let parameters = ["user_id": userId, "follow_user_id": followUserId ]
        let request = "http://47.103.3.131:5000/followUser"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let statusCode = response.response?.statusCode {
                print("follow status code: \(statusCode)")
                if statusCode == 200 {
                    self?.isFollowed = true
                } else {
                    self?.isFollowed = false
                }
            }
        }
    }
    
    // 取消关注用户
    func unfollowUser(userId: Int, followUserId: Int) {
        let parameters = ["user_id": userId, "follow_user_id": followUserId ]
        let request = "http://47.103.3.131:5000/unFollowUser"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let statusCode = response.response?.statusCode {
                print("unfollow status code: \(statusCode)")
                if statusCode == 200 {
                    self?.isFollowed = false
                } else {
                    self?.isFollowed = true
                }
            }
        }
    }
    
    //获取用户创建的单词表
    //http://47.103.3.131:5000/getAllUserWordList
    func getUserWordList(userId: Int) {
        let parameters = ["user_id": userId]
        let request = "http://47.103.3.131:5000/getAllUserWordList"
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()
            Alamofire.request(request, method: .post, parameters: parameters).responseJSON { [weak self] response in
                
                if let statusCode = response.response?.statusCode, let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("getUserWordList: \(utf8Text)")
                    if statusCode == 200 {
                        self?.userWordLists = try! JSONDecoder().decode([WordList].self, from: data)
                    }
                }
                self?.semaphore.signal()
            }
        }
    }
    
    //获取moment
    //http://47.103.3.131:5000/getMoment
    func getMoment(userId: Int) {
        let parameters = ["user_id": userId]
        let request = "http://47.103.3.131:5000/getMoment"
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()
            Alamofire.request(request, method: .post, parameters: parameters).responseJSON { [weak self] response in
                
                if let statusCode = response.response?.statusCode, let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("getMoment: \(utf8Text)")
                    if statusCode == 200 {
                        self?.momentList = try! JSONDecoder().decode([Moment].self, from: data)
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
                self?.semaphore.signal()
            }
        }
    }
    
}
