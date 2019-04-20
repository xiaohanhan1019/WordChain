//
//  UserInfoTableViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/2.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class UserInfoTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userStatusLabel: UILabel!
    @IBOutlet weak var userCityInfo: UILabel!
    @IBOutlet weak var userAgeInfo: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var userSocialDataLabel: UILabel!
    
    @IBOutlet weak var wordListTableView: UITableView!
    @IBOutlet weak var momentTableView: UITableView!
    @IBOutlet weak var tabPanel: UIView!
    @IBOutlet weak var wordListBtn: UIButton!
    @IBOutlet weak var momentBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let scrollBar = UIView()
    
    let userId = UserDefaults.standard.integer(forKey: "userId")
    
    var userWordLists = [WordList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wordList = WordList(name: "aaa", words: [Word(name: "apple"), Word(name: "peach")])
        userWordLists.append(wordList)
        
        // 填充数据
        userImageView.downloadedFrom(link: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555944871&di=45dccd9aa19e79602a26e866d9f0c283&imgtype=jpg&er=1&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201610%2F21%2F20161021114501_kKusd.jpeg", cornerRadius: 75)
        userStatusLabel.text = "dashfjashdkjfhksadhkfhkasdhkjfhkj"
        userNameLabel.text = "xiaohanhan"
        
        userCityInfo.text = "  shanghai  "
        userCityInfo.layer.cornerRadius = 8
        userCityInfo.clipsToBounds = true
        
        userAgeInfo.text = "  23 years old  "
        userAgeInfo.layer.cornerRadius = 8
        userAgeInfo.clipsToBounds = true
        
        userSocialDataLabel.text = "0 Hearts  93 Follow  20 Followers"
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        //初始化要用到的参数
        let WIDTH = self.view.frame.width
        let HEIGHT = self.view.frame.height - 60 - 30 - 49
        
        //设置 tab 标签面板底部阴影
        self.tabPanel.layer.shadowColor = UIColor.white.cgColor
        self.tabPanel.layer.shadowRadius = 0.5
        self.tabPanel.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        self.tabPanel.layer.shadowOpacity = 1
        
        //添加 tab 标签面板底部蓝条
        self.view.addSubview(self.scrollBar)
        self.scrollBar.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        self.scrollBar.frame = CGRect(x: WIDTH/8, y: 294, width: WIDTH / 4, height: 3)
        
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
        return 3
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
            self.scrollBar.frame = CGRect(x: offsetX / 2 + self.view.frame.width/8, y: 294, width: self.view.frame.width / 4, height: 3)
            
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
    
    @IBAction func wordListBtnPressed(sender: UIButton) {
        //点击按钮时，通过动画移动到对应 tableView
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: { () -> Void in
            self.scrollView.contentOffset.x = 0
        }, completion: nil)
    }
    
    @IBAction func momentBtnPressed(sender: UIButton) {
        //点击按钮时，通过动画移动到对应 tableView
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: { () -> Void in
            self.scrollView.contentOffset.x = self.view.frame.width
        }, completion: nil)
    }
    
    //http://47.103.3.131:5000/getUserInfo
//    func getUserInfo()
//    {
//        let session = URLSession(configuration: .default)
//
//        let json = ["id":userId]
//        let jsonData = try? JSONSerialization.data(withJSONObject: json)
//
//        let url = URL(string: "http://47.103.3.131:5000/getUserInfo")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = jsonData
//        let task = session.dataTask(with: request) { [weak self] (data: Data?, response, error) in
//            if let error = error {
//                print("error: \(error)")
//            } else {
//                if let response = response as? HTTPURLResponse {
//                    print("statusCode: \(response.statusCode)")
//                }
//                if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                    print("data: \(dataString)")
//                    let user = try! JSONDecoder().decode(User.self, from: data)
//                    DispatchQueue.main.async {
//                        //self?.nicknameLabel.text = user.nickname
//                        // TODO 存储
//                    }
//                }
//            }
//        }
//        task.resume()
//    }
    
}
